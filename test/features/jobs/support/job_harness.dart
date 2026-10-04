import 'dart:async';

import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/services/job_runner.dart';
import 'package:nutq/features/jobs/domain/sources/text_transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source_registry.dart';
import 'package:nutq/features/jobs/domain/usecases/process_job.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../../support/sample_text.dart';
import '../../summarization/support/fake_gemma.dart';
import 'fake_media_files.dart';
import 'job_fixtures.dart';

/// A small per-call budget so a few paragraphs become several sections.
const testSummarizationConfig = SummarizationConfig(wordsPerCall: 8, debugLogging: false);

/// The real persistence, processing and queue stack (in-memory SQLite,
/// scripted model), wired the way the app wires it. The runner is started, so
/// a submitted job runs at once.
class JobHarness {
  /// [autoStart] starts the runner right away. Widget tests turn it off and
  /// start it inside `tester.runAsync`, because its startup database call
  /// needs real (not fake-async) time.
  JobHarness({Iterable<TranscriptSource> extraSources = const [], bool autoStart = true}) {
    db = newTestDatabase();
    repoFixture = TestRepo(db);
    gemma = FakeGemma();
    summarization = SummarizationRepositoryImpl(dataSource: gemma);
    registry = TranscriptSourceRegistry([const TextTranscriptSource(), ...extraSources]);
    processJob = ProcessJob(
      jobs: repoFixture.repo,
      sources: registry,
      summarize: SummarizeTranscript(repository: summarization),
      summarization: summarization,
      config: testSummarizationConfig,
    );
    runner = JobRunner(
      jobs: repoFixture.repo,
      process: processJob,
      partialInterval: const Duration(milliseconds: 10),
      // Earlier than any test job, so startup recovery never touches them.
      now: () => DateTime.utc(2000),
    );
    submitJob = SubmitJob(repoFixture.repo, runner);
    if (autoStart) unawaited(runner.start());
  }

  late final AppDatabase db;
  late final TestRepo repoFixture;
  late final FakeGemma gemma;
  late final SummarizationRepositoryImpl summarization;
  late final TranscriptSourceRegistry registry;
  late final ProcessJob processJob;
  late final JobRunner runner;
  late final SubmitJob submitJob;

  JobsRepositoryImpl get repo => repoFixture.repo;

  /// Saves a pending job without queueing it.
  Future<String> createJob(
    String text, {
    ContentLanguage language = ContentLanguage.ar,
  }) async => (await repo.createJob(draft(text, language: language))).id;

  /// Saves a job and queues it: the runner starts processing it.
  Future<String> submit(
    String text, {
    ContentLanguage language = ContentLanguage.ar,
  }) async => (await submitJob(draft(text, language: language))).id;

  JobDetailCubit detailCubit(String jobId) =>
      JobDetailCubit(repository: repo, scheduler: runner, jobId: jobId);

  JobsCubit jobsCubit({Duration searchDebounce = const Duration(milliseconds: 20)}) =>
      JobsCubit(repo, searchDebounce: searchDebounce);

  final media = FakeMediaFiles();

  NewJobCubit newJobCubit({Set<JobSourceType>? supportedSources}) => NewJobCubit(
    submitJob,
    media,
    supportedSources: supportedSources ?? registry.supportedTypes,
  );

  Future<void> dispose() async {
    await runner.dispose();
    await db.close();
  }
}

/// Six paragraphs of Arabic — several sections under [testSummarizationConfig].
final sampleTranscript = arabicTranscript(6);
