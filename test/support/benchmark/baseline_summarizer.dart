import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';
import 'package:nutq/features/summarization/domain/usecases/clean_transcript.dart';
import 'package:nutq/features/summarization/domain/usecases/validate_summary.dart';

/// The measurable baseline the full pipeline must beat (plan §6):
/// transcript → fixed-size word windows → Gemma → concatenated summaries.
/// No sentence awareness, no overlap, no analysis, no merge, no synthesis.
class BaselineSummarizer {
  const BaselineSummarizer(this._repository, {this.wordsPerChunk = 250});

  final SummarizationRepository _repository;
  final int wordsPerChunk;

  Future<SummaryResult> call(String transcript, SummarizationConfig config) async {
    final watch = Stopwatch()..start();
    final cleaned = const CleanTranscript()(transcript);
    await _repository.prepare();
    _repository.resetStats();

    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final parts = <String>[];
    var chunkCount = 0;
    var failed = 0;
    for (var i = 0; i < words.length; i += wordsPerChunk) {
      final text = words
          .sublist(i, i + wordsPerChunk > words.length ? words.length : i + wordsPerChunk)
          .join(' ');
      final chunk = TranscriptChunk(
        id: chunkCount++,
        text: text,
        startSentenceIndex: 0,
        endSentenceIndex: 0,
        tokenCount: 0,
      );
      try {
        parts.add(await _repository.summarizeChunk(chunk));
      } catch (_) {
        failed++;
      }
    }

    final summary = parts.join('\n\n');
    final stats = _repository.stats;
    return SummaryResult(
      summary: summary,
      validation: summary.isEmpty
          ? const ValidationReport()
          : const ValidateSummary()(
              sourceSentences: const SentenceSegmenter().segment(cleaned),
              summary: summary,
            ),
      debug: SummaryDebugInfo(
        jobId: 'baseline',
        chunkCount: chunkCount,
        failedChunkCount: failed,
        processingTimeMs: (watch..stop()).elapsedMilliseconds,
        inputTokens: stats.inputTokens,
        outputTokens: stats.outputTokens,
        generationTimeMs: stats.generationTimeMs,
      ),
    );
  }
}
