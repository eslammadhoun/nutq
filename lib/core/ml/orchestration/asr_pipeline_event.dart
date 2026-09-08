import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/network/error/api_error.dart';

part 'asr_pipeline_event.freezed.dart';

/// Event vocabulary emitted by `AsrPipeline.transcribeFile`.
///
/// A small, standalone event type for this ASR-only stub — the full
/// `JobOrchestrator`/`LocalJobProcessor` (a later workstream) maps these
/// onto `JobUpdateEvent`, the same way it maps `WhisperEngineEvent`.
@freezed
sealed class AsrPipelineEvent with _$AsrPipelineEvent {
  /// Coarse progress for the chunk currently transcribing.
  const factory AsrPipelineEvent.progress({
    required int chunkIndex,
    required int chunkTotal,
    required int percent,
  }) = AsrPipelineProgress;

  /// A batched run of newly-transcribed text — coalesced to roughly every
  /// [AsrPipeline.batchWindow] or [AsrPipeline.batchWordCount] words,
  /// whichever comes first, so a UI/consumer isn't flooded with one event
  /// per whisper segment (plan Section 7).
  const factory AsrPipelineEvent.transcriptBatch({required String text}) = AsrPipelineTranscriptBatch;

  /// Terminal — transcription finished successfully.
  const factory AsrPipelineEvent.done({
    required String fullText,
    required int wordCount,
    required Duration duration,
  }) = AsrPipelineDone;

  /// Terminal — pipeline failed (model missing, engine failure, cancelled…).
  const factory AsrPipelineEvent.error({required ApiError error}) = AsrPipelineError;
}
