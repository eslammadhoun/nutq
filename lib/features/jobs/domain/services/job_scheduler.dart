import 'package:nutq/features/jobs/domain/entities/job_progress.dart';

/// Live, in-memory state of a job that is being processed right now.
class JobLive {
  const JobLive({this.progress, this.partialTranscript, this.partialSummary});

  final JobProgress? progress;

  /// The transcript as recognized so far (media jobs, while transcribing).
  final String? partialTranscript;

  /// The summary as generated so far.
  final String? partialSummary;

  JobLive copyWith({JobProgress? progress, String? partialTranscript, String? partialSummary}) =>
      JobLive(
        progress: progress ?? this.progress,
        partialTranscript: partialTranscript ?? this.partialTranscript,
        partialSummary: partialSummary ?? this.partialSummary,
      );
}

/// Owns running jobs for the whole app, independent of any screen.
///
/// Jobs run one at a time, in the order they were enqueued. Screens observe a
/// job's durable state through `JobsRepository.watchJob` and its live progress
/// through [watchLive]; leaving a screen never stops a job — only [cancel] does.
abstract interface class JobScheduler {
  /// Queues a stored `pending` job. Enqueueing a job that is already queued or
  /// running does nothing.
  void enqueue(String jobId);

  /// Stops a running job, or removes a queued one, and records it as
  /// cancelled.
  Future<void> cancel(String jobId);

  /// The job's live state: the current value when listened to, then every
  /// change. Emits null when the job is not being processed.
  Stream<JobLive?> watchLive(String jobId);
}
