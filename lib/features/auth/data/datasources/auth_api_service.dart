import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/auth/data/models/auth_response.dart';
import 'package:nutq/features/auth/data/models/login_request.dart';
import 'package:nutq/features/auth/data/models/register_request.dart';

part 'auth_api_service.g.dart';

/// Retrofit HTTP interface — typed responses
@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @Extra({'requiresAuth': false})
  @POST('/auth/login')
  Future<HttpResponse<AuthResponse>> login(
    @Body() LoginRequest request,
  );

  @Extra({'requiresAuth': false})
  @POST('/auth/register')
  Future<HttpResponse<AuthResponse>> register(
    @Body() RegisterRequest request,
  );

  @POST('/auth/logout')
  Future<HttpResponse<void>> logout();
}

/// Datasource interface — all callers use this (ApiResult + typed models)
abstract interface class AuthDataSource {
  Future<ApiResult<AuthResponse>> login(LoginRequest request);
  Future<ApiResult<AuthResponse>> register(RegisterRequest request);
  Future<ApiResult<void>> logout();
}

/// Implementation: wraps Retrofit + ApiClient for safe deserialization
class AuthDataSourceImpl implements AuthDataSource {
  AuthDataSourceImpl(this._apiClient, this._retrofit);

  final ApiClient _apiClient;
  final AuthApiService _retrofit;

  @override
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    final res = await _apiClient.execute(() => _retrofit.login(request));
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    final res = await _apiClient.execute(() => _retrofit.register(request));
    return res.mapSuccess((http) => http.data);
  }

  @override
  Future<ApiResult<void>> logout() async {
    await _apiClient.execute(() => _retrofit.logout());
    return const ApiResult.success(null);
  }
}
