import 'dart:async';

import 'package:nutq/core/ml/whisper/whisper_engine.dart';
import 'package:nutq/core/ml/whisper/whisper_engine_event.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

/// [WhisperEngine] wrapping `whisper_ggml` (pub.dev, actively maintained —
/// last published 35 days before this workstream, vs. `whisper_flutter_new`
/// which hasn't shipped in ~2 years and doesn't document iOS+Android
/// parity). Chosen because it:
///  - covers both iOS (15.6+) and Android (API 21+) from one package;
///  - runs every native call off the UI isolate internally (`Isolate.run`
///    per FFI request — see the package's `Whisper._request`), so the Dart
///    UI thread never blocks on inference;
///  - decodes arbitrary input audio formats itself (bundles
///    `ffmpeg_kit_flutter_new_min`, converting to 16 kHz mono PCM before
///    handing off to whisper.cpp) — no separate `AudioPreprocessor` needed
///    in this codebase, see `lib/core/ml/audio/` (empty by design, see its
///    README-equivalent doc comment below) for that decision;
///  - supports `keepModelLoaded` to park the model in native memory across
///    calls, avoiding a multi-second reload per chunk.
///
/// It does **not** expose incremental streaming or a native abort for its
/// one-shot `transcribe()` call (only its separate live-microphone session
/// API has `stop()`, which doesn't apply to file transcription). See
/// [WhisperEngine]'s class doc for the resulting cancellation guarantee.
/// [WhisperEngineEvent.segment]s are therefore delivered in a burst once
/// the underlying call returns — true incremental streaming, and
/// chunk-boundary cancellation, come from `AsrPipeline` driving this engine
/// one ~5-minute chunk at a time (see
/// `lib/core/ml/orchestration/asr_pipeline.dart`), not from this class.
class WhisperEngineImpl implements WhisperEngine {
  String? _modelPath;
  bool _cancelRequested = false;

  @override
  Future<void> loadModel(String modelPath) async {
    // whisper_ggml has no separate "load" call — the model loads (and,
    // with `keepModelLoaded: true`, stays resident) on the first
    // `transcribe()` invocation. Just remember the path; the actual native
    // load happens lazily on the first `transcribe()` call below.
    _modelPath = modelPath;
    _cancelRequested = false;
  }

  @override
  Stream<WhisperEngineEvent> transcribe(String audioPath, {required String language}) {
    final modelPath = _modelPath;
    if (modelPath == null) {
      return Stream.value(
        const WhisperEngineEvent.error(message: 'transcribe() called before loadModel()'),
      );
    }

    late final StreamController<WhisperEngineEvent> controller;
    controller = StreamController<WhisperEngineEvent>(
      onListen: () => _run(controller, modelPath: modelPath, audioPath: audioPath, language: language),
    );
    return controller.stream;
  }

  Future<void> _run(
    StreamController<WhisperEngineEvent> controller, {
    required String modelPath,
    required String audioPath,
    required String language,
  }) async {
    if (_cancelRequested) {
      controller
        ..add(const WhisperEngineEvent.error(message: 'cancelled before starting'))
        ..close();
      return;
    }

    try {
      // `model` only picks the enum's display name for internal package
      // bookkeeping — the actual weights come from `modelPath` below, so
      // any tier value is safe here.
      final whisper = Whisper(model: WhisperModel.small);
      final response = await whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          language: language,
          isNoTimestamps: false,
          splitOnWord: true,
          keepModelLoaded: true,
        ),
        modelPath: modelPath,
        onProgress: (percent) {
          if (!controller.isClosed) {
            controller.add(WhisperEngineEvent.progress(percent: percent));
          }
        },
      );

      if (_cancelRequested) {
        controller.add(const WhisperEngineEvent.error(message: 'cancelled'));
        await controller.close();
        return;
      }

      for (final segment in response.segments ?? const []) {
        controller.add(
          WhisperEngineEvent.segment(text: segment.text, start: segment.fromTs, end: segment.toTs),
        );
      }
      controller.add(WhisperEngineEvent.done(fullText: response.text));
      await controller.close();
    } catch (e) {
      controller.add(WhisperEngineEvent.error(message: e.toString()));
      await controller.close();
    }
  }

  @override
  Future<void> cancel() async {
    // Cooperative-only — see class doc comment. Takes effect at the next
    // checkpoint (before a not-yet-started call, or before this engine's
    // caller issues the next chunk).
    _cancelRequested = true;
  }

  @override
  Future<void> unloadModel() async {
    _modelPath = null;
    await const Whisper(model: WhisperModel.tiny).releaseModel();
  }
}
