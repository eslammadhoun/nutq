import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';

import '../support/faulty_jobs_local_data_source.dart';
import '../support/job_fixtures.dart';

class _RecordingScheduler implements JobScheduler {
  final enqueued = <String>[];

  @override
  void enqueue(String jobId) => enqueued.add(jobId);

  @override
  Future<void> cancel(String jobId) async {}

  @override
  Stream<JobLive?> watchLive(String jobId) => const Stream.empty();
}

void main() {
  late AppDatabase db;
  late TestRepo t;
  late _RecordingScheduler scheduler;

  setUp(() {
    db = newTestDatabase();
    t = TestRepo(db);
    scheduler = _RecordingScheduler();
  });
  tearDown(() => db.close());

  test('saves the job first, then queues exactly that job', () async {
    final job = await SubmitJob(t.repo, scheduler)(draft('نص للتلخيص'));

    expect(scheduler.enqueued, [job.id]);
    final stored = (await t.repo.getJob(job.id))!;
    expect(stored.status, JobRunStatus.pending, reason: 'stored before anything runs');
    expect(stored.transcript!.text, 'نص للتلخيص');
  });

  test('the job is in storage by the time it is queued', () async {
    final order = <String>[];
    final probe = _ProbingScheduler((id) async => order.add((await t.repo.getJob(id)) != null ? 'stored' : 'missing'));
    await SubmitJob(t.repo, probe)(draft('نص'));
    await pumpEventQueue();
    expect(order, ['stored']);
  });

  test('a job that cannot be created is not queued', () async {
    await expectLater(SubmitJob(t.repo, scheduler)(draft('   ')), throwsArgumentError);
    expect(scheduler.enqueued, isEmpty);

    final broken = JobsRepositoryImpl(
      FaultyJobsLocalDataSource(JobsLocalDataSourceImpl(db.jobsDao), {Fault.insertJob}),
      newId: () => 'x',
    );
    await expectLater(SubmitJob(broken, scheduler)(draft('نص')), throwsA(isA<JobStorageException>()));
    expect(scheduler.enqueued, isEmpty);
  });

  test('each submission is queued separately, in order', () async {
    final submit = SubmitJob(t.repo, scheduler);
    final a = await submit(draft('أ'));
    final b = await submit(draft('ب'));
    expect(scheduler.enqueued, [a.id, b.id]);
  });
}

class _ProbingScheduler extends _RecordingScheduler {
  _ProbingScheduler(this._onEnqueue);

  final Future<void> Function(String id) _onEnqueue;

  @override
  void enqueue(String jobId) => _onEnqueue(jobId);
}
