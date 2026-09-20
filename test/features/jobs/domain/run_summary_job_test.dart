import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/usecases/run_summary_job.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_language.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../summarization/support/fake_gemma.dart';
import '../support/job_fixtures.dart';

const _config = SummarizationConfig(targetTokens: 60, overlapTokens: 10, minTokens: 30, maxTokens: 90);
final _text = List.generate(
  6,
  (i) => 'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024 وقال الدكتور أحمد محمد إن النتائج جيدة.',
).join('\n\n');

void main() {
  late AppDatabase db;
  late TestRepo t;
  late FakeGemma gemma;
  late RunSummaryJob runJob;

  setUp(() {
    db = newTestDatabase();
    t = TestRepo(db);
    gemma = FakeGemma();
    final summarization = SummarizationRepositoryImpl(dataSource: gemma);
    runJob = RunSummaryJob(
      jobs: t.repo,
      summarize: SummarizeTranscript(repository: summarization),
      summarization: summarization,
      config: _config,
    );
  });
  tearDown(() => db.close());

  Future<JobRunStatus> statusOf(String id) async => (await t.repo.getJob(id))!.status;

  test('runs a pending job to completion and saves the summary', () async {
    await t.repo.createJob(draft(_text));
    final events = await runJob('job-1').events.toList();

    final job = (await t.repo.getJob('job-1'))!;
    expect(job.status, JobRunStatus.completed);
    expect(job.summary!.summaryText, 'الملخص النهائي للمحاضرة');
    expect(job.summary!.takeaways, ['فكرة رئيسية عن الموضوع']);
    expect(job.failureKind, isNull);

    final progress = events.whereType<JobRunProgress>().map((e) => e.progress.stage).toList();
    expect(progress.first, SummarizationStage.preparing);
    expect(progress, contains(SummarizationStage.finalizing));
    expect(events.whereType<JobRunPartialSummary>(), isNotEmpty, reason: 'the final summary streams as partial text');
    expect(events.whereType<JobRunPartialSummary>().last.text, 'الملخص النهائي للمحاضرة');
  });

  test('the job is "running" while the pipeline works, and only then completed', () async {
    await t.repo.createJob(draft(_text));
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 2) await gate.future;
      return null;
    };
    final done = runJob('job-1').events.drain<void>();
    await pumpEventQueue();
    expect(await statusOf('job-1'), JobRunStatus.running);

    gate.complete();
    await done;
    expect(await statusOf('job-1'), JobRunStatus.completed);
  });

  test('a pipeline failure marks the job failed with the failure kind', () async {
    await t.repo.createJob(draft(_text));
    gemma.responder = (prompt, call) async {
      if (prompt.contains('final summary of a full lecture')) throw const GemmaGenerationException('x');
      return null;
    };
    await runJob('job-1').events.drain<void>();

    final job = (await t.repo.getJob('job-1'))!;
    expect(job.status, JobRunStatus.failed);
    expect(job.failureKind, SummarizationFailureKind.generationFailed);
    expect(job.summary, isNull);
  });

  test('an unexpected error is recorded as failed, not left running', () async {
    await t.repo.createJob(draft(_text));
    gemma.responder = (prompt, call) async => throw StateError('surprise');
    await runJob('job-1').events.drain<void>();
    expect(await statusOf('job-1'), JobRunStatus.failed);
  });

  test('cancel() stops the model and records the job as cancelled', () async {
    await t.repo.createJob(draft(_text));
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    final run = runJob('job-1');
    final done = run.events.drain<void>();
    await pumpEventQueue();

    await run.cancel();
    expect(gemma.cancelled, isTrue);
    gate.complete();
    await done;

    expect(await statusOf('job-1'), JobRunStatus.cancelled);
    expect(gemma.calls, 1, reason: 'no further model calls after cancelling');
    expect((await t.repo.getJob('job-1'))!.summary, isNull);
  });

  test('cancelling the event subscription (screen closed) cancels the job and the model', () async {
    await t.repo.createJob(draft(_text));
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    final events = <JobRunEvent>[];
    final sub = runJob('job-1').events.listen(events.add);
    await pumpEventQueue();
    expect(await statusOf('job-1'), JobRunStatus.running);

    unawaited(sub.cancel());
    gate.complete();
    await pumpEventQueue(times: 50);

    expect(gemma.cancelled, isTrue);
    expect(await statusOf('job-1'), JobRunStatus.cancelled);
  });

  test('a job that is not pending is left alone', () async {
    await t.repo.createJob(draft(_text));
    await t.repo.cancelJob('job-1');
    final events = await runJob('job-1').events.toList();
    expect(events, isEmpty);
    expect(gemma.calls, 0);
    expect(await statusOf('job-1'), JobRunStatus.cancelled);
  });

  test('running a job twice does not run the pipeline twice', () async {
    await t.repo.createJob(draft(_text));
    await runJob('job-1').events.drain<void>();
    final callsAfterFirst = gemma.calls;
    await runJob('job-1').events.drain<void>();
    expect(gemma.calls, callsAfterFirst);
  });

  test('a missing job is reported', () async {
    await expectLater(runJob('nope').events, emitsError(isA<JobNotFoundException>()));
  });

  test('a job deleted mid-run does not crash the run', () async {
    await t.repo.createJob(draft(_text));
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    final done = runJob('job-1').events.drain<void>();
    await pumpEventQueue();
    await t.repo.deleteJob('job-1');
    gate.complete();
    await done; // completes without throwing
    expect(await t.repo.getJob('job-1'), isNull);
  });

  test('the job language and length drive the pipeline', () async {
    await t.repo.createJob(draft('Attendance reached 250 people in 2024. The team said results were good.', language: SummaryLanguage.en));
    await runJob('job-1').events.drain<void>();
    expect(gemma.prompts.every((p) => p.contains('English')), isTrue);
    expect(gemma.prompts.last, contains('250-400 English words'), reason: 'medium length');
  });
}
