import 'package:dio/dio.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/error/error_handler.dart';
import 'package:nutq/core/network/result/api_result.dart';

/// Central safe executor — repositories call this instead of try/catch
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResult<T>> execute<T>(Future<T> Function() call) async {
    try {
      return ApiResult.success(await call());
    } on DioException catch (e) {
      return ApiResult.failure(ErrorHandler.map(e));
    } on Exception catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  /// Convenience for GET
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => execute(() => _dio
    .get<T>(path, queryParameters: queryParameters, options: options)
    .then((r) => r.data as T));

  /// Convenience for POST
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => execute(() => _dio
    .post<T>(path, data: data, queryParameters: queryParameters, options: options)
    .then((r) => r.data as T));

  /// Convenience for PUT
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => execute(() => _dio
    .put<T>(path, data: data, queryParameters: queryParameters, options: options)
    .then((r) => r.data as T));

  /// Convenience for DELETE
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => execute(() => _dio
    .delete<T>(path, data: data, queryParameters: queryParameters, options: options)
    .then((r) => r.data as T));
}