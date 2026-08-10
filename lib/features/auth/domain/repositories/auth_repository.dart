import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/auth/data/models/auth_models.dart';

abstract interface class AuthRepository {
  Future<ApiResult<UserResponse>> register(String email, String password);
  Future<ApiResult<TokenResponse>> login(String email, String password);
  Future<void> logout();
}
