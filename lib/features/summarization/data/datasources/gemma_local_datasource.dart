import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
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
  Future<GemmaResponse> generate(String prompt, GemmaGenerationConfig config);

  /// Model-tokenizer token count.
  Future<int> countTokens(String text);

  /// Stops in-flight generation, if any.
  Future<void> cancel();

  Future<void> dispose();
}

class GemmaLocalDataSourceImpl implements GemmaLocalDataSource {
  GemmaLocalDataSourceImpl({
    this.assetPath = defaultAssetPath,
    this.maxAttempts = 2,
    this.contextTokens = 4096,
    this.useGpu = false,
  });

  static const defaultAssetPath = 'assets/models/gemma3-1b-it-q4.litertlm';

  final String assetPath;
  final int maxAttempts;
  final int contextTokens;
  final bool useGpu;

  InferenceModel? _model;
  InferenceModelSession? _tokenizer;
  InferenceModelSession? _active;
  Future<void>? _activation;
  bool _cancelRequested = false;

  String get _modelFileName => assetPath.split('/').last;

  @override
  Future<bool> isModelAvailable() async {
    try {
      return FlutterGemma.hasActiveModel() ||
          await FlutterGemma.isModelInstalled(_modelFileName);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> activate() {
    _cancelRequested = false;
    if (_model != null) return Future.value();
    return _activation ??= _load().whenComplete(() => _activation = null);
  }

  Future<void> _load() async {
    try {
      if (!FlutterGemma.hasActiveModel()) {
        await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
          fileType: ModelFileType.litertlm,
        ).fromAsset(assetPath).install();
      }
      _model = await FlutterGemma.getActiveModel(
        maxTokens: contextTokens,
        preferredBackend: useGpu ? PreferredBackend.gpu : PreferredBackend.cpu,
      );
    } catch (e) {
      throw SummarizationFailure(SummarizationFailureKind.modelUnavailable, '$e');
    }
  }

  @override
  Future<GemmaResponse> generate(String prompt, GemmaGenerationConfig config) async {
    await activate();
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (_cancelRequested) throw const SummarizationCancelledException();
      try {
        return await _generateOnce(prompt, config);
      } on SummarizationCancelledException {
        rethrow;
      } catch (e) {
        if (_cancelRequested) throw const SummarizationCancelledException();
        lastError = e;
      }
    }
    throw GemmaGenerationException('$lastError');
  }

  Future<GemmaResponse> _generateOnce(String prompt, GemmaGenerationConfig config) async {
    final model = _model!;
    final session = await model.openSession(
      temperature: config.temperature,
      randomSeed: config.seed,
      topK: config.topK,
      topP: config.topP,
      maxOutputTokens: config.maxOutputTokens,
    );
    _active = session;
    final watch = Stopwatch()..start();
    try {
      await session.addQueryChunk(Message.text(text: prompt, isUser: true));
      final raw = await session.getResponse();
      watch.stop();
      if (_cancelRequested) throw const SummarizationCancelledException();

      final metrics = session.getSessionMetrics();
      final text = cleanResponse(raw);
      if (text.isEmpty) throw const GemmaGenerationException('empty response');
      return GemmaResponse(
        text: text,
        inputTokens: metrics.inputTokens,
        outputTokens: metrics.outputTokens,
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
    // Legacy singleton lane, kept open just for tokenizing; generation uses
    // independent `openSession`s so the two never close each other.
    _tokenizer ??= await _model!.createSession();
    return _tokenizer!.sizeInTokens(text);
  }

  @override
  Future<void> cancel() async {
    _cancelRequested = true;
    try {
      await _active?.stopGeneration();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      await _tokenizer?.close();
      await _model?.close();
    } catch (_) {}
    _tokenizer = null;
    _model = null;
  }
}
