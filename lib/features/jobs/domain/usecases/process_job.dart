import 'dart:async';

import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source_registry.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
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

/// Runs one stored `pending` job to a final state and records every outcome,
/// so the database always reflects the job's real state:
///
/// 1. **Resolve** the transcript with the job's [TranscriptSource] (pasted text
///    is instant; media and YouTube sources fetch and transcribe).
/// 2. **Summarize** it in the job's summary language and length.
///
/// Outcomes: success → `completed` with the summary saved atomically; a
/// [JobFailure] or a pipeline failure → `failed` with the reason; cancellation
/// (explicit, or the event subscription cancelled) → `cancelled`.
class ProcessJob {
  const ProcessJob({
    required this._jobs,
    required this._sources,
    required this._summarize,
    required this._summarization,
    this._config = const SummarizationConfig(),
  });

  final JobsRepository _jobs;
  final TranscriptSourceRegistry _sources;
  final SummarizeTranscript _summarize;
  final SummarizationRepository _summarization;
  final SummarizationConfig _config;

  JobRun call(String jobId) {
    final token = CancellationToken();
    return JobRun._(_events(jobId, token), () async {
      token.cancel();
      await _summarization.cancel();
    });
  }

  Stream<JobRunEvent> _events(String jobId, CancellationToken token) {
    late final StreamController<JobRunEvent> controller;

    // True while this run has no outcome left to record: before it owns the
    // job, and after the job reached a final state.
    var settled = true;
    var listenerGone = false;

    // The bar never goes backwards, however a source reports its phases.
    var highestFraction = 0.0;

    void emit(JobRunEvent event) {
      if (controller.isClosed || listenerGone) return;
      if (event is JobRunProgress) {
        final p = event.progress;
        if (p.fraction < highestFraction) {
          controller.add(
            JobRunProgress(JobProgress(p.stage, fraction: highestFraction, done: p.done, total: p.total)),
          );
          return;
        }
        highestFraction = p.fraction;
      }
      controller.add(event);
    }

    Future<void> settle(Future<void> Function() write) async {
      settled = true;
      try {
        await write();
      } on JobNotFoundException {
        // Deleted while running — nothing left to record.
      } on InvalidJobTransitionException {
        // Already in a final state.
      } on JobStorageException {
        // Best effort; startup recovery fails a job that stays active.
      }
    }

    Future<void> body() async {
      try {
        final job = await _jobs.getJob(jobId);
        if (job == null) {
          controller.addError(JobNotFoundException(jobId));
          return;
        }
        if (job.status != JobRunStatus.pending) return;

        await _jobs.markRunning(jobId);
        settled = false; // this run now owns the job's outcome
        emit(const JobRunProgress(JobProgress(JobStage.preparing, fraction: 0.01)));

        final source = _sources.of(job.sourceType);
        if (source == null) {
          throw JobFailure(
            JobFailureKind.unsupportedMedia,
            'no source registered for ${job.sourceType.name}',
          );
        }

        final resolved = await source.resolve(
          SourceRequest(
            job: job,
            cancellation: token,
            onProgress: (p) => emit(JobRunProgress(_scaled(p, source.progressShare))),
            saveSourceInfo: (info) => _jobs.updateSourceInfo(jobId, info),
          ),
        );
        token.throwIfCancelled();

        final text = resolved.text.trim();
        if (text.isEmpty) throw const JobFailure(JobFailureKind.emptyTranscript);
        if (job.transcript?.text != text) {
          await _jobs.saveTranscript(
            jobId,
            Transcript(
              text: text,
              wordCount: text.split(RegExp(r'\s+')).length,
              modelName: resolved.modelName,
              modelVersion: resolved.modelVersion,
            ),
          );
        }

        final updates = _summarize.stream(
          text,
          _config.copyWith(language: job.summaryLanguage, length: job.requestedLength),
          cancellation: token,
        );
        await for (final update in updates) {
          switch (update) {
            case SummarizationProgressUpdate(:final progress):
              emit(JobRunProgress(_toJobProgress(progress, source.progressShare)));
            case SummarizationPartialSummaryUpdate(:final text):
              emit(JobRunPartialSummary(text));
            case SummarizationCompletedUpdate(:final result):
              await _jobs.completeJob(jobId, _toSummary(job, result));
              settled = true;
          }
        }
      } on CancelledException {
        await settle(() => _jobs.cancelJob(jobId));
      } on JobFailure catch (failure) {
        await settle(() => _jobs.failJob(jobId, failure.kind));
      } on SummarizationFailure catch (failure) {
        await settle(() => _jobs.failJob(jobId, _toJobFailure(failure.kind)));
      } on InvalidJobTransitionException {
        // Someone else owns this job (it is no longer pending): leave it alone.
      } on JobStorageException catch (e, st) {
        // Could not save something: record the failure if we still can, then
        // let the caller see the storage error.
        await settle(() => _jobs.failJob(jobId, JobFailureKind.generationFailed));
        if (!controller.isClosed) controller.addError(e, st);
      } catch (_) {
        await settle(() => _jobs.failJob(jobId, JobFailureKind.generationFailed));
      } finally {
        if (!settled) {
          // The listener left mid-run: stop the model and record it.
          token.cancel();
          await _summarization.cancel();
          await settle(() => _jobs.cancelJob(jobId));
        }
        if (!controller.isClosed) await controller.close();
      }
    }

    controller = StreamController<JobRunEvent>(
      onListen: () => unawaited(body()),
      onCancel: () async {
        listenerGone = true;
        if (!settled) {
          token.cancel();
          await _summarization.cancel();
        }
      },
    );
    return controller.stream;
  }

  /// A source's own progress (0–1 within its work) placed on the whole bar.
  static JobProgress _scaled(JobProgress p, double share) => JobProgress(
    p.stage,
    fraction: (p.fraction.clamp(0.0, 1.0) * share).clamp(0.0, 1.0),
    done: p.done,
    total: p.total,
  );

  /// Summarization progress placed after the source's share of the bar.
  static JobProgress _toJobProgress(SummarizationProgress p, double share) => JobProgress(
    switch (p.stage) {
      SummarizationStage.preparing => JobStage.preparing,
      SummarizationStage.analyzing => JobStage.analyzing,
      SummarizationStage.summarizing => JobStage.summarizing,
      SummarizationStage.combining => JobStage.combining,
      SummarizationStage.checking => JobStage.checking,
      SummarizationStage.finalizing => JobStage.finalizing,
      SummarizationStage.completed => JobStage.completed,
    },
    fraction: share + (1 - share) * p.fraction,
    done: p.processedChunks,
    total: p.totalChunks,
  );

  static JobFailureKind _toJobFailure(SummarizationFailureKind kind) => switch (kind) {
    SummarizationFailureKind.emptyTranscript => JobFailureKind.emptyTranscript,
    SummarizationFailureKind.modelUnavailable => JobFailureKind.modelUnavailable,
    SummarizationFailureKind.generationFailed => JobFailureKind.generationFailed,
    SummarizationFailureKind.interrupted => JobFailureKind.interrupted,
  };

  Summary _toSummary(JobDetailEntity job, SummaryResult result) => Summary(
    summaryText: result.summary,
    length: job.requestedLength,
    takeaways: List.unmodifiable(result.keyPoints),
    modelName: _summarization.modelId,
    promptVersion: _summarization.promptVersion,
    needsReview: result.validation.isSuspicious,
    tokensIn: result.debug.inputTokens,
    tokensOut: result.debug.outputTokens,
    processingTimeMs: result.debug.processingTimeMs,
  );
}
