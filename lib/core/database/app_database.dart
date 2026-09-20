// The generated part file references the enum and converter types used by the
// tables, so they must be in scope here.
// ignore_for_file: unused_import
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/core/database/schema_versions.dart';
import 'package:nutq/features/jobs/data/local/converters/string_list_converter.dart';
import 'package:nutq/features/jobs/data/local/tables/jobs_tables.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

part 'app_database.g.dart';

/// The app's local SQLite database.
///
/// Tables and DAOs are owned by their features; this class only assembles
/// them. Schema changes: bump [schemaVersion], add a migration step, and
/// re-dump the schema (`dart run drift_dev schema dump ... drift_schemas/`)
/// so migrations can be tested against real earlier versions.
@DriftDatabase(tables: [Jobs, JobTranscripts, JobSummaries], daos: [JobsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'nutq_db'));

  /// For tests: pass an in-memory `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Source description (for media and YouTube jobs) and a summary
        // language that is separate from the source language.
        await m.addColumn(schema.jobs, schema.jobs.summaryLanguage);
        await m.addColumn(schema.jobs, schema.jobs.sourceUrl);
        await m.addColumn(schema.jobs, schema.jobs.sourceFilePath);
        await m.addColumn(schema.jobs, schema.jobs.sourceMimeType);
        await m.addColumn(schema.jobs, schema.jobs.sourceTitle);
        await m.addColumn(schema.jobs, schema.jobs.durationSeconds);
        await m.addColumn(schema.jobTranscripts, schema.jobTranscripts.modelName);
        await m.addColumn(schema.jobTranscripts, schema.jobTranscripts.modelVersion);
        // v1 wrote summaries in the source language.
        await m.database.customStatement(
          'UPDATE jobs SET summary_language = language',
        );
      },
    ),
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless enabled per connection; cascades
      // (deleting a job removes its transcript and summary) depend on it.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
