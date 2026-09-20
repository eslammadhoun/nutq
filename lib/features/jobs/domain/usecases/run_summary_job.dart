import 'dart:async';

import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

/// Live, in-memory events of a running job. Durable outcomes (running,
/// completed, failed, cancelled) are written to the repository instead and
/// reach the UI through `JobsRepository.watchJob`.
sealed class JobRunEvent {
  const JobRunEvent();
}

class JobRunProgress extends JobRunEvent {
  const JobRunProgress(this.progress);

  final JobProgress progress;
}

/// The final summary as generated so far.
class JobRunPartialSummary extends JobRunEvent {
  const JobRunPartialSummary(this.text);

  final String text;
}

/// A started run: its events, and a way to stop it.
class JobRun {
  const JobRun._(this.events, this._cancel);

  /// Single-subscription; the job starts when this is listened to. Cancelling
  /// the subscription cancels the job.
  final Stream<JobRunEvent> events;
  final Future<void> Function() _cancel;

  Future<void> cancel() => _cancel();
}

/// Runs a stored `pending` job through the summarization pipeline and records
/// every outcome, so the database always reflects the job's real state:
///
/// - success → `completed` with the summary saved atomically
/// - pipeline failure → `failed` with the failure kind
/// - cancellation (explicit, or the event subscription cancelled) → `cancelled`
class RunSummaryJob {
  const RunSummaryJob({
    required this._jobs,
    required this._summarize,
    required this._summarization,
    this._config = const SummarizationConfig(),
  });

  final JobsRepository _jobs;
  final SummarizeTranscript _summarize;
  final SummarizationRepository _summarization;
  final SummarizationConfig _config;

  JobRun call(String jobId) {
    final token = CancellationToken();
    return JobRun._(_run(jobId, token), () async {
      token.cancel();
      await _summarization.cancel();
    });
  }

  Stream<JobRunEvent> _run(String jobId, CancellationToken token) async* {
    final job = await _jobs.getJob(jobId);
    if (job == null) throw JobNotFoundException(jobId);
    final transcript = job.transcript;
    if (job.status != JobRunStatus.pending || transcript == null) return;

    await _jobs.markRunning(jobId);

    var settled = false;
    try {
      final updates = _summarize.stream(
        transcript.text,
        _config.copyWith(language: job.summaryLanguage, length: job.requestedLength),
        cancellation: token,
      );
      await for (final update in updates) {
        switch (update) {
          case SummarizationProgressUpdate(:final progress):
            yield JobRunProgress(_toJobProgress(progress));
          case SummarizationPartialSummaryUpdate(:final text):
            yield JobRunPartialSummary(text);
          case SummarizationCompletedUpdate(:final result):
            await _jobs.completeJob(jobId, _toSummary(job.requestedLength, result));
            settled = true;
        }
      }
    } on CancelledException {
      await _settle(() => _jobs.cancelJob(jobId));
      settled = true;
    } on SummarizationFailure catch (failure) {
      await _settle(() => _jobs.failJob(jobId, _toJobFailure(failure.kind)));
      settled = true;
    } on JobStorageException {
      // Could not save the result: record the failure if we still can, then
      // let the caller see the storage error.
      await _settle(
        () => _jobs.failJob(jobId, JobFailureKind.generationFailed),
      );
      settled = true;
      rethrow;
    } catch (_) {
      await _settle(
        () => _jobs.failJob(jobId, JobFailureKind.generationFailed),
      );
      settled = true;
    } finally {
      if (!settled) {
        // The consumer stopped listening mid-run: stop the model and record it.
        token.cancel();
        await _summarization.cancel();
        await _settle(() => _jobs.cancelJob(jobId));
      }
    }
  }

  /// Runs a bookkeeping write that may legitimately no-op (job deleted or
  /// already settled) or fail; never throws.
  Future<void> _settle(Future<void> Function() write) async {
    try {
      await write();
    } on JobNotFoundException {
      // Deleted while running — nothing left to record.
    } on InvalidJobTransitionException {
      // Already in a final state.
    } on JobStorageException {
      // Best effort; startup recovery will fail the job if it stays active.
    }
  }

  Summary _toSummary(SummaryLength length, SummaryResult result) => Summary(
    summaryText: result.summary,
    length: length,
    takeaways: List.unmodifiable(result.keyPoints),
    modelName: _summarization.modelId,
    promptVersion: _summarization.promptVersion,
    needsReview: result.validation.isSuspicious,
    tokensIn: result.debug.inputTokens,
    tokensOut: result.debug.outputTokens,
    processingTimeMs: result.debug.processingTimeMs,
  );

  static JobProgress _toJobProgress(SummarizationProgress p) => JobProgress(
    switch (p.stage) {
      SummarizationStage.preparing => JobStage.preparing,
      SummarizationStage.analyzing => JobStage.analyzing,
      SummarizationStage.summarizing => JobStage.summarizing,
      SummarizationStage.combining => JobStage.combining,
      SummarizationStage.checking => JobStage.checking,
      SummarizationStage.finalizing => JobStage.finalizing,
      SummarizationStage.completed => JobStage.completed,
    },
    fraction: p.fraction,
    done: p.processedChunks,
    total: p.totalChunks,
  );

  static JobFailureKind _toJobFailure(SummarizationFailureKind kind) => switch (kind) {
    SummarizationFailureKind.emptyTranscript => JobFailureKind.emptyTranscript,
    SummarizationFailureKind.modelUnavailable => JobFailureKind.modelUnavailable,
    SummarizationFailureKind.generationFailed => JobFailureKind.generationFailed,
    SummarizationFailureKind.interrupted => JobFailureKind.interrupted,
  };
}
