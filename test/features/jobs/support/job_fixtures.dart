import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/summarization/domain/entities/summary_language.dart';

/// A fresh in-memory database per test.
AppDatabase newTestDatabase() {
  // Some tests deliberately open two databases side by side.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Repository over [db] with sequential ids (`job-1`, `job-2`, …) and a clock
/// that advances one minute per call, so ordering is deterministic.
class TestRepo {
  TestRepo(this.db, {DateTime? start})
    : _clock = start ?? DateTime.utc(2026, 9, 20, 12) {
    repo = JobsRepositoryImpl(
      JobsLocalDataSourceImpl(db.jobsDao),
      newId: () => 'job-${++_ids}',
      now: () {
        final t = _clock;
        _clock = _clock.add(const Duration(minutes: 1));
        return t;
      },
    );
  }

  final AppDatabase db;
  late final JobsRepositoryImpl repo;
  int _ids = 0;
  DateTime _clock;
}

NewJobDraft draft(
  String text, {
  SummaryLanguage language = SummaryLanguage.ar,
}) => NewJobDraft(text: text, language: language);
