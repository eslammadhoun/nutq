import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/auth/domain/params/login_params.dart';
import 'package:nutq/features/auth/domain/params/register_params.dart';

abstract interface class AuthRepository {
  Future<ApiResult<void>> login(LoginParams params);
  Future<ApiResult<void>> register(RegisterParams params);
  Future<ApiResult<void>> logout();
}
