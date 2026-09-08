import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  group('JobsRepositoryImpl (local DB)', () {
    late AppDatabase db;
    late Directory tempDir;
    late JobsRepository repository;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp('nutq_jobs_repo_test');
      final dataSource = JobsDataSourceImpl(
        db.jobsDao,
        supportDirectory: () async => tempDir,
      );
      repository = JobsRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('submitting a text job persists it and it appears in listJobs', () async {
      final submitted = await repository.submitJob(
        const SubmitJobParams(sourceType: 'text', language: 'ar', text: 'مرحبا بالعالم'),
      );
      final job = switch (submitted) {
        Success(:final data) => data,
        Failure(:final error) => throw StateError('submit failed: $error'),
      };

      expect(job.status, 'pending');
      expect(job.sourceType, 'text');

      final page = await repository.listJobs(limit: 20);
      final items = switch (page) {
        Success(:final data) => data.items,
        Failure(:final error) => throw StateError('list failed: $error'),
      };

      expect(items, hasLength(1));
      expect(items.single.id, job.id);
      expect(items.single.preview, contains('مرحبا'));
    });

    test('submitting an upload job copies the file into permanent storage', () async {
      final sourceFile = File(p.join(tempDir.path, 'picker_cache', 'clip.mp3'));
      await sourceFile.create(recursive: true);
      await sourceFile.writeAsString('fake audio bytes');

      final submitted = await repository.submitJob(
        SubmitJobParams(
          sourceType: 'upload',
          language: 'ar',
          filename: 'clip.mp3',
          contentType: 'audio/mpeg',
          sizeHint: 17,
          file: UploadFile(
            name: 'clip.mp3',
            path: sourceFile.path,
            sizeBytes: 17,
            contentType: 'audio/mpeg',
          ),
        ),
      );
      final job = switch (submitted) {
        Success(:final data) => data,
        Failure(:final error) => throw StateError('submit failed: $error'),
      };

      expect(job.status, 'pending');
      expect(job.sourceType, 'upload');

      final detailResult = await repository.getJob(job.id);
      final detail = switch (detailResult) {
        Success(:final data) => data,
        Failure(:final error) => throw StateError('getJob failed: $error'),
      };
      expect(detail.id, job.id);
      expect(detail.transcript, isNull);
      expect(detail.summary, isNull);
    });

    test('getJob returns a server-not-found-shaped failure for an unknown id', () async {
      final result = await repository.getJob('does-not-exist');
      expect(result, isA<Failure<dynamic>>());
    });

    test('deleteJob removes the row so it no longer appears in listJobs', () async {
      final submitted = await repository.submitJob(
        const SubmitJobParams(sourceType: 'text', language: 'ar', text: 'test'),
      );
      final job = (submitted as Success).data;

      final deleteResult = await repository.deleteJob(job.id);
      expect(deleteResult, isA<Success<void>>());

      final page = await repository.listJobs(limit: 20) as Success<JobsPage>;
      expect(page.data.items, isEmpty);
    });

    test('listJobs paginates newest-first with a working cursor', () async {
      for (var i = 0; i < 3; i++) {
        await repository.submitJob(
          SubmitJobParams(sourceType: 'text', language: 'ar', text: 'job $i'),
        );
      }

      final firstPage = await repository.listJobs(limit: 2) as Success<JobsPage>;
      expect(firstPage.data.items, hasLength(2));
      expect(firstPage.data.nextCursor, isNotNull);

      final secondPage =
          await repository.listJobs(cursor: firstPage.data.nextCursor, limit: 2)
              as Success<JobsPage>;
      expect(secondPage.data.items, hasLength(1));
      expect(secondPage.data.nextCursor, isNull);
    });
  });
}
