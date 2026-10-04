import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/services/job_runner.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source_registry.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/jobs/support/job_fixtures.dart';

/// The app's wiring, exercised with an in-memory database: everything the UI
/// asks for must resolve, and nothing may touch the model or platform plugins
/// until it is used.
void main() {
  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await setupDI(openDatabase: () => AppDatabase.forTesting(NativeDatabase.memory()));
  });

  tearDown(() => sl.reset());

  test('every cubit the screens ask for resolves', () async {
    final jobs = sl<JobsCubit>();
    final newJob = sl<NewJobCubit>();
    final detail = sl<JobDetailCubit>(param1: 'some-job');
    addTearDown(() async {
      await jobs.close();
      await newJob.close();
      await detail.close();
    });
    expect(detail.jobId, 'some-job');
  });

  test('cubits are new instances each time; services are shared', () {
    expect(identical(sl<JobsCubit>(), sl<JobsCubit>()), isFalse);
    expect(identical(sl<JobsRepository>(), sl<JobsRepository>()), isTrue);
    expect(identical(sl<JobRunner>(), sl<JobRunner>()), isTrue);
    expect(identical(sl<SummarizationRepository>(), sl<SummarizationRepository>()), isTrue);
  });

  test('the scheduler the UI talks to is the one runner that processes jobs', () {
    expect(identical(sl<JobScheduler>(), sl<JobRunner>()), isTrue);
  });

  test('only sources that are registered can be submitted', () {
    expect(sl<TranscriptSourceRegistry>().supportedTypes, {JobSourceType.text});
    expect(sl<NewJobCubit>().state.supportedSources, {JobSourceType.text});
  });

  test('a job submitted through the wired stack is saved and queued', () async {
    final job = await sl<SubmitJob>()(draft('نص للتلخيص'));
    final stored = await sl<JobsRepository>().getJob(job.id);
    expect(stored!.transcript!.text, 'نص للتلخيص');
  });

  test('resolving the summarization stack does not load the model', () {
    // Constructing (not using) these must not touch the LiteRT plugin: the
    // model loads lazily on the first job.
    sl<SummarizationRepository>();
    sl<SubmitJob>();
  });

  test('resetting disposes the runner and closes the database without errors', () async {
    sl<JobRunner>();
    sl<AppDatabase>();
    await sl.reset();
  });
}
