// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';
import 'package:nutq/core/network/token/token_refresher.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required TokenRefresher tokenRefresher,
    required Future<void> Function() onSessionExpired,
  }) : _tokenStorage = tokenStorage,
       _tokenRefresher = tokenRefresher,
       _onSessionExpired = onSessionExpired;

  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;
  final Future<void> Function() _onSessionExpired;
  late final Dio _dio;

  /// Must be called once with the [Dio] instance this interceptor is attached to
  void attach(Dio dio) => _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding auth header for refresh call itself
    if (options.extra['isRefreshCall'] != true) {
      final token = await _tokenStorage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isRefreshCall = err.requestOptions.extra['isRefreshCall'] == true;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (err.response?.statusCode != 401 || isRefreshCall || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) {
      await _expireSession(handler, err);
      return;
    }

    try {
      final tokenPair = await _tokenRefresher.refresh(refreshToken);
      if (tokenPair == null) {
        await _expireSession(handler, err);
        return;
      }

      await _tokenStorage.saveTokens(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
      );

      final retryOptions = err.requestOptions;
      retryOptions.extra['retried'] = true;
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _expireSession(handler, err);
    }
  }

  Future<void> _expireSession(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    await _tokenStorage.clear();
    await _onSessionExpired();
    handler.next(err);
  }
}