import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';
import 'package:nutq/core/domain/content_language.dart';

import 'support/faulty_jobs_local_data_source.dart';
import 'support/job_harness.dart';

void main() {
  late JobHarness h;
  late NewJobCubit cubit;

  setUp(() {
    h = JobHarness();
    cubit = NewJobCubit(h.repo);
  });
  tearDown(() async {
    await cubit.close();
    await h.dispose();
  });

  test('only a non-empty text source can be submitted', () {
    expect(cubit.state.canSubmit, isFalse);

    cubit.setText('   ');
    expect(cubit.state.canSubmit, isFalse);

    cubit.setText('نص للتلخيص');
    expect(cubit.state.canSubmit, isTrue);

    cubit.changeSourceType(JobSourceType.youtube.index);
    cubit.setSourceUrl('https://www.youtube.com/watch?v=abcdefghijk');
    expect(cubit.state.isSourceSupported, isFalse);
    expect(cubit.state.canSubmit, isFalse);
  });

  test('submit saves a pending job and reports its id', () async {
    cubit.setText('  نص للتلخيص  ');
    await cubit.submit();

    expect(cubit.state.status, NewJobStatus.success);
    final id = cubit.state.submittedJobId!;
    final stored = (await h.repo.getJob(id))!;
    expect(stored.status, JobRunStatus.pending, reason: 'processing starts when the job is opened');
    expect(stored.transcript!.text, 'نص للتلخيص');
    expect(stored.sourceLanguage, ContentLanguage.ar);
  });

  test('the language toggle is saved with the job', () async {
    cubit.setText('Hello world');
    cubit.toggleLanguage();
    await cubit.submit();
    expect((await h.repo.getJob(cubit.state.submittedJobId!))!.sourceLanguage, ContentLanguage.en);
  });

  test('submitting twice creates one job', () async {
    cubit.setText('نص');
    await Future.wait([cubit.submit(), cubit.submit()]);
    await cubit.submit();
    expect(cubit.state.status, NewJobStatus.success);
    expect((await h.repo.watchJobs(const JobsQuery()).first), hasLength(1));
  });

  test('nothing is saved when the form is not submittable', () async {
    await cubit.submit();
    expect(cubit.state.status, NewJobStatus.idle);
    expect(cubit.state.submittedJobId, isNull);
  });

  test('a storage failure is reported and the sheet can retry', () async {
    final repo = JobsRepositoryImpl(FaultyJobsLocalDataSource(JobsLocalDataSourceImpl(h.db.jobsDao), {Fault.insertJob}), newId: () => 'x');
    final failing = NewJobCubit(repo);
    addTearDown(failing.close);
    failing.setText('نص');

    await failing.submit();
    expect(failing.state.status, NewJobStatus.failure);
    expect(failing.state.lastError, AppError.storage);
    expect(failing.state.submittedJobId, isNull);
    expect(failing.state.text, 'نص', reason: 'the user does not lose what they typed');

    await failing.submit();
    expect(failing.state.status, NewJobStatus.failure, reason: 'a failed submit can be attempted again');
  });
}
