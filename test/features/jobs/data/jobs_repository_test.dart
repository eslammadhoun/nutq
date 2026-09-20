import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/summarization/data/prompts/prompt_version.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';

import '../support/job_fixtures.dart';

SummaryResult _result({String summary = 'ملخص نهائي', List<String> keyPoints = const ['نقطة ١', 'نقطة ٢'], bool suspicious = false}) =>
    SummaryResult(
      summary: summary,
      keyPoints: keyPoints,
      validation: suspicious
          ? const ValidationReport(
              issues: [ValidationIssue(type: ValidationIssueType.numberMismatch, severity: ValidationSeverity.high, detail: '9')],
            )
          : const ValidationReport(),
      debug: const SummaryDebugInfo(
        jobId: 'x',
        chunkCount: 3,
        failedChunkCount: 0,
        processingTimeMs: 4200,
        inputTokens: 900,
        outputTokens: 300,
      ),
    );

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
      expect(job.language, ContentLanguage.ar);
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
        const NewJobDraft(text: 'hello world', language: ContentLanguage.en, length: SummaryLength.detailed),
      );
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.language, ContentLanguage.en);
      expect(job.requestedLength, SummaryLength.detailed);
    });
  });

  group('lifecycle', () {
    test('pending → running → completed saves the summary with its provenance', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.markRunning('job-1');
      expect((await t.repo.getJob('job-1'))!.status, JobRunStatus.running);

      await t.repo.completeJob('job-1', _result(suspicious: true));
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.status, JobRunStatus.completed);
      final Summary s = job.summary!;
      expect(s.summaryText, 'ملخص نهائي');
      expect(s.takeaways, ['نقطة ١', 'نقطة ٢']);
      expect(s.length, SummaryLength.medium);
      expect(s.modelName, summarizationModelId);
      expect(s.promptVersion, summarizationPromptVersion);
      expect(s.needsReview, isTrue);
      expect(s.tokensIn, 900);
      expect(s.tokensOut, 300);
      expect(s.processingTimeMs, 4200);
      expect(job.updatedAt.isAfter(job.createdAt), isTrue);
    });

    test('a pending job can complete directly (short runs)', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.completeJob('job-1', _result());
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

      await expectLater(t.repo.completeJob('job-1', _result()), throwsA(isA<InvalidJobTransitionException>()));
      await expectLater(t.repo.failJob('job-1', JobFailureKind.generationFailed), throwsA(isA<InvalidJobTransitionException>()));
      await expectLater(t.repo.markRunning('job-1'), throwsA(isA<InvalidJobTransitionException>()));
      final job = (await t.repo.getJob('job-1'))!;
      expect(job.status, JobRunStatus.cancelled);
      expect(job.summary, isNull, reason: 'a rejected completion leaves no summary behind');
    });

    test('a completed job cannot be cancelled or failed afterwards, so its summary is safe', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.completeJob('job-1', _result());

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
      await expectLater(t.repo.completeJob('job-1', _result()), throwsA(isA<InvalidJobTransitionException>()));
      expect((await t.repo.getJob('job-1'))!.status, JobRunStatus.failed);
    });

    test('markRunning is only valid from pending', () async {
      await t.repo.createJob(draft('نص'));
      await t.repo.markRunning('job-1');
      await expectLater(t.repo.markRunning('job-1'), throwsA(isA<InvalidJobTransitionException>()));
    });

    test('operations on a missing job throw JobNotFoundException', () async {
      await expectLater(t.repo.markRunning('nope'), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.completeJob('nope', _result()), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.failJob('nope', JobFailureKind.generationFailed), throwsA(isA<JobNotFoundException>()));
      await expectLater(t.repo.cancelJob('nope'), throwsA(isA<JobNotFoundException>()));
      expect(await t.repo.getJob('nope'), isNull);
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
      await t.repo.completeJob('job-3', _result());
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
      await t.repo.completeJob('job-1', _result());
      await pumpEventQueue();
      await t.repo.deleteJob('job-1');
      await pumpEventQueue();
      await sub.cancel();
      expect(statuses, [JobRunStatus.pending, JobRunStatus.running, JobRunStatus.completed, null]);
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
      final broken = JobsRepositoryImpl(_ThrowingDataSource(), newId: () => 'x');
      await expectLater(broken.getJob('a'), throwsA(isA<JobStorageException>()));
      await expectLater(broken.createJob(draft('نص')), throwsA(isA<JobStorageException>()));
      await expectLater(broken.markRunning('a'), throwsA(isA<JobStorageException>()));
      await expectLater(broken.deleteJob('a'), throwsA(isA<JobStorageException>()));
      await expectLater(broken.recoverInterruptedJobs(), throwsA(isA<JobStorageException>()));
      await expectLater(broken.watchJobs(const JobsQuery()), emitsError(isA<JobStorageException>()));
      await expectLater(broken.watchJob('a'), emitsError(isA<JobStorageException>()));
    });
  });
}

class _ThrowingDataSource implements JobsLocalDataSource {
  static final _boom = StateError('disk I/O error');

  @override
  Stream<List<JobEntity>> watchJobs(JobsQuery query) => Stream.error(_boom);

  @override
  Stream<JobDetailEntity?> watchJob(String id) => Stream.error(_boom);

  @override
  Future<JobDetailEntity?> getJob(String id) => Future.error(_boom);

  @override
  Future<void> insertJob(JobDetailEntity job) => Future.error(_boom);

  @override
  Future<TransitionOutcome> transition(String id, {required Set<JobRunStatus> from, required JobRunStatus to, required DateTime at, JobFailureKind? failureKind}) =>
      Future.error(_boom);

  @override
  Future<TransitionOutcome> completeJob(String id, Summary summary, DateTime at) => Future.error(_boom);

  @override
  Future<void> deleteJob(String id) => Future.error(_boom);

  @override
  Future<int> failActiveJobs(JobFailureKind kind, DateTime at) => Future.error(_boom);
}
