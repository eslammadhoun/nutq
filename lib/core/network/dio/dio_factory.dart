import 'package:dio/dio.dart';
import 'package:nutq/core/network/dio/config/dio_config.dart';
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
  final TokenRefresher _tokenRefresher;
  final NetworkInfo _networkInfo;
  final Future<void> Function() _onSessionExpired;
  final DioConfig _config;

  Dio create() {
    final dio = Dio(_config.baseOptions);

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
      LoggingInterceptor(),
    ]);

    return dio;
  }
}
