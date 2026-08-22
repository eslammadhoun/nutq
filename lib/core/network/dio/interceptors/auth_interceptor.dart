// ignore_for_file: prefer_initializing_formals
import 'package:dio/dio.dart';
import 'package:nutq/core/network/token/token_refresher.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    TokenRefresher? tokenRefresher, // nullable for late injection
    required Future<void> Function() onSessionExpired,
  }) : _tokenStorage = tokenStorage,
       _tokenRefresher = tokenRefresher,
       _onSessionExpired = onSessionExpired;

  final TokenStorage _tokenStorage;
  TokenRefresher? _tokenRefresher;
  final Future<void> Function() _onSessionExpired;

  /// A bare Dio with no interceptors, used only to replay a request after a
  /// refresh. Retrying through the main [Dio] would re-enter this same
  /// QueuedInterceptor's error queue if the retry itself 401s (e.g. a retried
  /// login with a wrong password) — since the outer onError call is still
  /// active/unresolved at that point, the retry's error task would sit queued
  /// behind it forever, deadlocking the request.
  late final Dio _retryDio;

  /// Must be called once with the [Dio] instance this interceptor is attached to
  void attach(Dio dio) {
    _retryDio = Dio(dio.options);
  }

  /// Inject TokenRefresher after Dio creation (breaks circular dependency)
  void updateTokenRefresher(TokenRefresher tokenRefresher) {
    _tokenRefresher = tokenRefresher;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding auth header for the refresh call itself and for public
    // endpoints (login/register) — a stale stored token has no business
    // being sent there, and can otherwise cause a spurious 401 -> refresh
    // -> retry cycle on a plain login attempt.
    final requiresAuth = options.extra['requiresAuth'] != false;
    if (options.extra['isRefreshCall'] != true && requiresAuth) {
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
    final requiresAuth = err.requestOptions.extra['requiresAuth'] != false;

    // A 401 on a public endpoint (login/register) means bad credentials, not
    // an expired session — never attempt a token refresh for it.
    if (err.response?.statusCode != 401 ||
        isRefreshCall ||
        alreadyRetried ||
        !requiresAuth) {
      handler.next(err);
      return;
    }

    // TokenRefresher must be injected before any 401 handling
    if (_tokenRefresher == null) {
      await _expireSession(handler, err);
      return;
    }

    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) {
      await _expireSession(handler, err);
      return;
    }

    try {
      final tokenPair = await _tokenRefresher!.refresh(refreshToken);
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
      retryOptions.headers['Authorization'] = 'Bearer ${tokenPair.accessToken}';
      final retryResponse = await _retryDio.fetch(retryOptions);
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