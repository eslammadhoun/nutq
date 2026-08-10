import 'package:dio/dio.dart';
import 'package:nutq/core/network/auth_interceptor.dart';
import 'package:nutq/core/network/token_storage.dart';

/// Builds the app's single [Dio] instance, registered as a singleton via
/// GetIt so it (and the [TokenStorage] it depends on) can be swapped for
/// fakes in tests instead of reaching into static state.
Dio buildDio({
  required TokenStorage tokenStorage,
  required Future<void> Function() onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://192.168.1.1:8000/v1',
      ),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final authInterceptor = AuthInterceptor(
    tokenStorage: tokenStorage,
    onSessionExpired: onSessionExpired,
  )..attach(dio);

  dio.interceptors.add(authInterceptor);
  return dio;
}
