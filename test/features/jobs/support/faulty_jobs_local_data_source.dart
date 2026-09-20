import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';

/// An operation of [JobsLocalDataSource] that [FaultyJobsLocalDataSource] can
/// make fail.
enum Fault {
  watchJobs,
  watchJob,
  getJob,
  insertJob,
  transition,
  completeJob,
  saveTranscript,
  updateSourceInfo,
  deleteJob,
  failActiveJobs,
}

/// Wraps a real data source and makes the chosen operations throw a storage
/// error, so failure paths can be tested without a broken database.
/// `FaultyJobsLocalDataSource.everything` fails all of them.
class FaultyJobsLocalDataSource implements JobsLocalDataSource {
  FaultyJobsLocalDataSource(this._inner, this._faults);

  FaultyJobsLocalDataSource.everything(this._inner) : _faults = Fault.values.toSet();

  final JobsLocalDataSource _inner;
  final Set<Fault> _faults;

  StateError get _error => StateError('simulated storage failure');

  bool _fails(Fault f) => _faults.contains(f);

  @override
  Stream<List<JobEntity>> watchJobs(JobsQuery query) =>
      _fails(Fault.watchJobs) ? Stream.error(_error) : _inner.watchJobs(query);

  @override
  Stream<JobDetailEntity?> watchJob(String id) =>
      _fails(Fault.watchJob) ? Stream.error(_error) : _inner.watchJob(id);

  @override
  Future<JobDetailEntity?> getJob(String id) =>
      _fails(Fault.getJob) ? Future.error(_error) : _inner.getJob(id);

  @override
  Future<void> insertJob(JobDetailEntity job) =>
      _fails(Fault.insertJob) ? Future.error(_error) : _inner.insertJob(job);

  @override
  Future<TransitionOutcome> transition(
    String id, {
    required Set<JobRunStatus> from,
    required JobRunStatus to,
    required DateTime at,
    JobFailureKind? failureKind,
  }) => _fails(Fault.transition)
      ? Future.error(_error)
      : _inner.transition(id, from: from, to: to, at: at, failureKind: failureKind);

  @override
  Future<TransitionOutcome> completeJob(String id, Summary summary, DateTime at) =>
      _fails(Fault.completeJob) ? Future.error(_error) : _inner.completeJob(id, summary, at);

  @override
  Future<TransitionOutcome> saveTranscript(String id, Transcript transcript, DateTime at) =>
      _fails(Fault.saveTranscript)
      ? Future.error(_error)
      : _inner.saveTranscript(id, transcript, at);

  @override
  Future<TransitionOutcome> updateSourceInfo(String id, SourceInfo info, DateTime at) =>
      _fails(Fault.updateSourceInfo)
      ? Future.error(_error)
      : _inner.updateSourceInfo(id, info, at);

  @override
  Future<void> deleteJob(String id) =>
      _fails(Fault.deleteJob) ? Future.error(_error) : _inner.deleteJob(id);

  @override
  Future<int> failActiveJobs(JobFailureKind kind, DateTime at) =>
      _fails(Fault.failActiveJobs) ? Future.error(_error) : _inner.failActiveJobs(kind, at);
}
