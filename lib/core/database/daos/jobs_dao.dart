import 'package:drift/drift.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/database/tables.dart';

part 'jobs_dao.g.dart';

/// One [JobRow] plus its optional [TranscriptRow]/[SummaryRow] rows and the
/// summary's [TakeawayRow]s, loaded together for `JobsRepositoryImpl.getJob`.
class JobDetailRow {
  const JobDetailRow({required this.job, this.transcript, this.summary, this.takeaways = const []});

  final JobRow job;
  final TranscriptRow? transcript;
  final SummaryRow? summary;
  final List<TakeawayRow> takeaways;
}

/// A single page of [listJobs], cursor-paginated on (createdAt, id) —
/// mirrors the shape `JobsRepositoryImpl` maps into a domain `JobsPage`.
class JobsPageRows {
  const JobsPageRows({required this.items, required this.hasMore});

  final List<JobRow> items;
  final bool hasMore;
}

@DriftAccessor(tables: [Jobs, Transcripts, Summaries, Takeaways])
class JobsDao extends DatabaseAccessor<AppDatabase> with _$JobsDaoMixin {
  JobsDao(super.db);

  /// Newest-first cursor pagination. The cursor is `"<createdAtMillis>_<id>"`
  /// of the last item on the previous page; rows are ordered by
  /// (createdAt desc, id desc) so the pair is a stable tiebreaker for
  /// same-millisecond inserts.
  Future<JobsPageRows> listJobs({String? cursor, int limit = 20}) async {
    final query = select(jobs)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);

    if (cursor != null) {
      final decoded = _decodeCursor(cursor);
      if (decoded != null) {
        final (createdAtMillis, id) = decoded;
        query.where(
          (t) =>
              t.createdAt.isSmallerThanValue(
                DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
              ) |
              (t.createdAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
                  ) &
                  t.id.isSmallerThanValue(id)),
        );
      }
    }

    // Fetch one extra row to know whether another page follows.
    query.limit(limit + 1);
    final rows = await query.get();
    final hasMore = rows.length > limit;
    return JobsPageRows(items: hasMore ? rows.sublist(0, limit) : rows, hasMore: hasMore);
  }

  String encodeCursor(JobRow job) => '${job.createdAt.millisecondsSinceEpoch}_${job.id}';

  (int, String)? _decodeCursor(String cursor) {
    final separator = cursor.indexOf('_');
    if (separator <= 0) return null;
    final millis = int.tryParse(cursor.substring(0, separator));
    if (millis == null) return null;
    return (millis, cursor.substring(separator + 1));
  }

  Future<void> insertJob(JobsCompanion entry) => into(jobs).insert(entry);

  Future<JobRow?> getJob(String id) =>
      (select(jobs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<JobDetailRow?> getJobDetail(String id) async {
    final job = await getJob(id);
    if (job == null) return null;

    final transcript = await (select(
      transcripts,
    )..where((t) => t.jobId.equals(id))).getSingleOrNull();
    final summary = await (select(
      summaries,
    )..where((t) => t.jobId.equals(id))).getSingleOrNull();

    var takeawayRows = const <TakeawayRow>[];
    if (summary != null) {
      takeawayRows =
          await (select(takeaways)
                ..where((t) => t.summaryId.equals(summary.id))
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get();
    }

    return JobDetailRow(
      job: job,
      transcript: transcript,
      summary: summary,
      takeaways: takeawayRows,
    );
  }

  Future<void> updateJob(String id, JobsCompanion entry) =>
      (update(jobs)..where((t) => t.id.equals(id))).write(entry);

  /// Deletes the job row; `Transcripts`/`Summaries`/`Takeaways` cascade via
  /// the foreign-key `onDelete` clauses. Returns the deleted row (so the
  /// repository can also remove [JobRow.sourceFilePath] from disk) or null
  /// if nothing matched.
  Future<JobRow?> deleteJob(String id) async {
    final job = await getJob(id);
    if (job == null) return null;
    await (delete(jobs)..where((t) => t.id.equals(id))).go();
    return job;
  }

  Future<String?> getTranscriptText(String jobId) async {
    final row = await (select(
      transcripts,
    )..where((t) => t.jobId.equals(jobId))).getSingleOrNull();
    return row?.content;
  }
}
