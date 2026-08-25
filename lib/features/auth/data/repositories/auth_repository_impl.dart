import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/auth/data/datasources/auth_api_service.dart';
import 'package:nutq/features/auth/data/models/auth_response.dart';
import 'package:nutq/features/auth/data/models/login_request.dart';
import 'package:nutq/features/auth/data/models/logout_request.dart';
import 'package:nutq/features/auth/data/models/register_request.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

/// Repository: the single owner of "am I authenticated".
/// Token persistence happens here — never in the datasource or cubit.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._dataSource,
    this._tokenStorage,
    this._appPreferences,
  );

  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;
  final AppPreferences _appPreferences;

  @override
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    final result = await _dataSource.login(request);
    return result.mapSuccess((auth) async {
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      await _appPreferences.setLoggedIn(true);
      return auth;
    });
  }

  @override
  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    final result = await _dataSource.register(request);
    return result.mapSuccess((auth) async {
      await _tokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      await _appPreferences.setLoggedIn(true);
      return auth;
    });
  }

  @override
  Future<ApiResult<void>> logout() async {
    // Best-effort server logout (token auth makes it optional)
    final String? token = await _tokenStorage.refreshToken;
    final logoutRequest = LogoutRequest(refreshToken: token ?? '');
    await _dataSource.logout(logoutRequest);
    await _tokenStorage.clear();
    await _appPreferences.setLoggedIn(false);
    return const ApiResult.success(null);
  }
}
