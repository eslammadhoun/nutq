import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/features/summarization/domain/entities/local_summary.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/text/evidence_selector.dart';

class MergeOutcome {
  const MergeOutcome({required this.summaries, required this.rounds});

  final List<LocalSummary> summaries;
  final int rounds;
}

/// Hierarchical, evidence-grounded merging: S1+S2→M1, S3+S4→M2, … repeated
/// until at most `maxSummariesBeforeFinal` summaries remain. Never sends all
/// summaries to the model at once.
///
/// Each merge also receives the facts of the chunks it covers and bounded
/// source excerpts, so compression stays grounded in the source.
class MergeSummaries {
  const MergeSummaries(this._repository);

  final SummarizationRepository _repository;

  Future<MergeOutcome> call({
    required List<LocalSummary> summaries,
    required List<ChunkAnalysis> analyses,
    required List<TranscriptChunk> chunks,
    required SummarizationConfig config,
    required CancellationToken token,
    void Function(int mergesDone, int mergesTotal)? onProgress,
  }) async {
    final analysisById = {for (final a in analyses) a.chunkId: a};
    final chunkById = {for (final c in chunks) c.id: c};
    final selector = EvidenceSelector(_repository.tokenCounter);
    final target = config.maxSummariesBeforeFinal < 1 ? 1 : config.maxSummariesBeforeFinal;

    var current = summaries;
    var rounds = 0;
    while (current.length > target) {
      rounds++;
      final next = <LocalSummary>[];
      final mergesTotal = current.length ~/ 2;
      var mergesDone = 0;
      for (var i = 0; i < current.length; i += 2) {
        token.throwIfCancelled();
        if (i + 1 >= current.length) {
          next.add(current[i]); // odd one out carries over unchanged
          continue;
        }
        next.add(
          await _mergePair(
            [current[i], current[i + 1]],
            analysisById,
            chunkById,
            selector,
            config,
          ),
        );
        mergesDone++;
        onProgress?.call(mergesDone, mergesTotal);
      }
      current = next;
    }
    return MergeOutcome(summaries: current, rounds: rounds);
  }

  Future<LocalSummary> _mergePair(
    List<LocalSummary> pair,
    Map<int, ChunkAnalysis> analysisById,
    Map<int, TranscriptChunk> chunkById,
    EvidenceSelector selector,
    SummarizationConfig config,
  ) async {
    final ids = [for (final s in pair) ...s.chunkIds]..sort();
    final facts = <String>[
      for (final id in ids) ...?analysisById[id]?.facts,
    ].take(config.maxFactsPerPrompt).toList();
    final evidence = await selector.select(
      chunks: [for (final id in ids) ?chunkById[id]],
      facts: facts,
      tokenBudget: config.evidenceTokensPerMerge,
    );

    try {
      final merged = await _repository.mergeSummaries(
        MergeRequest(summaries: pair, facts: facts, evidence: evidence),
      );
      if (merged.trim().isNotEmpty) {
        return LocalSummary(chunkIds: ids, text: merged.trim());
      }
    } on SummarizationCancelledException {
      rethrow;
    } catch (_) {
      // Fall back to concatenation below; nothing is dropped.
    }
    return LocalSummary(
      chunkIds: ids,
      text: pair.map((s) => s.text).join('\n\n'),
      failed: pair.any((s) => s.failed),
    );
  }
}
