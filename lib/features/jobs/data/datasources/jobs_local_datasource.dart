import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/data/mappers/job_mappers.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';

/// SQLite access for jobs, expressed in domain entities.
///
/// State changes are conditional (`WHERE status IN ...`) and reported as a
/// [TransitionOutcome], so the repository can tell "no such job" from "not
/// allowed from its current state" without a race between check and write.
abstract interface class JobsLocalDataSource {
  Stream<List<JobEntity>> watchJobs(JobsQuery query);

  Stream<JobDetailEntity?> watchJob(String id);

  Future<JobDetailEntity?> getJob(String id);

  /// Inserts the job together with its transcript.
  Future<void> insertJob(JobDetailEntity job);

  Future<TransitionOutcome> transition(
    String id, {
    required Set<JobRunStatus> from,
    required JobRunStatus to,
    required DateTime at,
    SummarizationFailureKind? failureKind,
  });

  Future<TransitionOutcome> completeJob(
    String id,
    Summary summary,
    DateTime at,
  );

  Future<void> deleteJob(String id);

  Future<int> failActiveJobs(SummarizationFailureKind kind, DateTime at);
}

class JobsLocalDataSourceImpl implements JobsLocalDataSource {
  JobsLocalDataSourceImpl(this._dao);

  final JobsDao _dao;

  @override
  Stream<List<JobEntity>> watchJobs(JobsQuery query) =>
      _dao.watchJobs(query).map((rows) => [for (final r in rows) r.toEntity()]);

  @override
  Stream<JobDetailEntity?> watchJob(String id) =>
      _dao.watchDetail(id).map((rows) => rows?.toEntity());

  @override
  Future<JobDetailEntity?> getJob(String id) async =>
      (await _dao.getDetail(id))?.toEntity();

  @override
  Future<void> insertJob(JobDetailEntity job) =>
      _dao.insertJob(job.toJobCompanion(), job.toTranscriptCompanion());

  @override
  Future<TransitionOutcome> transition(
    String id, {
    required Set<JobRunStatus> from,
    required JobRunStatus to,
    required DateTime at,
    SummarizationFailureKind? failureKind,
  }) =>
      _dao.transition(id, from: from, to: to, at: at, failureKind: failureKind);

  @override
  Future<TransitionOutcome> completeJob(
    String id,
    Summary summary,
    DateTime at,
  ) => _dao.completeJob(id, summary.toCompanion(id), at);

  @override
  Future<void> deleteJob(String id) => _dao.deleteJob(id);

  @override
  Future<int> failActiveJobs(SummarizationFailureKind kind, DateTime at) =>
      _dao.failActiveJobs(kind, at);
}
