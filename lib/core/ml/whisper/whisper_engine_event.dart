import 'package:freezed_annotation/freezed_annotation.dart';

part 'whisper_engine_event.freezed.dart';

/// Event vocabulary emitted by [WhisperEngine.transcribe].
///
/// Deliberately independent of `lib/features/jobs/domain/entities/
/// job_update_event.dart` — `lib/core/ml/` must stay free of `jobs` feature
/// imports so it remains a reusable engine layer. A later workstream
/// (`JobOrchestrator`/`LocalJobProcessor`) maps these onto
/// `JobUpdateEvent.transcriptWord`/`transcriptDone`.
@freezed
sealed class WhisperEngineEvent with _$WhisperEngineEvent {
  /// Coarse 0–100 progress within the current unit of work (a single chunk
  /// when the engine is driven by the chunking orchestrator, or the whole
  /// file otherwise).
  const factory WhisperEngineEvent.progress({required int percent}) = WhisperEngineProgress;

  /// One transcribed segment. Granularity depends on what the wrapped
  /// package actually produced: word-level when the engine requested
  /// word-split segments, phrase-level otherwise (see
  /// [WhisperEngineImpl] doc comment for the concrete guarantee).
  const factory WhisperEngineEvent.segment({
    required String text,
    required Duration start,
    required Duration end,
  }) = WhisperEngineSegment;

  /// Transcription finished successfully.
  const factory WhisperEngineEvent.done({required String fullText}) = WhisperEngineDone;

  /// Transcription failed.
  const factory WhisperEngineEvent.error({required String message}) = WhisperEngineError;
}
