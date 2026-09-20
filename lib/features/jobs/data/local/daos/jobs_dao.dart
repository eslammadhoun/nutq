import 'package:drift/drift.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/local/tables/jobs_tables.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';

part 'jobs_dao.g.dart';

/// A job row joined with its optional transcript and summary rows.
class JobDetailRows {
  const JobDetailRows(this.job, this.transcript, this.summary);

  final JobRow job;
  final TranscriptRow? transcript;
  final SummaryRow? summary;
}

/// How an attempted state change ended.
enum TransitionOutcome { applied, notFound, invalidState }

@DriftAccessor(tables: [Jobs, JobTranscripts, JobSummaries])
class JobsDao extends DatabaseAccessor<AppDatabase> with _$JobsDaoMixin {
  JobsDao(super.attachedDatabase);

  static const _likeEscape = r'\';

  /// Newest first; ties broken by id so the order is stable.
  Stream<List<JobRow>> watchJobs(JobsQuery query) {
    final select = this.select(jobs)
      ..orderBy([
        (j) => OrderingTerm.desc(j.createdAt),
        (j) => OrderingTerm.desc(j.id),
      ])
      ..limit(query.limit);

    final statuses = query.statuses;
    if (statuses != null) {
      select.where((j) => j.status.isInValues(statuses.toList()));
    }

    final text = query.text.trim();
    if (text.isNotEmpty) {
      final pattern = '%${_escapeLike(text)}%';
      select.where((j) {
        final inTranscript = existsQuery(
          selectOnly(jobTranscripts)
            ..addColumns([jobTranscripts.jobId])
            ..where(
              jobTranscripts.jobId.equalsExp(j.id) &
                  jobTranscripts.content.like(pattern, escapeChar: _likeEscape),
            ),
        );
        return j.preview.like(pattern, escapeChar: _likeEscape) | inTranscript;
      });
    }
    return select.watch();
  }

  Stream<JobDetailRows?> watchDetail(String id) =>
      _detailQuery(id).watchSingleOrNull().map(_toDetail);

  Future<JobDetailRows?> getDetail(String id) async =>
      _toDetail(await _detailQuery(id).getSingleOrNull());

  JoinedSelectStatement<HasResultSet, dynamic> _detailQuery(String id) =>
      select(jobs).join([
        leftOuterJoin(jobTranscripts, jobTranscripts.jobId.equalsExp(jobs.id)),
        leftOuterJoin(jobSummaries, jobSummaries.jobId.equalsExp(jobs.id)),
      ])..where(jobs.id.equals(id));

  JobDetailRows? _toDetail(TypedResult? row) => row == null
      ? null
      : JobDetailRows(
          row.readTable(jobs),
          row.readTableOrNull(jobTranscripts),
          row.readTableOrNull(jobSummaries),
        );

  /// Inserts the job and its transcript atomically.
  Future<void> insertJob(
    JobsCompanion job,
    JobTranscriptsCompanion transcript,
  ) => transaction(() async {
    await into(jobs).insert(job);
    await into(jobTranscripts).insert(transcript);
  });

  /// Moves a job to [to] only if it is currently in one of [from].
  Future<TransitionOutcome> transition(
    String id, {
    required Set<JobRunStatus> from,
    required JobRunStatus to,
    required DateTime at,
    SummarizationFailureKind? failureKind,
  }) => transaction(() async {
    final updated =
        await (update(jobs)..where(
              (j) => j.id.equals(id) & j.status.isInValues(from.toList()),
            ))
            .write(
              JobsCompanion(
                status: Value(to),
                updatedAt: Value(at),
                failureKind: Value(failureKind),
              ),
            );
    return updated > 0 ? TransitionOutcome.applied : await _whyNotApplied(id);
  });

  /// `pending|running → completed` and the summary row, atomically.
  Future<TransitionOutcome> completeJob(
    String id,
    JobSummariesCompanion summary,
    DateTime at,
  ) => transaction(() async {
    final updated =
        await (update(
          jobs,
        )..where((j) => j.id.equals(id) & j.status.isInValues(_active))).write(
          JobsCompanion(
            status: const Value(JobRunStatus.completed),
            updatedAt: Value(at),
            failureKind: const Value(null),
          ),
        );
    if (updated == 0) return _whyNotApplied(id);
    await into(jobSummaries).insertOnConflictUpdate(summary);
    return TransitionOutcome.applied;
  });

  Future<int> deleteJob(String id) =>
      (delete(jobs)..where((j) => j.id.equals(id))).go();

  /// Fails every job still pending/running. Returns how many changed.
  Future<int> failActiveJobs(SummarizationFailureKind kind, DateTime at) =>
      (update(jobs)..where((j) => j.status.isInValues(_active))).write(
        JobsCompanion(
          status: const Value(JobRunStatus.failed),
          updatedAt: Value(at),
          failureKind: Value(kind),
        ),
      );

  static final _active = JobRunStatus.values.where((s) => s.isActive).toList();

  Future<TransitionOutcome> _whyNotApplied(String id) async {
    final exists =
        await (selectOnly(jobs)
              ..addColumns([jobs.id])
              ..where(jobs.id.equals(id)))
            .getSingleOrNull();
    return exists == null
        ? TransitionOutcome.notFound
        : TransitionOutcome.invalidState;
  }

  /// Escapes LIKE wildcards so user input is matched literally.
  static String _escapeLike(String input) => input
      .replaceAll(_likeEscape, '$_likeEscape$_likeEscape')
      .replaceAll('%', '$_likeEscape%')
      .replaceAll('_', '${_likeEscape}_');
}
