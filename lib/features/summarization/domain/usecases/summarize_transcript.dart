import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/features/summarization/domain/entities/local_summary.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/aggregate_key_facts.dart';
import 'package:nutq/features/summarization/domain/usecases/chunk_transcript.dart';
import 'package:nutq/features/summarization/domain/usecases/clean_transcript.dart';
import 'package:nutq/features/summarization/domain/usecases/merge_summaries.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_chunk.dart';
import 'package:nutq/features/summarization/domain/usecases/validate_summary.dart';

/// An event on the stream returned by [SummarizeTranscript.stream].
sealed class SummarizationUpdate {
  const SummarizationUpdate();
}

class SummarizationProgressUpdate extends SummarizationUpdate {
  const SummarizationProgressUpdate(this.progress);

  final SummarizationProgress progress;
}

/// The final summary as generated so far (accumulated text, word by word).
class SummarizationPartialSummaryUpdate extends SummarizationUpdate {
  const SummarizationPartialSummaryUpdate(this.text);

  final String text;
}

class SummarizationCompletedUpdate extends SummarizationUpdate {
  const SummarizationCompletedUpdate(this.result);

  final SummaryResult result;
}

/// The complete pipeline:
/// clean → segment → chunk → (analyze + summarize) per chunk → aggregate
/// facts → hierarchical merge → final synthesis → validation.
class SummarizeTranscript {
  const SummarizeTranscript({
    required this.repository,
    this.cleanTranscript = const CleanTranscript(),
    this.chunkTranscript = const ChunkTranscript(),
    this.aggregateKeyFacts = const AggregateKeyFacts(),
    this.validateSummary = const ValidateSummary(),
  });

  final SummarizationRepository repository;
  final CleanTranscript cleanTranscript;
  final ChunkTranscript chunkTranscript;
  final AggregateKeyFacts aggregateKeyFacts;
  final ValidateSummary validateSummary;

  static const _maxKeyPoints = 5;
  static const _maxImportantFacts = 8;

  /// Throws [SummarizationFailure] or [SummarizationCancelledException].
  Future<SummaryResult> call(
    String transcript,
    SummarizationConfig config, {
    CancellationToken? cancellation,
    void Function(SummarizationProgress progress)? onProgress,
    void Function(String partialSummary)? onPartialSummary,
  }) async {
    final token = cancellation ?? CancellationToken();
    final watch = Stopwatch()..start();
    final jobId = _newJobId();
    void report(SummarizationStage stage, [int? done, int? total]) {
      onProgress?.call(
        SummarizationProgress(stage, processedChunks: done, totalChunks: total),
      );
    }

    void log(String message) {
      if (config.debugLogging) debugPrint('[summarization:$jobId] $message');
    }

    report(SummarizationStage.preparing);
    final cleaned = cleanTranscript(transcript);
    if (cleaned.isEmpty) {
      throw const SummarizationFailure(SummarizationFailureKind.emptyTranscript);
    }
    await repository.prepare();
    token.throwIfCancelled();
    repository.resetStats();

    final prepared = await chunkTranscript(cleaned, config, repository.tokenCounter);
    final chunks = prepared.chunks;
    log('chunks=${chunks.length} chars=${cleaned.length}');
    token.throwIfCancelled();

    final analyses = <ChunkAnalysis>[];
    final summaries = <LocalSummary>[];
    var failedChunks = 0;
    for (var i = 0; i < chunks.length; i++) {
      token.throwIfCancelled();
      report(SummarizationStage.analyzing, i, chunks.length);
      final result = await SummarizeChunk(repository)(
        chunks[i],
        token,
        language: config.language,
      );
      analyses.add(result.analysis);
      summaries.add(result.summary);
      if (result.summary.failed) failedChunks++;
      report(SummarizationStage.summarizing, i + 1, chunks.length);
    }
    log('failedChunks=$failedChunks');

    final keyFacts = aggregateKeyFacts(analyses);

    report(SummarizationStage.combining, chunks.length, chunks.length);
    final merged = await MergeSummaries(repository)(
      summaries: summaries,
      analyses: analyses,
      chunks: chunks,
      config: config,
      token: token,
    );
    log('mergeRounds=${merged.rounds}');

    report(SummarizationStage.finalizing);
    token.throwIfCancelled();
    final String finalText;
    try {
      finalText = await repository.generateFinalSummary(
        FinalSummaryRequest(
          summaries: merged.summaries,
          keyFacts: keyFacts.facts.take(config.maxFactsPerPrompt).toList(),
          entities: keyFacts.entities,
          numbers: keyFacts.numbers,
          length: config.length,
          language: config.language,
        ),
        onPartial: onPartialSummary,
      );
    } on SummarizationCancelledException {
      rethrow;
    } catch (e) {
      throw SummarizationFailure(SummarizationFailureKind.generationFailed, '$e');
    }
    token.throwIfCancelled();
    if (finalText.trim().isEmpty) {
      throw const SummarizationFailure(SummarizationFailureKind.generationFailed, 'empty summary');
    }

    report(SummarizationStage.checking);
    final validation = validateSummary(
      sourceSentences: prepared.sentences,
      summary: finalText,
    );
    log('validationIssues=${validation.issues.length}');

    final stats = repository.stats;
    watch.stop();
    report(SummarizationStage.completed, chunks.length, chunks.length);
    return SummaryResult(
      summary: finalText.trim(),
      keyPoints: keyFacts.mainIdeas.take(_maxKeyPoints).toList(),
      importantFacts: keyFacts.facts.take(_maxImportantFacts).toList(),
      validation: validation,
      debug: SummaryDebugInfo(
        jobId: jobId,
        chunkCount: chunks.length,
        failedChunkCount: failedChunks,
        processingTimeMs: watch.elapsedMilliseconds,
        inputTokens: stats.inputTokens,
        outputTokens: stats.outputTokens,
        generationTimeMs: stats.generationTimeMs,
        mergeRounds: merged.rounds,
      ),
    );
  }

  /// Runs the pipeline and streams progress as it happens, ending with one
  /// [SummarizationCompletedUpdate]. Failures arrive as stream errors
  /// ([SummarizationFailure] / [SummarizationCancelledException]). Cancelling
  /// the subscription cancels the job.
  Stream<SummarizationUpdate> stream(
    String transcript,
    SummarizationConfig config, {
    CancellationToken? cancellation,
  }) {
    final token = cancellation ?? CancellationToken();
    late final StreamController<SummarizationUpdate> controller;
    controller = StreamController<SummarizationUpdate>(
      onListen: () async {
        try {
          final result = await call(
            transcript,
            config,
            cancellation: token,
            onProgress: (p) {
              if (!controller.isClosed) controller.add(SummarizationProgressUpdate(p));
            },
            onPartialSummary: (text) {
              if (!controller.isClosed) controller.add(SummarizationPartialSummaryUpdate(text));
            },
          );
          if (!controller.isClosed) controller.add(SummarizationCompletedUpdate(result));
        } catch (e, st) {
          if (!controller.isClosed) controller.addError(e, st);
        } finally {
          if (!controller.isClosed) await controller.close();
        }
      },
      onCancel: token.cancel,
    );
    return controller.stream;
  }

  static String _newJobId() {
    final rng = Random();
    return '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
        '${rng.nextInt(1 << 20).toRadixString(36)}';
  }
}
