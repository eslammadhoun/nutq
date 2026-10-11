import 'dart:async';
import 'dart:math' as math;

import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/foreground_gate.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/services/background_job.dart';
import 'package:nutq/features/jobs/domain/services/job_estimate.dart';
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

/// The transcript as recognized so far, while a media source transcribes.
class JobRunPartialTranscript extends JobRunEvent {
  const JobRunPartialTranscript(this.text);

  final String text;
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
    this._foreground = const AlwaysInForeground(),
    this._background = const NoBackgroundJob(),
    this._rates,
  });

  final JobsRepository _jobs;
  final TranscriptSourceRegistry _sources;
  final SummarizeTranscript _summarize;
  final SummarizationRepository _summarization;
  final SummarizationConfig _config;
  final ForegroundGate _foreground;

  /// Shows a media job on the lock screen and keeps it running outside the
  /// app. Pasted text is summarized only while the app is open, so it is
  /// never shown there.
  final BackgroundJob _background;

  /// This device's measured speeds, which the progress bar is estimated from
  /// and which every finished step updates. Null uses the defaults and learns
  /// nothing.
  final JobRatesStore? _rates;

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
    // When the time estimate grows, the work left is spread over the rest of
    // the bar from where it stands (an anchor), rather than holding the bar
    // still until the new estimate catches up: on a long job that froze it for
    // many minutes. A source's own dips (a phase restarting its count) just
    // hold the bar, as before.
    var highestFraction = 0.0;
    var anchorRaw = 0.0;
    var anchorShown = 0.0;
    var estimateChanged = false;

    double shown(double raw) {
      final value = raw <= anchorRaw || anchorRaw >= 1
          ? anchorShown
          : anchorShown + (raw - anchorRaw) * (1 - anchorShown) / (1 - anchorRaw);
      // A new estimate applies from the next value on: re-anchor there if it
      // would pull the bar back.
      if (value < highestFraction && estimateChanged) {
        anchorRaw = raw;
        anchorShown = highestFraction;
      }
      estimateChanged = false;
      return math.max(value, highestFraction).clamp(0.0, 1.0);
    }

    // Set once the job is known: where progress is also shown outside the app,
    // and the plan the lock-screen timeline is drawn from.
    BackgroundJob background = const NoBackgroundJob();
    JobPlan? plan;
    var shownPercent = -1;
    Duration? shownTotal;

    void showOutside(double fraction) {
      final percent = (fraction * 100).floor();
      final total = plan != null && plan!.isKnown ? plan!.total : null;
      if (percent == shownPercent && total == shownTotal) return;
      shownPercent = percent;
      shownTotal = total;
      unawaited(background.update(progress: fraction, estimatedTotal: total));
    }

    void emit(JobRunEvent event) {
      if (controller.isClosed || listenerGone) return;
      if (event is JobRunProgress) {
        final p = event.progress;
        final fraction = shown(p.fraction);
        final moved = fraction > highestFraction;
        highestFraction = fraction;
        if (moved) showOutside(fraction);
        controller.add(
          JobRunProgress(JobProgress(p.stage, fraction: fraction, done: p.done, total: p.total)),
        );
        return;
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

    StreamSubscription<BackgroundJobCommand>? cancelButton;

    Future<void> body() async {
      var completed = false;
      try {
        final job = await _jobs.getJob(jobId);
        if (job == null) {
          controller.addError(JobNotFoundException(jobId));
          return;
        }
        if (job.status != JobRunStatus.pending) return;

        await _jobs.markRunning(jobId);
        settled = false; // this run now owns the job's outcome

        final source = _sources.of(job.sourceType);
        if (source == null) {
          throw JobFailure(
            JobFailureKind.unsupportedMedia,
            'no source registered for ${job.sourceType.name}',
          );
        }

        var rates = _rates?.load() ?? const JobRates();
        final summaryConfig = _config.copyWith(
          language: job.summaryLanguage,
          length: job.requestedLength,
        );
        final jobPlan = plan = JobPlan(
          rates: rates,
          summaryRatio: summaryConfig.summaryRatio,
          transcriptWords: source.progressShare == 0 ? _wordCount(job.transcript?.text) : null,
        );
        if (source.progressShare > 0) {
          background = _background;
          // Android's notification has a Cancel button.
          cancelButton = background.commands.where((c) => c == BackgroundJobCommand.cancel).listen((
            _,
          ) {
            token.cancel();
            unawaited(_summarization.cancel());
          });
          await background.begin(title: job.sourceTitle ?? job.sourceType.name);
          // The summarizer may still be loaded from the job before (it is freed
          // only after two idle minutes). Free it now: speech recognition then
          // has the phone's memory to itself, instead of iOS compressing
          // memory, which costs CPU and heat, under a 579 MB model it will not
          // need for many minutes. It reloads in seconds when the summary
          // starts.
          await _summarization.release();
        }
        emit(const JobRunProgress(JobProgress(JobStage.preparing, fraction: 0.01)));

        Duration? audio;
        final sourceWatch = Stopwatch()..start();
        final resolved = await source.resolve(
          SourceRequest(
            job: job,
            cancellation: token,
            onPartialTranscript: (text) => emit(JobRunPartialTranscript(text)),
            // Until a media job's audio length is known, its share of the bar
            // is the source's own guess.
            onProgress: (p) => emit(
              JobRunProgress(
                jobPlan.isKnown
                    ? JobProgress(
                        p.stage,
                        fraction: jobPlan.duringSource(p.fraction),
                        done: p.done,
                        total: p.total,
                      )
                    : _scaled(p, source.progressShare),
              ),
            ),
            saveSourceInfo: (info) async {
              final seconds = info.durationSeconds;
              if (seconds != null && source.transcribesAudio) {
                jobPlan.audio = audio = Duration(milliseconds: (seconds * 1000).round());
                estimateChanged = true;
              }
              await _jobs.updateSourceInfo(jobId, info);
            },
          ),
        );
        token.throwIfCancelled();

        final text = resolved.text.trim();
        if (text.isEmpty) throw const JobFailure(JobFailureKind.emptyTranscript);
        final words = _wordCount(text);
        jobPlan.transcriptWords = words;
        estimateChanged = true;
        if (audio != null) {
          rates = rates.afterTranscription(
            audio: audio!,
            elapsed: sourceWatch.elapsed,
            words: words,
          );
          await _rates?.save(rates);
        }
        if (job.transcript?.text != text) {
          await _jobs.saveTranscript(
            jobId,
            Transcript(
              text: text,
              wordCount: words,
              modelName: resolved.modelName,
              modelVersion: resolved.modelVersion,
            ),
          );
        }

        // A transcription can finish while the app is in the background, where
        // iOS refuses GPU work; summarize once the user is back.
        if (!_foreground.isInForeground) {
          await background.setPhase(BackgroundJobPhase.waitingForApp);
        }
        await _foreground.whenInForeground(token);
        await background.setPhase(BackgroundJobPhase.summarizing);

        // Summary progress is the tokens written so far against the tokens
        // expected, so the bar moves as the text appears.
        var summaryProgress = const SummarizationProgress(SummarizationStage.preparing);
        var summaryWords = 0;
        void reportSummary() => emit(
          JobRunProgress(
            _summaryProgress(
              summaryProgress,
              summaryProgress.stage == SummarizationStage.completed
                  ? 1
                  : jobPlan.duringSummary(
                      outputTokens: (summaryWords * rates.outputTokensPerWord).round(),
                      sectionFraction: summaryProgress.fraction,
                    ),
            ),
          ),
        );

        final summaryWatch = Stopwatch()..start();
        final updates = _summarize.stream(text, summaryConfig, cancellation: token);
        await for (final update in updates) {
          switch (update) {
            case SummarizationProgressUpdate(:final progress):
              summaryProgress = progress;
              reportSummary();
            case SummarizationPausedUpdate(:final paused):
              // The app left mid-summary: say so on the lock screen until it
              // is back.
              await background.setPhase(
                paused ? BackgroundJobPhase.waitingForApp : BackgroundJobPhase.summarizing,
              );
            case SummarizationPartialSummaryUpdate(:final text):
              summaryWords = _wordCount(text);
              reportSummary();
              emit(JobRunPartialSummary(text));
            case SummarizationCompletedUpdate(:final result):
              await _jobs.completeJob(jobId, _toSummary(job, result));
              settled = true;
              completed = true;
              await _rates?.save(
                rates.afterSummary(
                  outputTokens: result.debug.outputTokens,
                  elapsed: summaryWatch.elapsed,
                  summaryWords: _wordCount(result.summary),
                ),
              );
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
        await cancelButton?.cancel();
        await background.end(completed: completed);
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

  static int _wordCount(String? text) =>
      text == null ? 0 : text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  /// Summarization progress at [fraction] of the whole job.
  static JobProgress _summaryProgress(SummarizationProgress p, double fraction) => JobProgress(
    switch (p.stage) {
      SummarizationStage.preparing => JobStage.preparing,
      SummarizationStage.analyzing => JobStage.analyzing,
      SummarizationStage.summarizing => JobStage.summarizing,
      SummarizationStage.combining => JobStage.combining,
      SummarizationStage.checking => JobStage.checking,
      SummarizationStage.finalizing => JobStage.finalizing,
      SummarizationStage.completed => JobStage.completed,
    },
    fraction: fraction,
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
    needsReview: result.needsReview,
    tokensIn: result.debug.inputTokens,
    tokensOut: result.debug.outputTokens,
    processingTimeMs: result.debug.processingTimeMs,
  );
}
