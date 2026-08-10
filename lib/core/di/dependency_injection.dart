import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutq/core/network/dio_factory.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/auth/data/datasources/auth_api_service.dart';
import 'package:nutq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));

  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(DioFactory.instance),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthApiService>(), sl<AppPreferences>()),
  );

  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));
}
