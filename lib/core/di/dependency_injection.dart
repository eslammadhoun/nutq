import 'package:get_it/get_it.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/usecases/run_summary_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl<AppPreferences>()),
  );

  // Local database and the jobs feature built on it.
  sl.registerLazySingleton<AppDatabase>(
    AppDatabase.new,
    dispose: (db) => db.close(),
  );
  sl.registerLazySingleton<JobsLocalDataSource>(
    () => JobsLocalDataSourceImpl(sl<AppDatabase>().jobsDao),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(
      sl<JobsLocalDataSource>(),
      newId: () => const Uuid().v4(),
    ),
  );
  sl.registerLazySingleton<RunSummaryJob>(
    () => RunSummaryJob(
      jobs: sl<JobsRepository>(),
      summarize: sl<SummarizeTranscript>(),
      summarization: sl<SummarizationRepository>(),
    ),
  );
  sl.registerFactory<JobsCubit>(() => JobsCubit(sl<JobsRepository>()));
  sl.registerFactory<NewJobCubit>(() => NewJobCubit(sl<JobsRepository>()));
  sl.registerFactoryParam<JobDetailCubit, String, void>(
    (jobId, _) => JobDetailCubit(
      repository: sl<JobsRepository>(),
      runJob: sl<RunSummaryJob>(),
      jobId: jobId,
    ),
  );

  // On-device summarization (Gemma 3 1B IT, LiteRT-LM).
  sl.registerLazySingleton<GemmaLocalDataSource>(GemmaLocalDataSourceImpl.new);
  sl.registerLazySingleton<SummarizationRepository>(
    () => SummarizationRepositoryImpl(dataSource: sl<GemmaLocalDataSource>()),
  );
  sl.registerLazySingleton<SummarizeTranscript>(
    () => SummarizeTranscript(repository: sl<SummarizationRepository>()),
  );
}
