import 'dart:async';
import 'dart:io' show Platform;

import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:nutq/core/ml/llm/llm_engine.dart';
import 'package:nutq/core/ml/llm/llm_engine_event.dart';

/// [LlmEngine] wrapping `llama_cpp_dart` (pub.dev, prerelease `0.9.0-dev`
/// track — the package's 0.9.x rewrite, published 15 days before this
/// workstream at the time of writing, vs. `fllama`'s single 0.0.1 release
/// from 22 months earlier under an unverified publisher). Chosen because it:
///  - is a Flutter-mobile-first binding — the 0.9.x rewrite's own README
///    states the project "now focuses on one thing: llama.cpp inside a
///    Flutter mobile app", targeting iOS + Android + macOS explicitly
///    (macOS kept only as a dev target);
///  - already runs generation off the UI isolate internally via
///    `LlamaEngine.spawn`'s own worker isolate — see this class's doc
///    comment below on why [LlmEngine] does *not* get its own
///    `WhisperIsolateEngine`-style wrapper on top of that;
///  - streams `TokenEvent`s incrementally (`Stream<GenerationEvent>`),
///    unlike whisper_ggml's one-shot burst-of-segments behavior — real
///    token-by-token output for `SummarizationPipeline` to batch;
///  - exposes cancellation as a first-class Dart idiom (cancelling the
///    stream subscription sends a `CancelCommand` to the worker, observed
///    between decode steps) rather than no abort at all.
///
/// `fllama` was also considered: it does expose `stopCompletion()`, but its
/// only pub.dev release is 22 months old under an "unverified uploader",
/// with no evidence of Gemma-3/current llama.cpp compatibility work landing
/// since. Rejected in favor of the actively-developed `llama_cpp_dart`
/// 0.9.x line.
///
/// ## No custom worker isolate here
///
/// [WhisperEngineImpl] needed [WhisperIsolateEngine] on top of it because
/// `whisper_ggml`'s `transcribe()` call, while internally off-thread per
/// FFI request, has no persistent worker of its own for this app to reuse
/// across calls. `llama_cpp_dart`'s `LlamaEngine.spawn` already *is* that
/// persistent worker isolate — spawned once, reused for every
/// `createSession`/`generate`/dispose call. Wrapping it in a second isolate
/// would just relay messages through an extra hop for no benefit, so
/// [LlmEngineImpl] talks to `LlamaEngine` directly. See
/// `SummarizationPipeline`'s doc comment for how this affects that
/// pipeline's threading story relative to `AsrPipeline`.
class LlmEngineImpl implements LlmEngine {
  LlamaEngine? _engine;
  EngineSession? _session;
  String? _modelPath;
  bool _cancelRequested = false;

  StreamSubscription<GenerationEvent>? _activeSub;
  StreamController<LlmEngineEvent>? _activeController;

  @override
  Future<void> loadModel(String modelPath) async {
    if (_modelPath == modelPath && _engine != null) return;
    await unloadModel();

    // `gpuLayers: 0` (CPU-only) is the conservative default here — there is
    // no simulator/device in this environment to validate Metal/Hexosat
    // GPU-offload numerics or stability for Gemma 3 GGUF, so this ships
    // correct-but-unaccelerated rather than an unverified GPU path. Tuning
    // `gpuLayers` up is a follow-up once real-device profiling is possible.
    final modelParams = ModelParams(path: modelPath, gpuLayers: 0);
    // `.mobile()` is the package's own smaller-footprint preset for
    // phones/tablets; `nCtx` matches `LlmModelSpec.contextLength`.
    final contextParams = ContextParams.mobile(nCtx: 4096, nBatch: 512, nUbatch: 512);

    // Per the package's "Loading the native library" table: iOS/macOS load
    // `llama.xcframework`'s symbols already resident in the host process
    // (once it has been Embed & Signed into the Xcode project — see this
    // repo's `ios/README_llama_cpp_dart.md` for that one-time manual step,
    // which could not be performed in this sandboxed, GUI/Xcode-less,
    // device-less environment), so those platforms use
    // `spawnFromProcess()`. Android bundles `libllama.so` automatically via
    // the package's native-assets build hook and loads it with plain
    // `spawn()` — no native project changes needed on that platform.
    _engine = Platform.isIOS || Platform.isMacOS
        ? await LlamaEngine.spawnFromProcess(modelParams: modelParams, contextParams: contextParams)
        : await LlamaEngine.spawn(modelParams: modelParams, contextParams: contextParams);
    _session = await _engine!.createSession();
    _modelPath = modelPath;
    _cancelRequested = false;
  }

  @override
  Stream<LlmEngineEvent> generate(String prompt, {int? maxTokens}) {
    final session = _session;
    if (session == null) {
      return Stream.value(
        const LlmEngineEvent.error(message: 'generate() called before loadModel()'),
      );
    }
    if (_cancelRequested) {
      return Stream.value(const LlmEngineEvent.error(message: 'cancelled before starting'));
    }

    late final StreamController<LlmEngineEvent> controller;
    controller = StreamController<LlmEngineEvent>(
      onListen: () => _run(controller, session, prompt, maxTokens),
    );
    return controller.stream;
  }

  Future<void> _run(
    StreamController<LlmEngineEvent> controller,
    EngineSession session,
    String prompt,
    int? maxTokens,
  ) async {
    _activeController = controller;
    final buffer = StringBuffer();
    final completer = Completer<void>();

    _activeSub = session
        .generate(prompt: prompt, addSpecial: true, maxTokens: maxTokens ?? 1024)
        .listen(
          (event) {
            switch (event) {
              case TokenEvent(:final text):
                if (text.isNotEmpty) {
                  buffer.write(text);
                  if (!controller.isClosed) controller.add(LlmEngineEvent.token(text: text));
                }
              case ShiftEvent():
                break; // Bookkeeping only — see GenerationEvent.ShiftEvent's doc.
              case DoneEvent():
                break; // Terminal handling happens in onDone below.
            }
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete();
          },
          onError: (Object e) {
            if (!controller.isClosed) controller.add(LlmEngineEvent.error(message: e.toString()));
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: true,
        );

    await completer.future;

    if (!controller.isClosed) {
      controller.add(LlmEngineEvent.done(fullText: buffer.toString()));
      await controller.close();
    }
    _activeSub = null;
    _activeController = null;
  }

  @override
  Future<void> cancel() async {
    // Cooperative at token granularity — see LlmEngine's class doc comment.
    _cancelRequested = true;
    final sub = _activeSub;
    final controller = _activeController;
    _activeSub = null;
    _activeController = null;
    await sub?.cancel();
    if (controller != null && !controller.isClosed) {
      controller.add(const LlmEngineEvent.error(message: 'cancelled'));
      await controller.close();
    }
  }

  @override
  Future<void> unloadModel() async {
    await _session?.dispose();
    await _engine?.dispose();
    _session = null;
    _engine = null;
    _modelPath = null;
  }
}
