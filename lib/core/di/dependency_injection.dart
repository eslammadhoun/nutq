import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/dio/config/dio_config.dart';
import 'package:nutq/core/network/dio/dio_factory.dart';
import 'package:nutq/core/network/network_info.dart';
import 'package:nutq/core/network/network_info_impl.dart';
import 'package:nutq/core/network/token/token_refresher.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));

  // Network stack
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // TokenRefresher implementation depends on Dio — register lazily
  sl.registerLazySingleton<TokenRefresher>(
    () => TokenRefresherImpl(sl<Dio>(), sl<TokenStorage>()),
  );

  sl.registerLazySingleton<Dio>(
    () => DioFactory(
      tokenStorage: sl<TokenStorage>(),
      tokenRefresher: sl<TokenRefresher>(),
      networkInfo: sl<NetworkInfo>(),
      onSessionExpired: () => sl<AppPreferences>().setLoggedIn(false),
      config: const DioConfig(),
    ).create(),
  );

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));
}

/// Implementation of TokenRefresher — depends on Dio (lazy)
class TokenRefresherImpl implements TokenRefresher {
  TokenRefresherImpl(this._dio, this._storage);
  final Dio _dio;
  final TokenStorage _storage;

  @override
  Future<TokenPair?> refresh(String refreshToken) async {
    try {
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
      return TokenPair(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
    } on DioException {
      return null;
    }
  }
}