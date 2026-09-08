import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/dio/dio_config.dart';
import 'package:nutq/core/network/dio/interceptors/logging_interceptor.dart';
import 'package:nutq/core/network/dio/interceptors/retry_interceptor.dart';

/// DioFactory — registered as singleton in GetIt
class DioFactory {
  DioFactory({DioConfig? config}) : _config = config ?? const DioConfig();

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

    final retryInterceptor = RetryInterceptor()..attach(dio);

    dio.interceptors.addAll([
      retryInterceptor,
      // Debug-only: logs headers and bodies — never in release
      if (!kReleaseMode) LoggingInterceptor(),
    ]);

    return dio;
  }
}
