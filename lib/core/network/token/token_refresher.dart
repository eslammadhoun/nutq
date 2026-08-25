import 'package:dio/dio.dart';

/// Opaque token pair returned by refresh endpoint
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// Thrown when the refresh endpoint DEFINITIVELY rejects the refresh token
/// (401/403) — the session is unrecoverable and must be expired.
///
/// Transient failures (offline, timeout, 5xx) surface as plain [DioException]
/// instead: the stored tokens are still valid and the caller should NOT log
/// the user out — the next attempt may simply succeed.
class TokenRefreshRejectedException implements Exception {
  TokenRefreshRejectedException(this.cause);
  final DioException cause;

  @override
  String toString() => 'TokenRefreshRejectedException: ${cause.message}';
}

/// Interface — AuthInterceptor depends on this, not a concrete endpoint
abstract interface class TokenRefresher {
  /// Returns a fresh [TokenPair] on success.
  ///
  /// Throws [TokenRefreshRejectedException] when the session is dead, or a
  /// [DioException] for transient failures (caller decides what to do).
  Future<TokenPair> refresh(String refreshToken);
}
