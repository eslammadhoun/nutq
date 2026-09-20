import 'package:drift/drift.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/data/local/converters/string_list_converter.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

/// One row per job — only lightweight columns, so list queries never load
/// transcript or summary bodies.
///
/// Enum columns are stored by name (`textEnum`): renaming an enum value needs
/// a migration.
@DataClassName('JobRow')
@TableIndex(name: 'jobs_created_at_idx', columns: {#createdAt})
@TableIndex(name: 'jobs_status_created_at_idx', columns: {#status, #createdAt})
class Jobs extends Table {
  TextColumn get id => text()();
  TextColumn get status => textEnum<JobRunStatus>()();
  TextColumn get sourceType => textEnum<JobSourceType>()();

  /// Language of the source. The SQL column keeps its original name.
  TextColumn get sourceLanguage => textEnum<ContentLanguage>().named('language')();

  /// Language the summary is written in (added in schema v2).
  TextColumn get summaryLanguage =>
      textEnum<ContentLanguage>().withDefault(const Constant('ar'))();
  TextColumn get requestedLength => textEnum<SummaryLength>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get failureKind => textEnum<JobFailureKind>().nullable()();

  /// First words of the transcript, denormalized for the list row.
  TextColumn get preview => text().nullable()();

  /// Web address of the source (YouTube). Never deleted.
  TextColumn get sourceUrl => text().nullable()();

  /// App-owned copy of an uploaded/downloaded file. The repository deletes the
  /// file when the job is deleted.
  TextColumn get sourceFilePath => text().nullable()();
  TextColumn get sourceMimeType => text().nullable()();
  TextColumn get sourceTitle => text().nullable()();
  RealColumn get durationSeconds => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One-to-one with [Jobs]: the (possibly large) text being summarized. Absent
/// until a job that starts from media has been transcribed.
@DataClassName('TranscriptRow')
class JobTranscripts extends Table {
  TextColumn get jobId => text().references(Jobs, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  IntColumn get wordCount =>
      // ignore: recursive_getters
      integer().check(wordCount.isBiggerOrEqualValue(0))();

  /// Speech-recognition model that produced [content] (added in schema v2).
  TextColumn get modelName => text().nullable()();
  TextColumn get modelVersion => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {jobId};
}

/// One-to-one with [Jobs]: present only once the job completed.
@DataClassName('SummaryRow')
class JobSummaries extends Table {
  TextColumn get jobId => text().references(Jobs, #id, onDelete: KeyAction.cascade)();
  TextColumn get summaryText => text()();
  TextColumn get takeaways => text().map(const StringListConverter())();
  TextColumn get modelName => text()();
  TextColumn get promptVersion => text()();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
  IntColumn get processingTimeMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {jobId};
}
