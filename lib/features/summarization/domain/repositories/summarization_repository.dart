import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/features/summarization/domain/entities/local_summary.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Input for one hierarchical merge step.
class MergeRequest {
  const MergeRequest({
    required this.summaries,
    required this.facts,
    required this.evidence,
    this.language = ContentLanguage.ar,
  });

  final List<LocalSummary> summaries;

  /// Facts from the chunks the summaries cover.
  final List<String> facts;

  /// Bounded source excerpts grounding the merge.
  final List<String> evidence;
  final ContentLanguage language;
}

/// Input for the final synthesis.
class FinalSummaryRequest {
  const FinalSummaryRequest({
    required this.summaries,
    required this.keyFacts,
    required this.entities,
    required this.numbers,
    required this.length,
    this.language = ContentLanguage.ar,
  });

  final List<LocalSummary> summaries;
  final List<String> keyFacts;
  final List<String> entities;
  final List<String> numbers;
  final SummaryLength length;
  final ContentLanguage language;
}

/// Cumulative model usage for one summarization job.
class GenerationStats {
  const GenerationStats({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.generationTimeMs = 0,
    this.calls = 0,
  });

  final int inputTokens;
  final int outputTokens;
  final int generationTimeMs;
  final int calls;

  GenerationStats operator +(GenerationStats other) => GenerationStats(
    inputTokens: inputTokens + other.inputTokens,
    outputTokens: outputTokens + other.outputTokens,
    generationTimeMs: generationTimeMs + other.generationTimeMs,
    calls: calls + other.calls,
  );
}

/// Everything the pipeline needs from the model, without exposing prompts,
/// the Gemma runtime, or response parsing to the domain layer.
abstract class SummarizationRepository {
  /// Identifies the model that produces summaries (stored with each result).
  String get modelId;

  /// Identifies the prompt templates in use.
  String get promptVersion;

  /// Token counter backed by the model's tokenizer when available.
  TokenCounter get tokenCounter;

  /// Ensures the model is installed and loaded. Throws
  /// `SummarizationFailure(modelUnavailable)` when it cannot be.
  Future<void> prepare();

  Future<ChunkAnalysis> analyzeChunk(
    TranscriptChunk chunk, {
    ContentLanguage language = ContentLanguage.ar,
  });

  Future<String> summarizeChunk(
    TranscriptChunk chunk, {
    ContentLanguage language = ContentLanguage.ar,
  });

  Future<String> mergeSummaries(MergeRequest request);

  /// [onPartial] receives the summary text accumulated so far, as the model
  /// generates it (word by word); the returned string is the final text.
  Future<String> generateFinalSummary(
    FinalSummaryRequest request, {
    void Function(String partialText)? onPartial,
  });

  /// Usage accumulated since the last [resetStats].
  GenerationStats get stats;

  void resetStats();

  /// Stops any in-flight generation. Safe to call when idle.
  Future<void> cancel();

  /// Unloads the model to free memory. The next job reloads it on demand.
  Future<void> release();
}
