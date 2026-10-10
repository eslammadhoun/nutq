import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';
import 'package:nutq/features/summarization/data/datasources/summarizer_model.dart';

/// [LlmRuntime] on `flutter_gemma` + LiteRT-LM: [model] loaded from the file
/// the app downloaded (`ModelRepository`), registered with flutter_gemma in
/// place, without a copy. Contains no logic beyond translating calls, so it is the only
/// part of summarization that needs a real device to verify.
///
/// The engine is initialized on first use, not at app start: the native setup
/// then happens with the first job instead of delaying startup.
class FlutterGemmaRuntime implements LlmRuntime {
  FlutterGemmaRuntime({
    required this.modelPath,
    this.model = activeSummarizerModel,
    this.backend = PreferredBackend.gpu,
  });

  final SummarizerModel model;

  /// Where the downloaded [model] file is.
  final String Function() modelPath;

  /// Where inference runs. On an iPhone XR (3 GB) v3 on the GPU ran the AI
  /// lecture (2279 words) in 44.7 s — prefill ~160 tok/s, decode 15.8 tok/s —
  /// against ~70-86 and ~10 tok/s on the CPU (2026-09-28). The plugin falls
  /// back to the CPU by itself when the GPU fails to initialize.
  ///
  /// The iOS Simulator only emulates Metal, and there the GPU computes garbage
  /// (`ৈতন্য بالcameraAutoFocus <unused607>…` from the first token), so the
  /// simulator always runs on the CPU ([_resolveBackend]).
  final PreferredBackend backend;

  static const _deviceChannel = MethodChannel('nutq/device');

  static Future<void>? _engine;
  InferenceModel? _model;

  /// The backend the model was created with (CPU on the simulator).
  PreferredBackend? runningBackend;

  Future<void> _ensureEngine() => _engine ??= FlutterGemma.initialize(
    inferenceEngines: const [LiteRtLmEngine()],
  );

  Future<PreferredBackend> _resolveBackend() async {
    if (backend == PreferredBackend.cpu) return backend;
    try {
      final simulator = await _deviceChannel.invokeMethod<bool>('isSimulator');
      return simulator ?? false ? PreferredBackend.cpu : backend;
    } catch (_) {
      // Only iOS answers; elsewhere there is no simulator to guard against.
      return backend;
    }
  }

  @override
  bool get isLoaded => _model != null;

  @override
  Future<bool> isModelAvailable() async {
    try {
      return await File(modelPath()).exists();
    } catch (_) {
      return false;
    }
  }

  /// flutter_gemma restores the last active model on launch, so after the app
  /// moves to a new model an installed old one would otherwise keep running.
  /// The path counts too: iOS moves the app's folder on every update.
  bool get _isActive {
    final active = FlutterGemmaPlugin.instance.modelManager.activeInferenceModel;
    if (active is! InferenceModelSpec || active.name != model.fileName) return false;
    final source = active.modelSource;
    return source is FileSource && source.path == modelPath();
  }

  @override
  Future<void> load() async {
    await _ensureEngine();
    if (!_isActive) {
      await _forgetEarlierInstall();
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.litertlm,
      ).fromFile(modelPath()).install();
    }
    final resolved = await _resolveBackend();
    _model = await FlutterGemma.getActiveModel(
      maxTokens: model.contextTokens,
      preferredBackend: resolved,
    );
    runningBackend = resolved;
  }

  /// Drops flutter_gemma's record of the model from an earlier install: a
  /// stale path, or, from builds that bundled the model, its own ~580 MB copy
  /// of the asset, which this deletes.
  Future<void> _forgetEarlierInstall() async {
    try {
      if (await FlutterGemma.isModelInstalled(model.fileName)) {
        await FlutterGemma.uninstallModel(model.fileName);
      }
    } catch (_) {
      // Best effort: installing from the file below works either way.
    }
  }

  @override
  Future<LlmSession> openSession(GemmaGenerationConfig config) async => _Session(
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
