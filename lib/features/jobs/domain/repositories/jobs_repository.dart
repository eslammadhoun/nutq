import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';

/// Durable storage for summary jobs.
///
/// Reads are streams that re-emit whenever the underlying data changes, so the
/// database stays the single source of truth. All failures surface as
/// `JobStorageException`; lifecycle misuse as `JobNotFoundException` or
/// `InvalidJobTransitionException`.
abstract interface class JobsRepository {
  /// Jobs matching [query], newest first.
  Stream<List<JobEntity>> watchJobs(JobsQuery query);

  /// One job with its transcript and summary; emits null when it does not
  /// exist (or is deleted while watched).
  Stream<JobDetailEntity?> watchJob(String id);

  Future<JobDetailEntity?> getJob(String id);

  /// Saves a new job in the `pending` state.
  Future<JobDetailEntity> createJob(NewJobDraft draft);

  /// `pending → running`.
  Future<void> markRunning(String id);

  /// `running → completed`, saving the summary atomically with the status.
  Future<void> completeJob(String id, SummaryResult result);

  /// `pending|running → failed`.
  Future<void> failJob(String id, SummarizationFailureKind kind);

  /// `pending|running → cancelled`.
  Future<void> cancelJob(String id);

  /// Removes the job and everything attached to it. Deleting a missing job is
  /// a no-op.
  Future<void> deleteJob(String id);

  /// Marks jobs left `pending`/`running` (for example by an app kill) as
  /// failed with `interrupted`. Returns how many were recovered.
  Future<int> recoverInterruptedJobs();
}
