import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/dio/dio_config.dart';
import 'package:nutq/core/network/dio/interceptors/auth_interceptor.dart';
import 'package:nutq/core/network/dio/interceptors/connectivity_interceptor.dart';
import 'package:nutq/core/network/dio/interceptors/logging_interceptor.dart';
import 'package:nutq/core/network/dio/interceptors/retry_interceptor.dart';
import 'package:nutq/core/network/network_info.dart';
import 'package:nutq/core/network/token/token_refresher.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';

/// DioFactory — registered as singleton in GetIt
class DioFactory {
  DioFactory({
    required this._tokenStorage,
    required this._tokenRefresher,
    required this._networkInfo,
    required this._onSessionExpired,
    DioConfig? config,
  }) : _config = config ?? const DioConfig();

  final TokenStorage _tokenStorage;
  final TokenRefresher? _tokenRefresher; // nullable for late injection
  final NetworkInfo _networkInfo;
  final Future<void> Function() _onSessionExpired;
  final DioConfig _config;

  Dio create() {
    DioConfig.ensureSecureBaseUrl(_config.baseUrl);
    final dio = Dio(_config.baseOptions);

    // dart:io's HttpClient pools keep-alive connections indefinitely by
    // default. After the app sits idle, the server (or the OS network
    // stack) can close those sockets without telling the client — the
    // pool then hands out a dead connection on the next request, which
    // surfaces as a connectionError until the app is fully relaunched.
    // A short idle timeout forces the pool to evict and reconnect instead.
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient()..idleTimeout = const Duration(seconds: 3);

    // Order matters: connectivity → auth → retry → logging (outermost)
    final authInterceptor = AuthInterceptor(
      tokenStorage: _tokenStorage,
      tokenRefresher: _tokenRefresher,
      onSessionExpired: _onSessionExpired,
    )..attach(dio);

    final retryInterceptor = RetryInterceptor()..attach(dio);

    dio.interceptors.addAll([
      ConnectivityInterceptor(_networkInfo),
      authInterceptor,
      retryInterceptor,
      // Debug-only: logs headers (JWTs) and bodies (passwords) — never in release
      if (!kReleaseMode) LoggingInterceptor(),
    ]);

    return dio;
  }

  /// Inject TokenRefresher after Dio creation (breaks circular dependency)
  static void injectTokenRefresher(Dio dio, TokenRefresher tokenRefresher) {
    for (final interceptor in dio.interceptors) {
      if (interceptor is AuthInterceptor) {
        interceptor.updateTokenRefresher(tokenRefresher);
        break;
      }
    }
  }
}
