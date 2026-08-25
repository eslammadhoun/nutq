import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/dio/dio_config.dart';
import 'package:nutq/core/network/dio/dio_factory.dart';
import 'package:nutq/core/network/network_info.dart';
import 'package:nutq/core/network/network_info_impl.dart';
import 'package:nutq/core/network/token/token_refresher.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/session/session_manager.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/features/auth/data/datasources/auth_api_service.dart';
import 'package:nutq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_api_service.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  sl.registerLazySingleton<SessionManager>(() => SessionManager());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()));

  // Network stack
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Create Dio FIRST without TokenRefresher (breaks circular dependency)
  final dio = DioFactory(
    tokenStorage: sl<TokenStorage>(),
    tokenRefresher: null, // will be injected after creation
    networkInfo: sl<NetworkInfo>(),
    onSessionExpired: () async {
      await sl<AppPreferences>().setLoggedIn(false);
      // Tell the UI layer to redirect to login (main.dart listens).
      sl<SessionManager>().notifyExpired();
    },
    config: const DioConfig(),
  ).create();

  sl.registerLazySingleton<Dio>(() => dio);

  // Now create TokenRefresher with the Dio instance
  sl.registerLazySingleton<TokenRefresher>(
    () => TokenRefresherImpl(sl<Dio>()),
  );

  // Inject TokenRefresher into Dio's interceptors (post-construction)
  DioFactory.injectTokenRefresher(dio, sl<TokenRefresher>());

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // Auth feature
  sl.registerLazySingleton<AuthApiService>(() => AuthApiService(sl<Dio>()));
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(sl<ApiClient>(), sl<AuthApiService>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthDataSource>(),
      sl<TokenStorage>(),
      sl<AppPreferences>(),
    ),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(repo: sl<AuthRepository>()));

  // Jobs feature
  sl.registerLazySingleton<JobsApiService>(() => JobsApiService(sl<Dio>()));
  sl.registerLazySingleton<JobsDataSource>(
    () => JobsDataSourceImpl(sl<ApiClient>(), sl<JobsApiService>()),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(sl<JobsDataSource>()),
  );
  sl.registerFactory<JobsCubit>(() => JobsCubit(repo: sl<JobsRepository>()));
  sl.registerLazySingleton<NewJobCubit>(() => NewJobCubit());
}

/// Implementation of TokenRefresher — depends on Dio (lazy)
class TokenRefresherImpl implements TokenRefresher {
  TokenRefresherImpl(this._dio);

  final Dio _dio;

  /// Single-flight guard — concurrent 401s share one refresh in-flight.
  Future<TokenPair>? _inFlight;

  @override
  Future<TokenPair> refresh(String refreshToken) {
    // If a refresh is already running, all callers await the same future.
    // This prevents N parallel /auth/refresh calls (token clobbering / race).
    if (_inFlight != null) return _inFlight!;

    final completer = Completer<TokenPair>();
    _inFlight = completer.future;

    () async {
      try {
        completer.complete(await _doRefresh(refreshToken));
      } catch (error, stackTrace) {
        // Propagate to ALL concurrent callers sharing this future:
        // TokenRefreshRejectedException → everyone expires;
        // transient DioException → everyone keeps their tokens.
        completer.completeError(error, stackTrace);
      } finally {
        _inFlight = null;
      }
    }();

    return completer.future;
  }

  Future<TokenPair> _doRefresh(String refreshToken) async {
    // The refresh token goes in the JSON body ({"refresh_token": "..."}),
    // matching the backend's RefreshRequest schema — NOT an Authorization
    // header. Sending it as a header instead of a body previously caused
    // this call to hang indefinitely rather than fail fast.
    late final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'isRefreshCall': true}),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        throw TokenRefreshRejectedException(e);
      }
      rethrow; // offline / timeout / 5xx — session stays alive
    }
    final data = response.data!;
    final accessToken = data['access_token'] as String;
    final newRefreshToken = data['refresh_token'] as String;
    return TokenPair(accessToken: accessToken, refreshToken: newRefreshToken);
  }
}
