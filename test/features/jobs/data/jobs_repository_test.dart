import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import '../support/faulty_jobs_local_data_source.dart';
import '../support/job_fixtures.dart';

void main() {
  late AppDatabase db;
  late TestRepo t;

  setUp(() {
    db = newTestDatabase();
    t = TestRepo(db);
  });
  tearDown(() => db.close());

  group('createJob', () {
    test('saves a pending job with a preview, word count and injected id/clock', () async {
      final job = await t.repo.createJob(draft('  مرحبا   بكم\nفي   الدرس  '));

      expect(job.id, 'job-1');
      expect(job.status, JobRunStatus.pending);
      expect(job.createdAt, DateTime.utc(2026, 9, 20, 12));
      expect(job.updatedAt, job.createdAt);
      expect(job.transcript!.text, 'مرحبا   بكم\nفي   الدرس', reason: 'trimmed but otherwise verbatim');
      expect(job.transcript!.wordCount, 4);
      expect(job.sourceLanguage, ContentLanguage.ar);
      expect(job.requestedLength, SummaryLength.medium);

      final stored = (await t.repo.getJob('job-1'))!;
      expect(stored.transcript!.text, job.transcript!.text);
      final listed = await t.repo.watchJobs(const JobsQuery()).first;
      expect(listed.single.preview, 'مرحبا بكم في الدرس');
    });

    test('long text is previewed with an ellipsis but stored in full', () async {
      final text = List.filled(100, 'كلمة').join(' ');
      await t.repo.createJob(draft(text));
      final preview = (await t.repo.watchJobs(const JobsQuery()).first).single.preview!;
      expect(preview.length, lessThanOrEqualTo(141));
      expect(preview.endsWith('…'), isTrue);
      expect((await t.repo.getJob('job-1'))!.transcript!.text, text);
    });

    test('a blank transcript is rejected and nothing is saved', () async {
      await expectLater(t.repo.createJob(draft('   \n ')), throwsArgumentError);
      expect(await t.repo.watchJobs(const JobsQuery()).first, isEmpty);
    });

    test('keeps the chosen language and length', () async {
      await t.repo.createJob(
        NewJobDraft.text(text: 'hello world', language: ContentLanguage.en, length: SummaryLength.detailed),
      );
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.sourceLanguage, ContentLanguage.en);
      expect(job.requestedLength, SummaryLength.detailed);
    });
  });

  group('lifecycle', () {
    test('pending → running → completed saves the summary with its provenance', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.markRunning('job-1');
      expect((await t.repo.getJob('job-1'))!.status, JobRunStatus.running);

      await t.repo.completeJob('job-1', testSummary(needsReview: true));
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.status, JobRunStatus.completed);
      final Summary s = job.summary!;
      expect(s.summaryText, 'ملخص نهائي');
      expect(s.takeaways, ['نقطة ١', 'نقطة ٢']);
      expect(s.length, SummaryLength.medium);
      expect(s.modelName, 'test-model');
      expect(s.promptVersion, 'test-v1');
      expect(s.needsReview, isTrue);
      expect(s.tokensIn, 900);
      expect(s.tokensOut, 300);
      expect(s.processingTimeMs, 4200);
      expect(job.updatedAt.isAfter(job.createdAt), isTrue);
    });

    test('a pending job can complete directly (short runs)', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.completeJob('job-1', testSummary());
      expect((await t.repo.getJob('job-1'))!.status, JobRunStatus.completed);
    });

    test('failJob records the failure kind', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.failJob('job-1', JobFailureKind.modelUnavailable);
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.status, JobRunStatus.failed);
      expect(job.failureKind, JobFailureKind.modelUnavailable);
    });

    test('cancelJob works from pending and running', () async {
      await t.repo.createJob(draft('a'));
      await t.repo.createJob(draft('b'));
      await t.repo.markRunning('job-2');
      await t.repo.cancelJob('job-1');
      await t.repo.cancelJob('job-2');
      expect((await t.repo.getJob('job-1'))!.status, JobRunStatus.cancelled);
      expect((await t.repo.getJob('job-2'))!.status, JobRunStatus.cancelled);
    });

    test('final states are final: no further transition is allowed', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.cancelJob('job-1');

      await expectLater(t.repo.completeJob('job-1', testSummary()), throwsA(isA<InvalidJobTransitionException>()));
      await expectLater(t.repo.failJob('job-1', JobFailureKind.generationFailed), throwsA(isA<InvalidJobTransitionException>()));
      await expectLater(t.repo.markRunning('job-1'), throwsA(isA<InvalidJobTransitionException>()));
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.status, JobRunStatus.cancelled);
      expect(job.summary, isNull, reason: 'a rejected completion leaves no summary behind');
    });

    test('a completed job cannot be cancelled or failed afterwards, so its summary is safe', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.completeJob('job-1', testSummary());

      await expectLater(t.repo.cancelJob('job-1'), throwsA(isA<InvalidJobTransitionException>()));
      await expectLater(t.repo.failJob('job-1', JobFailureKind.generationFailed), throwsA(isA<InvalidJobTransitionException>()));
      expect(await t.repo.recoverInterruptedJobs(), 0);

      final job = (await t.repo.getJob('job-1'))!;
      expect(job.status, JobRunStatus.completed);
      expect(job.summary!.summaryText, 'ملخص نهائي');
      expect(job.failureKind, isNull);
    });

    test('a failed job cannot later be cancelled or completed', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.failJob('job-1', JobFailureKind.generationFailed);
      await expectLater(t.repo.cancelJob('job-1'), throwsA(isA<InvalidJobTransitionException>()));
      await expectLater(t.repo.completeJob('job-1', testSummary()), throwsA(isA<InvalidJobTransitionException>()));
      expect((await t.repo.getJob('job-1'))!.status, JobRunStatus.failed);
    });

    test('markRunning is only valid from pending', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.markRunning('job-1');
      await expectLater(t.repo.markRunning('job-1'), throwsA(isA<InvalidJobTransitionException>()));
    });

    test('operations on a missing job throw JobNotFoundException', () async {
      await expectLater(t.repo.markRunning('nope'), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.completeJob('nope', testSummary()), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.failJob('nope', JobFailureKind.generationFailed), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.cancelJob('nope'), throwsA(isA<JobNotFoundException>()));
      expect(await t.repo.getJob('nope'), isNull);
    });
  });


  group('createJob per source type', () {
    test('a YouTube job needs a URL and starts without a transcript', () async {
      final job = await t.repo.createJob(
        NewJobDraft.youtube(url: '  https://youtu.be/abc  ', language: ContentLanguage.en, title: 'Lecture'),
      );
      expect(job.sourceType, JobSourceType.youtube);
      expect(job.sourceUrl, 'https://youtu.be/abc');
      expect(job.sourceTitle, 'Lecture');
      expect(job.transcript, isNull, reason: 'there is nothing to transcribe until the video is fetched');
      expect(job.summaryLanguage, ContentLanguage.en, reason: 'defaults to the source language');

      final listed = (await t.repo.watchJobs(const JobsQuery()).first).single;
      expect(listed.sourceTitle, 'Lecture');
      expect(listed.preview, isNull);
    });

    test('an audio job keeps its file, duration and a separate summary language', () async {
      final job = await t.repo.createJob(
        NewJobDraft.media(
          type: JobSourceType.audio,
          filePath: '/app/files/a.m4a',
          language: ContentLanguage.ar,
          summaryLanguage: ContentLanguage.en,
          mimeType: 'audio/mp4',
          durationSeconds: 1800,
        ),
      );
      final stored = (await t.repo.getJob(job.id))!;
      expect(stored.sourceFilePath, '/app/files/a.m4a');
      expect(stored.sourceMimeType, 'audio/mp4');
      expect(stored.durationSeconds, 1800);
      expect(stored.sourceLanguage, ContentLanguage.ar);
      expect(stored.summaryLanguage, ContentLanguage.en);
      expect(stored.transcript, isNull);
    });

    test('each source type must bring its own input', () async {
      await expectLater(t.repo.createJob(NewJobDraft.youtube(url: '  ', language: ContentLanguage.en)), throwsArgumentError);
      await expectLater(
        t.repo.createJob(NewJobDraft.media(type: JobSourceType.video, filePath: '', language: ContentLanguage.en)),
        throwsArgumentError,
      );
      expect(await t.repo.watchJobs(const JobsQuery()).first, isEmpty);
    });
  });

  group('transcript and source updates while a job runs', () {
    test('saveTranscript stores the text, its metadata, and refreshes the list preview', () async {
      final job = await t.repo.createJob(
        NewJobDraft.media(type: JobSourceType.audio, filePath: '/f.m4a', language: ContentLanguage.ar),
      );
      await t.repo.markRunning(job.id);
      await t.repo.saveTranscript(
        job.id,
        const Transcript(text: 'نص مفرّغ من الصوت', wordCount: 4, modelName: 'whisper', modelVersion: 'small'),
      );

      final stored = (await t.repo.getJob(job.id))!;
      expect(stored.transcript!.text, 'نص مفرّغ من الصوت');
      expect(stored.transcript!.modelName, 'whisper');
      expect(stored.transcript!.modelVersion, 'small');
      expect((await t.repo.watchJobs(const JobsQuery()).first).single.preview, 'نص مفرّغ من الصوت');
      expect((await t.repo.watchJobs(const JobsQuery(text: 'مفرّغ')).first), hasLength(1), reason: 'searchable once stored');
    });

    test('saving again replaces the transcript', () async {
      final job = await t.repo.createJob(draft('النص الأول'));
      await t.repo.saveTranscript(job.id, const Transcript(text: 'النص الثاني', wordCount: 2));
      expect((await t.repo.getJob(job.id))!.transcript!.text, 'النص الثاني');
    });

    test('updateSourceInfo changes only the fields it is given', () async {
      final job = await t.repo.createJob(
        NewJobDraft.youtube(url: 'https://youtu.be/x', language: ContentLanguage.en, title: 'Old title'),
      );
      await t.repo.updateSourceInfo(job.id, const SourceInfo(filePath: '/dl/v.mp4', durationSeconds: 95.5));
      var stored = (await t.repo.getJob(job.id))!;
      expect(stored.sourceFilePath, '/dl/v.mp4');
      expect(stored.durationSeconds, 95.5);
      expect(stored.sourceTitle, 'Old title', reason: 'untouched');
      expect(stored.sourceUrl, 'https://youtu.be/x', reason: 'untouched');

      await t.repo.updateSourceInfo(job.id, const SourceInfo(title: 'New title', mimeType: 'video/mp4'));
      stored = (await t.repo.getJob(job.id))!;
      expect(stored.sourceTitle, 'New title');
      expect(stored.sourceMimeType, 'video/mp4');
      expect(stored.sourceFilePath, '/dl/v.mp4', reason: 'earlier values survive a later partial update');
    });

    test('a finished job can no longer be changed', () async {
      final job = await t.repo.createJob(draft('نص'));
      await t.repo.completeJob(job.id, testSummary());
      await expectLater(
        t.repo.saveTranscript(job.id, const Transcript(text: 'x', wordCount: 1)),
        throwsA(isA<InvalidJobTransitionException>()),
      );
      await expectLater(t.repo.updateSourceInfo(job.id, const SourceInfo(title: 'x')), throwsA(isA<InvalidJobTransitionException>()));
      expect((await t.repo.getJob(job.id))!.transcript!.text, 'نص');
    });

    test('a missing job is reported', () async {
      await expectLater(t.repo.saveTranscript('nope', const Transcript(text: 'x', wordCount: 1)), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.updateSourceInfo('nope', const SourceInfo(title: 'x')), throwsA(isA<JobNotFoundException>()));
    });
  });

  group('deleting a job removes its stored source file', () {
    late List<String> removed;
    late TestRepo files;

    setUp(() {
      removed = [];
      files = TestRepo(db, removeFile: (path) async => removed.add(path));
    });

    test('the file goes with the job', () async {
      final job = await files.repo.createJob(
        NewJobDraft.media(type: JobSourceType.audio, filePath: '/app/files/a.m4a', language: ContentLanguage.ar),
      );
      await files.repo.deleteJob(job.id);
      expect(removed, ['/app/files/a.m4a']);
      expect(await files.repo.getJob(job.id), isNull);
    });

    test('a file fetched later (for example a downloaded video) is removed too', () async {
      final job = await files.repo.createJob(NewJobDraft.youtube(url: 'https://youtu.be/x', language: ContentLanguage.en));
      await files.repo.updateSourceInfo(job.id, const SourceInfo(filePath: '/dl/v.mp4'));
      await files.repo.deleteJob(job.id);
      expect(removed, ['/dl/v.mp4']);
    });

    test('the web address is never treated as a file, and text jobs remove nothing', () async {
      final yt = await files.repo.createJob(NewJobDraft.youtube(url: 'https://youtu.be/x', language: ContentLanguage.en));
      final text = await files.repo.createJob(draft('نص'));
      await files.repo.deleteJob(yt.id);
      await files.repo.deleteJob(text.id);
      expect(removed, isEmpty);
    });

    test('the file is removed only after the row is gone', () async {
      final job = await files.repo.createJob(
        NewJobDraft.media(type: JobSourceType.video, filePath: '/v.mp4', language: ContentLanguage.ar),
      );
      Object? rowStillThere;
      final ordered = TestRepo(db, removeFile: (path) async => rowStillThere = await db.jobsDao.getDetail(job.id));
      await ordered.repo.deleteJob(job.id);
      expect(rowStillThere, isNull, reason: 'the row was already deleted when the file removal ran');
    });

    test('deleting a missing job removes nothing', () async {
      await files.repo.deleteJob('nope');
      expect(removed, isEmpty);
    });
  });

  group('deleteJob', () {
    test('removes the job; deleting again is a no-op', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.deleteJob('job-1');
      await t.repo.deleteJob('job-1');
      expect(await t.repo.getJob('job-1'), isNull);
      expect(await t.repo.watchJobs(const JobsQuery()).first, isEmpty);
    });
  });

  group('recoverInterruptedJobs', () {
    test('fails pending and running jobs as interrupted and leaves final ones alone', () async {
      for (final text in ['pending', 'running', 'done', 'cancelled']) {
        await t.repo.createJob(draft(text));
      }
      await t.repo.markRunning('job-2');
      await t.repo.completeJob('job-3', testSummary());
      await t.repo.cancelJob('job-4');

      expect(await t.repo.recoverInterruptedJobs(), 2);

      Future<JobDetailEntity> job(String id) async => (await t.repo.getJob(id))!;
      expect((await job('job-1')).status, JobRunStatus.failed);
      expect((await job('job-1')).failureKind, JobFailureKind.interrupted);
      expect((await job('job-2')).failureKind, JobFailureKind.interrupted);
      expect((await job('job-3')).status, JobRunStatus.completed);
      expect((await job('job-4')).status, JobRunStatus.cancelled);
      expect(await t.repo.recoverInterruptedJobs(), 0, reason: 'idempotent');
    });
  });

  group('watching', () {
    test('watchJobs reflects creates, transitions and deletes live', () async {
      final seen = <List<JobRunStatus>>[];
      final sub = t.repo.watchJobs(const JobsQuery()).listen((jobs) => seen.add([for (final JobEntity j in jobs) j.status]));
      await pumpEventQueue();
      await t.repo.createJob(draft('نص'));
      await pumpEventQueue();
      await t.repo.markRunning('job-1');
      await pumpEventQueue();
      await t.repo.deleteJob('job-1');
      await pumpEventQueue();
      await sub.cancel();

      expect(seen, containsAllInOrder([
        <JobRunStatus>[],
        [JobRunStatus.pending],
        [JobRunStatus.running],
        <JobRunStatus>[],
      ]));
    });

    test('watchJob emits each change, then null after deletion', () async {
      await t.repo.createJob(draft('نص'));
      final statuses = <JobRunStatus?>[];
      final sub = t.repo.watchJob('job-1').listen((j) => statuses.add(j?.status));
      await pumpEventQueue();
      await t.repo.markRunning('job-1');
      await pumpEventQueue();
      await t.repo.completeJob('job-1', testSummary());
      await pumpEventQueue();
      await t.repo.deleteJob('job-1');
      await pumpEventQueue();
      await sub.cancel();
      expect(statuses, [JobRunStatus.pending, JobRunStatus.running, JobRunStatus.completed, null]);
    });

    test('a write to another job does not re-emit an unchanged list or detail', () async {
      await t.repo.createJob(draft('الأول')); // job-1
      var listEmissions = 0;
      var detailEmissions = 0;
      final listSub = t.repo.watchJobs(const JobsQuery(text: 'الأول')).listen((_) => listEmissions++);
      final detailSub = t.repo.watchJob('job-1').listen((_) => detailEmissions++);
      await pumpEventQueue();
      expect((listEmissions, detailEmissions), (1, 1));

      // Writes that do not change what these queries return.
      await t.repo.createJob(draft('الثاني')); // job-2
      await t.repo.markRunning('job-2');
      await t.repo.cancelJob('job-2');
      await pumpEventQueue();
      expect(detailEmissions, 1, reason: 'job-1 did not change');
      expect(listEmissions, 1, reason: 'the filtered list did not change');

      await t.repo.markRunning('job-1');
      await pumpEventQueue();
      expect(detailEmissions, 2, reason: 'a real change still emits');
      expect(listEmissions, 2);
      await listSub.cancel();
      await detailSub.cancel();
    });

    test('watchJobs orders newest first', () async {
      await t.repo.createJob(draft('first'));
      await t.repo.createJob(draft('second'));
      final ids = (await t.repo.watchJobs(const JobsQuery()).first).map((j) => j.id);
      expect(ids, ['job-2', 'job-1']);
    });
  });

  group('storage failures are wrapped', () {
    test('a failing database surfaces as JobStorageException, never a raw driver error', () async {
      final broken = JobsRepositoryImpl(
        FaultyJobsLocalDataSource.everything(JobsLocalDataSourceImpl(db.jobsDao)),
        newId: () => 'x',
      );
      await expectLater(broken.getJob('a'), throwsA(isA<JobStorageException>()));
      await expectLater(broken.createJob(draft('نص')), throwsA(isA<JobStorageException>()));
      await expectLater(broken.markRunning('a'), throwsA(isA<JobStorageException>()));
      await expectLater(broken.completeJob('a', testSummary()), throwsA(isA<JobStorageException>()));
      await expectLater(broken.saveTranscript('a', const Transcript(text: 't', wordCount: 1)), throwsA(isA<JobStorageException>()));
      await expectLater(broken.updateSourceInfo('a', const SourceInfo(title: 't')), throwsA(isA<JobStorageException>()));
      await expectLater(broken.deleteJob('a'), throwsA(isA<JobStorageException>()));
      await expectLater(broken.recoverInterruptedJobs(), throwsA(isA<JobStorageException>()));
      await expectLater(broken.watchJobs(const JobsQuery()), emitsError(isA<JobStorageException>()));
      await expectLater(broken.watchJob('a'), emitsError(isA<JobStorageException>()));
    });
  });
}
