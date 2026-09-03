import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';

@freezed
sealed class ApiError with _$ApiError {
  /// No internet / DNS failure
  const factory ApiError.network() = NetworkError;

  /// Connection actively refused — device is online but the API server
  /// process isn't listening (e.g. backend stopped/crashed).
  const factory ApiError.serverUnreachable() = ServerUnreachableError;

  /// Connection / send / receive timeout
  const factory ApiError.timeout() = TimeoutError;

  /// 401 — access token expired, refresh failed or missing
  const factory ApiError.unauthorized() = UnauthorizedError;

  /// 422 / 400 — backend validation errors (field → message)
  const factory ApiError.validation(Map<String, String> fieldErrors) = ValidationError;

  /// 5xx or non-2xx with a message from backend
  const factory ApiError.server(String message, int? statusCode) = ServerError;

  /// Anything else (parse errors, unexpected exceptions)
  const factory ApiError.unknown(String message) = UnknownError;
}