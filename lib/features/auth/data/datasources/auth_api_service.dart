import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:nutq/features/auth/data/models/auth_models.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  @POST('/auth/register')
  Future<UserResponse> register(@Body() RegisterRequest body);

  @POST('/auth/login')
  Future<TokenResponse> login(@Body() LoginRequest body);

  @POST('/auth/refresh')
  Future<TokenResponse> refresh(
    @Header('Authorization') String bearerRefreshToken,
  );
}
