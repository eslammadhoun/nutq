import 'package:nutq/core/ml/whisper/whisper_engine_event.dart';

/// Abstraction over an on-device whisper.cpp (GGML) speech-to-text engine.
///
/// Kept free of `dart:ffi` types and of any `lib/features/jobs/` import so
/// it stays mockable with `mocktail` and reusable outside the jobs feature.
///
/// ## Cancellation guarantee
///
/// The wrapped package ([WhisperEngineImpl]'s `whisper_ggml`) does not
/// expose a native abort for its one-shot `transcribe()` call — only its
/// *live* (streaming-microphone) session supports `stop()`. So
/// [cancel] here is **cooperative, not preemptive**: calling it sets a flag
/// checked between whisper.cpp invocations. For a single short clip that
/// means cancellation only takes effect once the in-flight `transcribe()`
/// call returns; for long recordings, `AsrPipeline` (see
/// `lib/core/ml/orchestration/asr_pipeline.dart`) drives this engine one
/// ~5-minute chunk at a time specifically so cancellation has a bounded
/// checkpoint to land on, not the whole file. There is no mid-invocation
/// abort — document this limitation to any caller that assumes otherwise.
abstract class WhisperEngine {
  /// Loads [modelPath] (a local ggml `.bin` file) into native memory.
  /// Must be called before [transcribe]. Safe to call again with a
  /// different path to swap models.
  Future<void> loadModel(String modelPath);

  /// Transcribes the audio file at [audioPath] (any format the wrapped
  /// package's internal decoder accepts) in [language] (ISO 639-1, e.g.
  /// `'ar'`). Emits [WhisperEngineEvent.progress]/[WhisperEngineEvent.segment]
  /// while running and a terminal [WhisperEngineEvent.done] or
  /// [WhisperEngineEvent.error]. The stream closes after the terminal event.
  Stream<WhisperEngineEvent> transcribe(String audioPath, {required String language});

  /// Requests cancellation of an in-flight [transcribe] call. See the
  /// class doc comment for the exact guarantee this provides.
  Future<void> cancel();

  /// Releases the loaded model from native memory.
  Future<void> unloadModel();
}
