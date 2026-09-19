import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/features/summarization/domain/entities/local_summary.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';

class ChunkResult {
  const ChunkResult({required this.analysis, required this.summary});

  final ChunkAnalysis analysis;
  final LocalSummary summary;
}

/// Chunk → analysis → local summary.
///
/// A failed step is recorded, never silently dropped: the summary is marked
/// `failed` and carries the cleaned chunk text as fallback evidence so the
/// merge stage still sees the content. (Retrying once is done by the model
/// data source.)
class SummarizeChunk {
  const SummarizeChunk(this._repository);

  final SummarizationRepository _repository;

  Future<ChunkResult> call(TranscriptChunk chunk, CancellationToken token) async {
    var analysis = ChunkAnalysis(chunkId: chunk.id);
    var analysisFailed = false;
    try {
      analysis = await _repository.analyzeChunk(chunk);
    } on SummarizationCancelledException {
      rethrow;
    } catch (_) {
      analysisFailed = true;
    }
    token.throwIfCancelled();

    try {
      final text = await _repository.summarizeChunk(chunk);
      token.throwIfCancelled();
      if (text.trim().isNotEmpty) {
        return ChunkResult(
          analysis: analysis,
          summary: LocalSummary(chunkIds: [chunk.id], text: text.trim()),
        );
      }
    } on SummarizationCancelledException {
      rethrow;
    } catch (_) {
      // Fall through to the fallback below.
    }
    token.throwIfCancelled();

    // Summary failed. If analysis worked, its MAIN/POINTS are better
    // evidence than raw text; otherwise use the chunk text itself.
    final fallback = !analysisFailed && analysis.main.isNotEmpty
        ? [analysis.main, ...analysis.points].join('\n')
        : chunk.text;
    return ChunkResult(
      analysis: analysis,
      summary: LocalSummary(chunkIds: [chunk.id], text: fallback, failed: true),
    );
  }
}
