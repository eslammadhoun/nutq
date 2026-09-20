import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';

/// How the UI groups a job's lifecycle (filter chips, status badges).
enum JobStatus { done, processing, queued, failed, cancelled }

/// UI-facing view of a [JobEntity].
///
/// Deliberately free of display strings (dates, language names, titles):
/// those are locale-dependent, and this model is built inside the cubit
/// where no BuildContext exists. [JobCard] formats everything via l10n.
class Job {
  const Job({
    required this.id,
    required this.sourceType,
    required this.status,
    required this.createdAt,
    required this.languageCode,
    this.preview,
    this.failureKind,
  });

  factory Job.fromEntity(JobEntity entity) => Job(
    id: entity.id,
    sourceType: entity.sourceType,
    status: statusFromRun(entity.status),
    createdAt: entity.createdAt,
    languageCode: entity.language.code,
    preview: entity.preview,
    failureKind: entity.failureKind,
  );

  final String id;
  final JobSourceType sourceType;
  final JobStatus status;
  final DateTime createdAt;
  final String languageCode;
  final String? preview;

  /// Why the job failed; only set for failed jobs. Localized by the UI.
  final SummarizationFailureKind? failureKind;

  static JobStatus statusFromRun(JobRunStatus status) => switch (status) {
    JobRunStatus.completed => JobStatus.done,
    JobRunStatus.running => JobStatus.processing,
    JobRunStatus.pending => JobStatus.queued,
    JobRunStatus.failed => JobStatus.failed,
    JobRunStatus.cancelled => JobStatus.cancelled,
  };

  /// The stored states a UI filter chip stands for.
  static Set<JobRunStatus> runStatusesFor(JobStatus status) => switch (status) {
    JobStatus.done => {JobRunStatus.completed},
    JobStatus.processing => {JobRunStatus.running},
    JobStatus.queued => {JobRunStatus.pending},
    JobStatus.failed => {JobRunStatus.failed},
    JobStatus.cancelled => {JobRunStatus.cancelled},
  };
}
