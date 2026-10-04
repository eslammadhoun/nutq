import 'package:get_it/get_it.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/utils/background_work.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/services/job_runner.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/domain/sources/text_transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source_registry.dart';
import 'package:nutq/features/jobs/domain/usecases/process_job.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/summarization/data/datasources/flutter_gemma_runtime.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final sl = GetIt.instance;

/// Registers everything. [openDatabase] and [preferences] exist so tests can
/// supply an in-memory database and mock preferences.
Future<void> setupDI({
  AppDatabase Function()? openDatabase,
  SharedPreferences? preferences,
}) async {
  final prefs = preferences ?? await SharedPreferences.getInstance();
  _registerCore(prefs, openDatabase ?? AppDatabase.new);
  _registerSummarization();
  _registerJobs();
}

void _registerCore(SharedPreferences prefs, AppDatabase Function() openDatabase) {
  sl
    ..registerLazySingleton<AppPreferences>(() => AppPreferences(prefs))
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()))
    ..registerLazySingleton<AppDatabase>(openDatabase, dispose: (db) => db.close());
}

/// On-device summarization (Gemma 3 1B fine-tuned for Arabic, LiteRT-LM).
void _registerSummarization() {
  sl
    ..registerLazySingleton<LlmRuntime>(FlutterGemmaRuntime.new)
    ..registerLazySingleton<GemmaLocalDataSource>(
      () => GemmaLocalDataSourceImpl(sl<LlmRuntime>()),
    )
    ..registerLazySingleton<SummarizationRepository>(
      () => SummarizationRepositoryImpl(dataSource: sl<GemmaLocalDataSource>()),
    )
    ..registerLazySingleton<SummarizeTranscript>(
      () => SummarizeTranscript(
        repository: sl<SummarizationRepository>(),
        background: const IsolateBackgroundWork(),
      ),
    );
}

/// Jobs: storage, the sources that can be processed, and the app-wide queue.
void _registerJobs() {
  sl
    ..registerLazySingleton<JobsLocalDataSource>(
      () => JobsLocalDataSourceImpl(sl<AppDatabase>().jobsDao),
    )
    ..registerLazySingleton<JobsRepository>(
      () => JobsRepositoryImpl(
        sl<JobsLocalDataSource>(),
        newId: () => const Uuid().v4(),
      ),
    )
    // Register a TranscriptSource here to make a new source type usable.
    ..registerLazySingleton<TranscriptSourceRegistry>(
      () => TranscriptSourceRegistry(const [TextTranscriptSource()]),
    )
    ..registerLazySingleton<ProcessJob>(
      () => ProcessJob(
        jobs: sl<JobsRepository>(),
        sources: sl<TranscriptSourceRegistry>(),
        summarize: sl<SummarizeTranscript>(),
        summarization: sl<SummarizationRepository>(),
      ),
    )
    ..registerLazySingleton<JobRunner>(
      () => JobRunner(
        jobs: sl<JobsRepository>(),
        process: sl<ProcessJob>(),
        // Free the model's memory once no job has run for a while.
        onIdle: sl<SummarizationRepository>().release,
      ),
      dispose: (runner) => runner.dispose(),
    )
    ..registerLazySingleton<JobScheduler>(() => sl<JobRunner>())
    ..registerLazySingleton<SubmitJob>(
      () => SubmitJob(sl<JobsRepository>(), sl<JobScheduler>()),
    )
    ..registerFactory<JobsCubit>(() => JobsCubit(sl<JobsRepository>()))
    ..registerFactory<NewJobCubit>(
      () => NewJobCubit(
        sl<SubmitJob>(),
        supportedSources: sl<TranscriptSourceRegistry>().supportedTypes,
      ),
    )
    ..registerFactoryParam<JobDetailCubit, String, void>(
      (jobId, _) => JobDetailCubit(
        repository: sl<JobsRepository>(),
        scheduler: sl<JobScheduler>(),
        jobId: jobId,
      ),
    );
}
