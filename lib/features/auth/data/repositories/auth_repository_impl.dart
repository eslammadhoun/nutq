import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/core/network/error_handler.dart';
import 'package:nutq/core/network/token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/auth/data/datasources/auth_api_service.dart';
import 'package:nutq/features/auth/data/models/auth_models.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._prefs, this._tokenStorage);

  final AuthApiService _api;
  final AppPreferences _prefs;
  final TokenStorage _tokenStorage;

  @override
  Future<ApiResult<UserResponse>> register(String email, String password) async {
    try {
      final result = await _api.register(
        RegisterRequest(email: email, password: password),
      );
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(
        ErrorHandler.handle(e),
        statusCode: ErrorHandler.statusCode(e),
      );
    }
  }

  @override
  Future<ApiResult<TokenResponse>> login(String email, String password) async {
    try {
      final result = await _api.login(
        LoginRequest(email: email, password: password),
      );
      await _tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _prefs.setLoggedIn(true);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(
        ErrorHandler.handle(e),
        statusCode: ErrorHandler.statusCode(e),
      );
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    await _prefs.setLoggedIn(false);
  }
}
