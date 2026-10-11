import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:nutq/core/utils/throttler.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/repositories/media_files.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/domain/usecases/process_job.dart';

/// The app-wide job queue.
///
/// - **One job at a time.** Models are large and generation is serial, so
///   parallel runs would only fight over memory and the accelerator.
/// - **Independent of the UI.** Runs continue while the user navigates; screens
///   observe the database and [watchLive].
/// - **Recovers after a crash.** [start] fails jobs an earlier session left
///   active (only those created before this runner was created, so a job
///   submitted a moment ago is never touched).
/// - **Frees media it no longer needs.** A job's audio or video file is deleted
///   once the job ends, and [start] sweeps away files no active job uses (left
///   by a crash, or by builds before this rule).
/// - **Releases memory when idle.** [onIdle] fires after the queue has been
///   empty for [idleAfter] (for example to unload the model).
///
/// It does not keep running when the OS suspends or kills the app; that needs
/// platform background execution.
class JobRunner implements JobScheduler {
  JobRunner({
    required this._jobs,
    required this._process,
    this._media,
    this.onIdle,
    this.idleAfter = const Duration(minutes: 2),
    this.partialInterval = const Duration(milliseconds: 250),
    DateTime Function()? now,
  }) : _startedAt = (now ?? DateTime.now)().toUtc();

  final JobsRepository _jobs;
  final ProcessJob _process;

  /// Null leaves media files alone (tests that do not need them).
  final MediaFiles? _media;

  /// Called once the queue has been idle for [idleAfter].
  final Future<void> Function()? onIdle;
  final Duration idleAfter;

  /// Streaming transcript and summary text is delivered at most this often.
  /// Each delivery re-lays-out the growing text on Job Detail, so a quarter of
  /// a second keeps it reading as a stream without keeping the phone busy.
  final Duration partialInterval;

  final DateTime _startedAt;
  final Queue<String> _queue = Queue();
  final Map<String, JobLive> _live = {};
  final StreamController<({String id, JobLive? live})> _changes = StreamController.broadcast();

  bool _started = false;
  bool _disposed = false;
  String? _currentId;
  JobRun? _currentRun;
  Timer? _idleTimer;

  /// Recovers interrupted jobs, then begins processing anything queued.
  /// Idempotent.
  Future<void> start() async {
    if (_started || _disposed) return;
    try {
      await _jobs.recoverInterruptedJobs(createdBefore: _startedAt);
    } catch (error) {
      debugPrint('Could not recover interrupted jobs: $error');
    }
    await _sweepMedia();
    _started = true;
    _pump();
  }

  @override
  void enqueue(String jobId) {
    if (_disposed || jobId == _currentId || _queue.contains(jobId)) return;
    _queue.add(jobId);
    _pump();
  }

  @override
  Future<void> cancel(String jobId) async {
    if (jobId == _currentId) {
      await _currentRun?.cancel();
      return;
    }
    if (!_queue.remove(jobId)) return;
    try {
      await _jobs.cancelJob(jobId);
    } on JobNotFoundException {
      // Deleted while queued.
    } on InvalidJobTransitionException {
      // Already settled.
    }
  }

  @override
  Stream<JobLive?> watchLive(String jobId) {
    late final StreamController<JobLive?> controller;
    StreamSubscription<({String id, JobLive? live})>? subscription;
    controller = StreamController<JobLive?>(
      onListen: () {
        controller.add(_live[jobId]);
        subscription = _changes.stream
            .where((change) => change.id == jobId)
            .listen((change) => controller.add(change.live));
      },
      onCancel: () async {
        await subscription?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  void _pump() {
    if (!_started || _disposed || _currentId != null || _queue.isEmpty) return;
    _idleTimer?.cancel();
    final id = _queue.removeFirst();
    _currentId = id;
    unawaited(_runOne(id));
  }

  Future<void> _runOne(String id) async {
    final run = _process(id);
    _currentRun = run;

    final partials = Throttler<String>(
      partialInterval,
      (text) => _update(id, (live) => live.copyWith(partialSummary: text)),
    );
    final transcripts = Throttler<String>(
      partialInterval,
      (text) => _update(id, (live) => live.copyWith(partialTranscript: text)),
    );
    final done = Completer<void>();
    final subscription = run.events.listen(
      (event) {
        switch (event) {
          case JobRunProgress(:final progress):
            _update(id, (live) => live.copyWith(progress: progress));
          case JobRunPartialTranscript(:final text):
            transcripts.add(text);
          case JobRunPartialSummary(:final text):
            partials.add(text);
        }
      },
      onError: (Object error) {
        // Outcomes are stored; only unexpected errors end up here.
        if (error is! JobNotFoundException) debugPrint('Job $id failed to run: $error');
      },
      onDone: done.complete,
    );

    await done.future;
    partials.cancel();
    transcripts.cancel();
    await subscription.cancel();

    try {
      await _jobs.releaseMedia(id);
    } catch (error) {
      debugPrint('Could not release media of job $id: $error');
    }

    _currentId = null;
    _currentRun = null;
    _live.remove(id);
    if (_disposed) return; // the stream is closed and nothing more should run
    _changes.add((id: id, live: null));

    if (_queue.isNotEmpty) {
      _pump();
    } else {
      _scheduleIdle();
    }
  }

  /// Deletes media files no pending or running job reads. Files imported since
  /// this runner was created are spared: they may belong to a job being
  /// submitted.
  Future<void> _sweepMedia() async {
    final media = _media;
    if (media == null) return;
    try {
      final active = await _jobs
          .watchJobs(
            const JobsQuery(statuses: {JobRunStatus.pending, JobRunStatus.running}, limit: 1 << 30),
          )
          .first;
      final keep = <String>{
        for (final job in active) ?(await _jobs.getJob(job.id))?.sourceFilePath,
      };
      await media.deleteAllExcept(keep, modifiedBefore: _startedAt);
    } catch (error) {
      debugPrint('Could not clean up job media: $error');
    }
  }

  void _update(String id, JobLive Function(JobLive live) change) {
    if (_disposed || id != _currentId) return;
    final next = change(_live[id] ?? const JobLive());
    _live[id] = next;
    _changes.add((id: id, live: next));
  }

  void _scheduleIdle() {
    final callback = onIdle;
    if (callback == null || _disposed) return;
    _idleTimer?.cancel();
    _idleTimer = Timer(idleAfter, () => unawaited(callback()));
  }

  /// Stops the current job and releases resources. The runner is unusable
  /// afterwards.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _idleTimer?.cancel();
    _queue.clear();
    await _currentRun?.cancel();
    await _changes.close();
  }
}
