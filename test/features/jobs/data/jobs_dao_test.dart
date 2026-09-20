import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summary_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

import '../support/job_fixtures.dart';

void main() {
  late AppDatabase db;
  late JobsDao dao;

  setUp(() {
    db = newTestDatabase();
    dao = db.jobsDao;
  });
  tearDown(() => db.close());

  final t0 = DateTime.utc(2026, 9, 20, 12);

  Future<void> insert(
    String id, {
    DateTime? at,
    String text = 'نص',
    String? preview,
    JobRunStatus status = JobRunStatus.pending,
    SummaryLanguage language = SummaryLanguage.ar,
  }) => dao.insertJob(
    JobsCompanion.insert(
      id: id,
      status: status,
      sourceType: JobSourceType.text,
      language: language,
      requestedLength: SummaryLength.medium,
      createdAt: at ?? t0,
      updatedAt: at ?? t0,
      preview: Value(preview ?? text),
    ),
    JobTranscriptsCompanion.insert(jobId: id, content: text, wordCount: 1),
  );

  JobSummariesCompanion summary(String id, {List<String> takeaways = const ['a']}) => JobSummariesCompanion.insert(
    jobId: id,
    summaryText: 'ملخص',
    takeaways: takeaways,
    modelName: 'm',
    promptVersion: 'v1',
  );

  test('schema version and foreign keys are set up', () async {
    expect(db.schemaVersion, 1);
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.single, 1);
  });

  group('insert / read', () {
    test('a job and its transcript round-trip through the join', () async {
      await insert('a', text: 'مرحبا بالعالم', language: SummaryLanguage.en);
      final rows = (await dao.getDetail('a'))!;
      expect(rows.job.status, JobRunStatus.pending);
      expect(rows.job.language, SummaryLanguage.en);
      expect(rows.job.requestedLength, SummaryLength.medium);
      expect(rows.job.createdAt.toUtc(), t0);
      expect(rows.transcript!.content, 'مرحبا بالعالم');
      expect(rows.summary, isNull);
    });

    test('reading a missing job returns null', () async {
      expect(await dao.getDetail('nope'), isNull);
    });

    test('inserting the same id twice fails and leaves no orphan transcript', () async {
      await insert('a');
      await expectLater(insert('a'), throwsA(isA<Exception>()));
      final transcripts = await db.select(db.jobTranscripts).get();
      expect(transcripts, hasLength(1));
    });

    test('the job and transcript insert is atomic', () async {
      await expectLater(
        dao.insertJob(
          JobsCompanion.insert(
            id: 'x',
            status: JobRunStatus.pending,
            sourceType: JobSourceType.text,
            language: SummaryLanguage.ar,
            requestedLength: SummaryLength.medium,
            createdAt: t0,
            updatedAt: t0,
          ),
          JobTranscriptsCompanion.insert(jobId: 'x', content: 'c', wordCount: -1),
        ),
        throwsA(isA<Exception>()),
      );
      expect(await dao.getDetail('x'), isNull, reason: 'the job row was rolled back');
    });

    test('a transcript for a missing job is rejected (foreign keys enforced)', () async {
      await expectLater(
        db.into(db.jobTranscripts).insert(JobTranscriptsCompanion.insert(jobId: 'ghost', content: 'c', wordCount: 1)),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('watchJobs', () {
    test('newest first, with a stable tie-break on id', () async {
      await insert('old', at: t0);
      await insert('b', at: t0.add(const Duration(hours: 1)));
      await insert('a', at: t0.add(const Duration(hours: 1)));
      final ids = (await dao.watchJobs(const JobsQuery()).first).map((j) => j.id);
      expect(ids, ['b', 'a', 'old']);
    });

    test('filters by status set', () async {
      await insert('p', status: JobRunStatus.pending);
      await insert('c', status: JobRunStatus.completed);
      await insert('f', status: JobRunStatus.failed);
      final done = await dao.watchJobs(const JobsQuery(statuses: {JobRunStatus.completed})).first;
      expect(done.map((j) => j.id), ['c']);
      final two = await dao.watchJobs(const JobsQuery(statuses: {JobRunStatus.completed, JobRunStatus.failed})).first;
      expect(two.map((j) => j.id).toSet(), {'c', 'f'});
    });

    test('limits the number of rows', () async {
      for (var i = 0; i < 5; i++) {
        await insert('j$i', at: t0.add(Duration(minutes: i)));
      }
      final rows = await dao.watchJobs(const JobsQuery(limit: 3)).first;
      expect(rows.map((j) => j.id), ['j4', 'j3', 'j2']);
    });

    test('search matches the preview or the full transcript text', () async {
      await insert('p', text: 'كلمة نادرة في النص الكامل هنا', preview: 'بداية النص');
      await insert('q', text: 'شيء آخر', preview: 'موضوع الميزانية');
      expect((await dao.watchJobs(const JobsQuery(text: 'الميزانية')).first).map((j) => j.id), ['q']);
      expect((await dao.watchJobs(const JobsQuery(text: 'نادرة')).first).map((j) => j.id), ['p']);
      expect(await dao.watchJobs(const JobsQuery(text: 'لا شيء')).first, isEmpty);
    });

    test('blank search returns everything', () async {
      await insert('a');
      await insert('b');
      expect(await dao.watchJobs(const JobsQuery(text: '   ')).first, hasLength(2));
    });

    test('LIKE wildcards in the search text are matched literally', () async {
      await insert('pct', text: 'ارتفعت 50% هذا العام');
      await insert('under', text: 'snake_case name');
      await insert('other', text: 'plain text');
      expect((await dao.watchJobs(const JobsQuery(text: '50%')).first).map((j) => j.id), ['pct']);
      expect((await dao.watchJobs(const JobsQuery(text: 'snake_case')).first).map((j) => j.id), ['under']);
      expect(await dao.watchJobs(const JobsQuery(text: '%')).first, hasLength(1), reason: '% only matches a literal percent sign');
      expect(await dao.watchJobs(const JobsQuery(text: '_')).first, hasLength(1), reason: '_ only matches a literal underscore');
      expect(await dao.watchJobs(const JobsQuery(text: r'\')).first, isEmpty);
    });

    test('status filter and search combine', () async {
      await insert('a', text: 'ميزانية', status: JobRunStatus.completed);
      await insert('b', text: 'ميزانية', status: JobRunStatus.failed);
      final rows = await dao.watchJobs(const JobsQuery(text: 'ميزانية', statuses: {JobRunStatus.failed})).first;
      expect(rows.map((j) => j.id), ['b']);
    });

    test('the stream re-emits when rows change', () async {
      final emissions = <List<String>>[];
      final sub = dao.watchJobs(const JobsQuery()).listen((rows) => emissions.add([for (final r in rows) r.id]));
      await pumpEventQueue();
      await insert('a');
      await pumpEventQueue();
      await dao.deleteJob('a');
      await pumpEventQueue();
      await sub.cancel();
      expect(emissions, containsAllInOrder([<String>[], ['a'], <String>[]]));
    });
  });

  group('transitions', () {
    test('applies only from an allowed state', () async {
      await insert('a');
      expect(
        await dao.transition('a', from: {JobRunStatus.pending}, to: JobRunStatus.running, at: t0),
        TransitionOutcome.applied,
      );
      expect(
        await dao.transition('a', from: {JobRunStatus.pending}, to: JobRunStatus.running, at: t0),
        TransitionOutcome.invalidState,
      );
      expect((await dao.getDetail('a'))!.job.status, JobRunStatus.running);
    });

    test('a missing job is reported as not found', () async {
      expect(
        await dao.transition('zz', from: {JobRunStatus.pending}, to: JobRunStatus.running, at: t0),
        TransitionOutcome.notFound,
      );
    });

    test('records the failure kind and updates updatedAt', () async {
      await insert('a');
      final later = t0.add(const Duration(minutes: 5));
      await dao.transition(
        'a',
        from: {JobRunStatus.pending},
        to: JobRunStatus.failed,
        at: later,
        failureKind: SummarizationFailureKind.modelUnavailable,
      );
      final job = (await dao.getDetail('a'))!.job;
      expect(job.failureKind, SummarizationFailureKind.modelUnavailable);
      expect(job.updatedAt.toUtc(), later);
      expect(job.createdAt.toUtc(), t0);
    });
  });

  group('completeJob', () {
    test('writes the summary and the status together', () async {
      await insert('a', status: JobRunStatus.running);
      final outcome = await dao.completeJob('a', summary('a', takeaways: ['نقطة "١"', 'two, three', "it's"]), t0);
      expect(outcome, TransitionOutcome.applied);
      final rows = (await dao.getDetail('a'))!;
      expect(rows.job.status, JobRunStatus.completed);
      expect(rows.summary!.summaryText, 'ملخص');
      expect(rows.summary!.takeaways, ['نقطة "١"', 'two, three', "it's"], reason: 'JSON round-trip keeps order and quoting');
      expect(rows.summary!.needsReview, isFalse);
    });

    test('is rejected — and writes nothing — when the job is not active', () async {
      await insert('a', status: JobRunStatus.cancelled);
      expect(await dao.completeJob('a', summary('a'), t0), TransitionOutcome.invalidState);
      expect((await dao.getDetail('a'))!.summary, isNull);
      expect((await dao.getDetail('a'))!.job.status, JobRunStatus.cancelled);
    });

    test('reports a missing job', () async {
      expect(await dao.completeJob('zz', summary('zz'), t0), TransitionOutcome.notFound);
    });
  });

  group('delete', () {
    test('cascades to the transcript and summary', () async {
      await insert('a', status: JobRunStatus.running);
      await dao.completeJob('a', summary('a'), t0);
      await insert('keep');
      expect(await dao.deleteJob('a'), 1);
      expect(await db.select(db.jobTranscripts).get(), hasLength(1));
      expect(await db.select(db.jobSummaries).get(), isEmpty);
      expect(await dao.getDetail('a'), isNull);
      expect(await dao.getDetail('keep'), isNotNull);
    });

    test('deleting a missing job affects nothing', () async {
      expect(await dao.deleteJob('zz'), 0);
    });

    test('a watched job emits null once deleted', () async {
      await insert('a');
      final emissions = <bool>[];
      final sub = dao.watchDetail('a').listen((r) => emissions.add(r != null));
      await pumpEventQueue();
      await dao.deleteJob('a');
      await pumpEventQueue();
      await sub.cancel();
      expect(emissions, [true, false]);
    });
  });

  test('failActiveJobs fails pending and running jobs only', () async {
    await insert('p', status: JobRunStatus.pending);
    await insert('r', status: JobRunStatus.running);
    await insert('c', status: JobRunStatus.completed);
    await insert('x', status: JobRunStatus.cancelled);
    expect(await dao.failActiveJobs(SummarizationFailureKind.interrupted, t0), 2);
    Future<JobRunStatus> status(String id) async => (await dao.getDetail(id))!.job.status;
    expect(await status('p'), JobRunStatus.failed);
    expect(await status('r'), JobRunStatus.failed);
    expect(await status('c'), JobRunStatus.completed);
    expect(await status('x'), JobRunStatus.cancelled);
    expect((await dao.getDetail('p'))!.job.failureKind, SummarizationFailureKind.interrupted);
  });

  test('large transcripts survive storage intact', () async {
    final big = List.generate(50000, (i) => 'كلمة$i').join(' ');
    await insert('big', text: big, preview: 'p');
    expect((await dao.getDetail('big'))!.transcript!.content, big);
    final list = await dao.watchJobs(const JobsQuery()).first;
    expect(list.single.preview, 'p', reason: 'list rows carry only the preview');
  });
}
