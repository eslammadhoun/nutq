import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/features/summarization/domain/entities/local_summary.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Input for one hierarchical merge step.
class MergeRequest {
  const MergeRequest({
    required this.summaries,
    required this.facts,
    required this.evidence,
  });

  final List<LocalSummary> summaries;

  /// Facts from the chunks the summaries cover.
  final List<String> facts;

  /// Bounded source excerpts grounding the merge.
  final List<String> evidence;
}

/// Input for the final synthesis.
class FinalSummaryRequest {
  const FinalSummaryRequest({
    required this.summaries,
    required this.keyFacts,
    required this.entities,
    required this.numbers,
    required this.length,
  });

  final List<LocalSummary> summaries;
  final List<String> keyFacts;
  final List<String> entities;
  final List<String> numbers;
  final SummaryLength length;
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
  /// Token counter backed by the model's tokenizer when available.
  TokenCounter get tokenCounter;

  /// Ensures the model is installed and loaded. Throws
  /// `SummarizationFailure(modelUnavailable)` when it cannot be.
  Future<void> prepare();

  Future<ChunkAnalysis> analyzeChunk(TranscriptChunk chunk);

  Future<String> summarizeChunk(TranscriptChunk chunk);

  Future<String> mergeSummaries(MergeRequest request);

  Future<String> generateFinalSummary(FinalSummaryRequest request);

  /// Usage accumulated since the last [resetStats].
  GenerationStats get stats;

  void resetStats();

  /// Stops any in-flight generation. Safe to call when idle.
  Future<void> cancel();
}
