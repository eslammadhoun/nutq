import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/auth/data/models/auth_response.dart';
import 'package:nutq/features/auth/data/models/login_request.dart';
import 'package:nutq/features/auth/data/models/register_request.dart';

abstract interface class AuthRepository {
  Future<ApiResult<AuthResponse>> login(LoginRequest request);
  Future<ApiResult<AuthResponse>> register(RegisterRequest request);
  Future<ApiResult<void>> logout();
}
