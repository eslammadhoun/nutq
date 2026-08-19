import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nutq/core/network/token/token_refresher.dart';

abstract interface class TokenStorage {
  Future<String?> get accessToken;
  Future<String?> get refreshToken;
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clear();

  /// Convenience getter for both tokens as a pair
  Future<TokenPair?> get tokenPair async {
    final access = await accessToken;
    final refresh = await refreshToken;
    if (access != null && refresh != null) {
      return TokenPair(accessToken: access, refreshToken: refresh);
    }
    return null;
  }
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clear() => _storage.deleteAll();

  @override
  Future<TokenPair?> get tokenPair async {
    final access = await accessToken;
    final refresh = await refreshToken;
    if (access != null && refresh != null) {
      return TokenPair(accessToken: access, refreshToken: refresh);
    }
    return null;
  }
}