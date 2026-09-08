import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';

part 'summarization_pipeline_event.freezed.dart';

/// Event vocabulary emitted by `SummarizationPipeline.summarize` — mirrors
/// `AsrPipelineEvent`'s shape (batched content events + one terminal event)
/// for the LLM side of on-device inference.
@freezed
sealed class SummarizationPipelineEvent with _$SummarizationPipelineEvent {
  /// A batched run of newly-generated summary text — coalesced to roughly
  /// every [SummarizationPipeline.batchWindow] or
  /// [SummarizationPipeline.batchWordCount] words, whichever comes first,
  /// matching `AsrPipeline`'s coalescing cadence.
  const factory SummarizationPipelineEvent.textBatch({required String text}) =
      SummarizationPipelineTextBatch;

  /// Terminal — summarization finished successfully; [summary] is the
  /// parsed structured result.
  const factory SummarizationPipelineEvent.done({required Summary summary}) =
      SummarizationPipelineDone;

  /// Terminal — pipeline failed (model missing, engine failure, cancelled…).
  const factory SummarizationPipelineEvent.error({required ApiError error}) =
      SummarizationPipelineError;
}
