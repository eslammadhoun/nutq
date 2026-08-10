import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;
  static const _storage = FlutterSecureStorage();

  static Dio get instance {
    _dio ??= _build();
    return _dio!;
  }

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://192.168.1.1:8000/v1',
        ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
