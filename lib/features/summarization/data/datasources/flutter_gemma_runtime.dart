import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';

/// [LlmRuntime] on `flutter_gemma` + LiteRT-LM: Gemma 3 1B IT installed from a
/// bundled asset. Contains no logic beyond translating calls, so it is the only
/// part of summarization that needs a real device to verify.
///
/// The engine is initialized on first use, not at app start: the native setup
/// then happens with the first job instead of delaying startup.
class FlutterGemmaRuntime implements LlmRuntime {
  FlutterGemmaRuntime({
    this.assetPath = defaultAssetPath,
    this.contextTokens = 4096,
    this.useGpu = false,
  });

  static const defaultAssetPath = 'assets/models/gemma3-1b-it-q4.litertlm';

  final String assetPath;
  final int contextTokens;
  final bool useGpu;

  static Future<void>? _engine;
  InferenceModel? _model;

  String get _modelFileName => assetPath.split('/').last;

  Future<void> _ensureEngine() => _engine ??= FlutterGemma.initialize(
    inferenceEngines: const [LiteRtLmEngine()],
  );

  @override
  bool get isLoaded => _model != null;

  @override
  Future<bool> isModelAvailable() async {
    try {
      await _ensureEngine();
      return FlutterGemma.hasActiveModel() ||
          await FlutterGemma.isModelInstalled(_modelFileName);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> load() async {
    await _ensureEngine();
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
  }

  @override
  Future<LlmSession> openSession(GemmaGenerationConfig config) async =>
      _Session(
        await _model!.openSession(
          temperature: config.temperature,
          randomSeed: config.seed,
          topK: config.topK,
          topP: config.topP,
          maxOutputTokens: config.maxOutputTokens,
        ),
      );

  /// The legacy singleton lane, kept open just for tokenizing; generation uses
  /// independent `openSession`s so the two never close each other.
  @override
  Future<LlmSession> openTokenizer() async => _Session(await _model!.createSession());

  @override
  Future<void> unload() async {
    final model = _model;
    _model = null;
    await model?.close();
  }
}

class _Session implements LlmSession {
  _Session(this._session);

  final InferenceModelSession _session;

  @override
  Future<void> setPrompt(String prompt) =>
      _session.addQueryChunk(Message.text(text: prompt, isUser: true));

  @override
  Future<String> respond() => _session.getResponse();

  @override
  Stream<String> respondStream() => _session.getResponseAsync();

  @override
  Future<int> countTokens(String text) => _session.sizeInTokens(text);

  @override
  LlmUsage get usage {
    final m = _session.getSessionMetrics();
    return LlmUsage(inputTokens: m.inputTokens, outputTokens: m.outputTokens);
  }

  @override
  Future<void> stop() => _session.stopGeneration();

  @override
  Future<void> close() => _session.close();
}
