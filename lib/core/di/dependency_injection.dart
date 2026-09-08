import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/database/daos/jobs_dao.dart';
import 'package:nutq/core/database/daos/models_dao.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/features/jobs/data/datasources/file_picker_service.dart';
import 'package:nutq/features/models/presentation/cubit/models_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/dio/dio_config.dart';
import 'package:nutq/core/network/dio/dio_factory.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/data/sockets/job_updates_socket_service.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()));

  // Network stack — kept for the WS job-updates service (replaced by a
  // local orchestrator in a later workstream) and future URL/YouTube fetch.
  final dio = DioFactory(config: const DioConfig()).create();

  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // Local database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<JobsDao>(() => sl<AppDatabase>().jobsDao);
  sl.registerLazySingleton<ModelsDao>(() => sl<AppDatabase>().modelsDao);

  // On-device ASR model management (Models screen). `AsrPipeline`/
  // `WhisperIsolateEngine` are constructed by whoever runs a transcription
  // (a later workstream's `JobOrchestrator`) — not registered here since
  // nothing in this workstream drives them from the UI yet.
  sl.registerLazySingleton<ModelDownloadService>(
    () => ModelDownloadService(dio: sl<Dio>(), modelsDao: sl<ModelsDao>()),
  );
  sl.registerFactory<ModelsCubit>(() => ModelsCubit(downloadService: sl<ModelDownloadService>()));

  // Jobs feature
  sl.registerLazySingleton<JobsDataSource>(
    () => JobsDataSourceImpl(sl<JobsDao>()),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(sl<JobsDataSource>()),
  );
  sl.registerFactory<JobsCubit>(() => JobsCubit(repo: sl<JobsRepository>()));
  // Factory (never a singleton) — a stray second Job Detail screen must
  // get its own socket connection, not tear down another job's.
  sl.registerFactory<JobUpdatesSocketService>(
    () => JobUpdatesSocketServiceImpl(dio: sl<Dio>()),
  );
  sl.registerFactoryParam<JobDetailCubit, String, void>(
    (jobId, _) => JobDetailCubit(
      repo: sl<JobsRepository>(),
      jobId: jobId,
      socketService: sl<JobUpdatesSocketService>(),
    ),
  );
  sl.registerLazySingleton<FilePickerService>(() => FilePickerServiceImpl());
  sl.registerFactory<NewJobCubit>(
    () => NewJobCubit(
      repository: sl<JobsRepository>(),
      filePicker: sl<FilePickerService>(),
      generateIdempotencyKey: () => const Uuid().v4(),
    ),
  );
}
