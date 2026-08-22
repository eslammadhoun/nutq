import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/dio/dio_config.dart';
import 'package:nutq/core/network/dio/dio_factory.dart';
import 'package:nutq/core/network/network_info.dart';
import 'package:nutq/core/network/network_info_impl.dart';
import 'package:nutq/core/network/token/token_refresher.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/auth/data/datasources/auth_api_service.dart';
import 'package:nutq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));

  // Network stack
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Create Dio FIRST without TokenRefresher (breaks circular dependency)
  final dio = DioFactory(
    tokenStorage: sl<TokenStorage>(),
    tokenRefresher: null, // will be injected after creation
    networkInfo: sl<NetworkInfo>(),
    onSessionExpired: () => sl<AppPreferences>().setLoggedIn(false),
    config: const DioConfig(),
  ).create();

  sl.registerLazySingleton<Dio>(() => dio);

  // Now create TokenRefresher with the Dio instance
  sl.registerLazySingleton<TokenRefresher>(
    () => TokenRefresherImpl(sl<Dio>(), sl<TokenStorage>()),
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
  sl.registerFactory<JobsCubit>(() => JobsCubit());
}

/// Implementation of TokenRefresher — depends on Dio (lazy)
class TokenRefresherImpl implements TokenRefresher {
  TokenRefresherImpl(this._dio, this._storage);
  final Dio _dio;
  final TokenStorage _storage;

  /// Single-flight guard — concurrent 401s share one refresh in-flight.
  Future<TokenPair?>? _inFlight;

  @override
  Future<TokenPair?> refresh(String refreshToken) {
    // If a refresh is already running, all callers await the same future.
    // This prevents N parallel /auth/refresh calls (token clobbering / race).
    if (_inFlight != null) return _inFlight!;

    final completer = Completer<TokenPair?>();
    _inFlight = completer.future;

    () async {
      try {
        final result = await _doRefresh(refreshToken);
        completer.complete(result);
      } catch (_) {
        completer.complete(null);
      } finally {
        _inFlight = null;
      }
    }();

    return completer.future;
  }

  Future<TokenPair?> _doRefresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      options: Options(
        headers: {'Authorization': 'Bearer $refreshToken'},
        extra: {'isRefreshCall': true},
      ),
    );
    final data = response.data!;
    final accessToken = data['access_token'] as String;
    final newRefreshToken = data['refresh_token'] as String;
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );
    return TokenPair(accessToken: accessToken, refreshToken: newRefreshToken);
  }
}
