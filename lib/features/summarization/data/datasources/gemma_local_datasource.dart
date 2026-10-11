import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/text/loop_guard.dart';
import 'package:nutq/features/summarization/domain/text/output_format.dart';

class GemmaResponse {
  const GemmaResponse({
    required this.text,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.durationMs = 0,
    this.prefillMs = 0,
    this.stoppedOnLoop = false,
    this.hitCap = false,
  });

  final String text;
  final int inputTokens;
  final int outputTokens;
  final int durationMs;

  /// Time to the first token: the prompt prefill. The rest is decode.
  final int prefillMs;

  /// Generation was stopped early because the model started repeating itself.
  final bool stoppedOnLoop;

  /// Ran into `maxOutputTokens`; an unfinished last sentence was cut.
  final bool hitCap;
}

class GemmaGenerationException implements Exception {
  const GemmaGenerationException(this.message);

  final String message;

  @override
  String toString() => 'GemmaGenerationException: $message';
}

/// Talks to the on-device Gemma model and nothing else: no prompts, no
/// chunking policy, no evaluation, no UI.
abstract class GemmaLocalDataSource {
  Future<bool> isModelAvailable();

  /// Installs the bundled model if needed and loads it. Throws
  /// `SummarizationFailure(modelUnavailable)` on failure. Also clears any
  /// pending cancellation from a previous job.
  Future<void> activate();

  /// One stateless, streamed generation (fresh session per call). Retries
  /// once on failure; cancellation is never retried.
  ///
  /// Stops early when the model starts looping (the loop is cut off), and
  /// fails with `SummarizationFailure(generationFailed)` without a retry when
  /// the output is not language at all — a broken backend, which a retry on
  /// the same backend would not fix.
  ///
  /// [onPartial] is called per token with the cleaned text accumulated so
  /// far. A retry restarts from empty, so callers should treat each call as
  /// replacing the previous partial text.
  Future<GemmaResponse> generate(
    String prompt,
    GemmaGenerationConfig config, {
    void Function(String partialText)? onPartial,
  });

  /// Model-tokenizer token count.
  Future<int> countTokens(String text);

  /// Closes the session [countTokens] keeps open. Each LiteRT-LM session
  /// holds its own KV cache, so leaving it open while generating costs a
  /// second cache (~200 MB on the GPU on an iPhone XR). The next
  /// [countTokens] opens it again.
  Future<void> closeTokenizer();

  /// Stops in-flight generation, if any.
  Future<void> cancel();

  Future<void> dispose();
}

/// The Gemma data source: retries, cancellation, streaming, response cleanup and
/// the model's lifecycle, on top of an [LlmRuntime].
class GemmaLocalDataSourceImpl implements GemmaLocalDataSource {
  GemmaLocalDataSourceImpl(this._runtime, {this.maxAttempts = 2});

  final LlmRuntime _runtime;
  final int maxAttempts;

  LlmSession? _tokenizer;
  LlmSession? _active;
  Future<void>? _activation;
  bool _cancelRequested = false;

  @override
  Future<bool> isModelAvailable() => _runtime.isModelAvailable();

  @override
  Future<void> activate() {
    _cancelRequested = false;
    if (_runtime.isLoaded) return Future.value();
    return _activation ??= _load().whenComplete(() => _activation = null);
  }

  Future<void> _load() async {
    try {
      await _runtime.load();
    } catch (e) {
      throw SummarizationFailure(SummarizationFailureKind.modelUnavailable, '$e');
    }
  }

  @override
  Future<GemmaResponse> generate(
    String prompt,
    GemmaGenerationConfig config, {
    void Function(String partialText)? onPartial,
  }) async {
    await activate();
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (_cancelRequested) throw const CancelledException();
      try {
        return await _generateOnce(prompt, config, onPartial);
      } on CancelledException {
        rethrow;
      } on SummarizationFailure {
        rethrow;
      } catch (e) {
        if (_cancelRequested) throw const CancelledException();
        lastError = e;
      }
    }
    throw GemmaGenerationException('$lastError');
  }

  Future<GemmaResponse> _generateOnce(
    String prompt,
    GemmaGenerationConfig config,
    void Function(String partialText)? onPartial,
  ) async {
    final session = await _runtime.openSession(config);
    _active = session;
    final watch = Stopwatch()..start();
    int? firstTokenMs;
    var pieces = 0;
    var stoppedOnLoop = false;
    try {
      await session.setPrompt(prompt);
      final buffer = StringBuffer();
      await for (final token in session.respondStream()) {
        if (_cancelRequested) break;
        if (token.isEmpty) continue;
        firstTokenMs ??= watch.elapsedMilliseconds;
        pieces++;
        buffer.write(token);

        // A broken backend writes garbage from the first token; stop after a
        // few dozen instead of generating to the cap.
        if (pieces == _corruptionCheckAt && looksCorrupted(buffer.toString())) break;

        final cut = loopCut(buffer.toString());
        if (cut != null) {
          final kept = buffer.toString().substring(0, cut);
          buffer
            ..clear()
            ..write(kept);
          stoppedOnLoop = true;
          break;
        }

        if (onPartial != null) {
          final partial = cleanResponse(buffer.toString());
          if (partial.isNotEmpty) onPartial(partial);
        }
      }
      if (stoppedOnLoop || pieces == _corruptionCheckAt) {
        // Leaving the loop ends the stream; stopping the native decoder only
        // stops it burning CPU meanwhile.
        try {
          await session.stop();
        } catch (_) {}
      }
      watch.stop();
      if (_cancelRequested) throw const CancelledException();

      var raw = buffer.toString();
      if (looksCorrupted(raw)) {
        throw const SummarizationFailure(
          SummarizationFailureKind.generationFailed,
          'unreadable model output',
        );
      }

      final usage = session.usage;

      // Hitting the cap cuts the model off, usually mid-sentence. Keep what
      // ends a sentence.
      final hitCap =
          !stoppedOnLoop && math.max(usage.outputTokens, pieces) >= config.maxOutputTokens;
      if (hitCap) {
        final lastEnd = raw.lastIndexOf(_sentenceEnd);
        if (lastEnd > raw.length ~/ 3) raw = raw.substring(0, lastEnd + 1);
      }

      final text = cleanResponse(raw);
      if (text.isEmpty) throw const GemmaGenerationException('empty response');
      return GemmaResponse(
        text: text,
        inputTokens: usage.inputTokens,
        // The native side does not always fill token counts; a streamed piece
        // is about one token.
        outputTokens: usage.outputTokens > 0 ? usage.outputTokens : pieces,
        durationMs: watch.elapsedMilliseconds,
        prefillMs: firstTokenMs ?? watch.elapsedMilliseconds,
        stoppedOnLoop: stoppedOnLoop,
        hitCap: hitCap,
      );
    } finally {
      _active = null;
      try {
        await session.close();
      } catch (_) {}
    }
  }

  static const _corruptionCheckAt = 40;
  static final RegExp _sentenceEnd = RegExp('[.!?؟؛…]');

  /// Strips chat-template artifacts and code fences the model sometimes
  /// emits around its answer.
  @visibleForTesting
  static String cleanResponse(String raw) {
    var text = raw
        .replaceAll(RegExp(r'<end_of_turn>|<start_of_turn>(?:model|user)?|<eos>|<bos>'), '')
        .trim();
    final fenced = RegExp(r'^```[a-zA-Z]*\n([\s\S]*?)\n?```$').firstMatch(text);
    if (fenced != null) text = fenced.group(1)!.trim();
    return text;
  }

  @override
  Future<int> countTokens(String text) async {
    await activate();
    _tokenizer ??= await _runtime.openTokenizer();
    return _tokenizer!.countTokens(text);
  }

  @override
  Future<void> closeTokenizer() async {
    final tokenizer = _tokenizer;
    _tokenizer = null;
    try {
      await tokenizer?.close();
    } catch (_) {}
  }

  @override
  Future<void> cancel() async {
    _cancelRequested = true;
    try {
      await _active?.stop();
    } catch (_) {}
  }

  /// Unloads the model and frees its memory; the next call reloads it.
  @override
  Future<void> dispose() async {
    try {
      await _tokenizer?.close();
    } catch (_) {}
    _tokenizer = null;
    try {
      await _runtime.unload();
    } catch (_) {}
  }
}
