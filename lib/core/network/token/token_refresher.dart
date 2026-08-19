/// Opaque token pair returned by refresh endpoint
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// Interface — AuthInterceptor depends on this, not a concrete endpoint
abstract interface class TokenRefresher {
  /// Returns null if refresh failed (token revoked, expired, etc.)
  Future<TokenPair?> refresh(String refreshToken);
}