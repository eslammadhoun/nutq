import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

/// Migrations are tested against the real earlier schemas dumped in
/// `drift_schemas/` (see docs/LOCAL_STORAGE.md), not against hand-written
/// approximations.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('the current schema version is the latest dumped one', () {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 2);
  });

  test('v1 → v2 produces exactly the v2 schema', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v1 → v2 keeps existing jobs, transcripts and summaries intact', () async {
    final schema = await verifier.schemaAt(1);

    // Rows exactly as v1 wrote them (no summary_language column exists yet).
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    Future<void> sql(String statement) => oldDb.customStatement(statement);
    await sql(
      'INSERT INTO jobs (id, status, source_type, language, requested_length, created_at, updated_at, failure_kind, preview) '
      "VALUES ('a', 'completed', 'text', 'en', 'short', '2026-09-01T10:00:00.000Z', '2026-09-01T10:05:00.000Z', NULL, 'hello world')",
    );
    await sql(
      'INSERT INTO jobs (id, status, source_type, language, requested_length, created_at, updated_at, failure_kind, preview) '
      "VALUES ('b', 'failed', 'text', 'ar', 'medium', '2026-09-02T10:00:00.000Z', '2026-09-02T10:01:00.000Z', 'interrupted', 'مرحبا')",
    );
    await sql(
      "INSERT INTO job_transcripts (job_id, content, word_count) VALUES ('a', 'hello world', 2)",
    );
    await sql(
      'INSERT INTO job_summaries (job_id, summary_text, takeaways, model_name, prompt_version, needs_review) '
      "VALUES ('a', 'A summary', '[\"one\",\"two\"]', 'gemma3-1b-it-q4', 'v1', 1)",
    );
    await oldDb.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    final a = (await db.jobsDao.getDetail('a'))!;
    expect(a.job.status, JobRunStatus.completed);
    expect(a.job.sourceLanguage, ContentLanguage.en);
    expect(
      a.job.summaryLanguage,
      ContentLanguage.en,
      reason: 'v1 summaries were written in the source language',
    );
    expect(a.job.requestedLength, SummaryLength.short);
    expect(a.job.preview, 'hello world');
    expect(a.transcript!.content, 'hello world');
    expect(a.transcript!.modelName, isNull);
    expect(a.summary!.summaryText, 'A summary');
    expect(a.summary!.takeaways, ['one', 'two']);
    expect(a.summary!.needsReview, isTrue);
    for (final field in [
      a.job.sourceUrl,
      a.job.sourceFilePath,
      a.job.sourceMimeType,
      a.job.sourceTitle,
      a.job.durationSeconds,
    ]) {
      expect(field, isNull, reason: 'new source columns start empty');
    }

    final b = (await db.jobsDao.getDetail('b'))!;
    expect(b.job.summaryLanguage, ContentLanguage.ar);
    expect(b.job.failureKind?.name, 'interrupted');
    expect(b.transcript, isNull);
  });

  test('foreign keys are still enforced after a migration', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.single, 1);
  });
}
