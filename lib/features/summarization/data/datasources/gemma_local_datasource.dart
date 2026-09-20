import 'package:flutter/foundation.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';

class GemmaResponse {
  const GemmaResponse({
    required this.text,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.durationMs = 0,
  });

  final String text;
  final int inputTokens;
  final int outputTokens;
  final int durationMs;
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

  /// One stateless generation (fresh session per call). Retries once on
  /// failure; cancellation is never retried.
  ///
  /// With [onPartial], generation is streamed and each token calls it with
  /// the cleaned text accumulated so far. A retry restarts from empty, so
  /// callers should treat each call as replacing the previous partial text.
  Future<GemmaResponse> generate(
    String prompt,
    GemmaGenerationConfig config, {
    void Function(String partialText)? onPartial,
  });

  /// Model-tokenizer token count.
  Future<int> countTokens(String text);

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
    try {
      await session.setPrompt(prompt);
      final String raw;
      if (onPartial == null) {
        raw = await session.respond();
      } else {
        final buffer = StringBuffer();
        await for (final token in session.respondStream()) {
          if (_cancelRequested) break;
          buffer.write(token);
          final partial = cleanResponse(buffer.toString());
          if (partial.isNotEmpty) onPartial(partial);
        }
        raw = buffer.toString();
      }
      watch.stop();
      if (_cancelRequested) throw const CancelledException();

      final text = cleanResponse(raw);
      if (text.isEmpty) throw const GemmaGenerationException('empty response');
      final usage = session.usage;
      return GemmaResponse(
        text: text,
        inputTokens: usage.inputTokens,
        outputTokens: usage.outputTokens,
        durationMs: watch.elapsedMilliseconds,
      );
    } finally {
      _active = null;
      try {
        await session.close();
      } catch (_) {}
    }
  }

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
