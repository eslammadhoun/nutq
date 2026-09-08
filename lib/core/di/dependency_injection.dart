import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:nutq/features/jobs/data/datasources/file_picker_service.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/dio/dio_config.dart';
import 'package:nutq/core/network/dio/dio_factory.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_api_service.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/data/sockets/job_updates_socket_service.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()));

  // Network stack
  final dio = DioFactory(config: const DioConfig()).create();

  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // Jobs feature
  sl.registerLazySingleton<JobsApiService>(() => JobsApiService(sl<Dio>()));
  sl.registerLazySingleton<JobsDataSource>(
    () => JobsDataSourceImpl(sl<ApiClient>(), sl<JobsApiService>(), sl<Dio>()),
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
