import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nutq/core/network/error/api_error.dart';

class ErrorHandler {
  ErrorHandler._();

  static ApiError map(Object error) {
    if (error is! DioException) {
      return ApiError.unknown(error.toString());
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError.timeout();

      case DioExceptionType.connectionError:
        return _isConnectionRefused(error) ? ApiError.serverUnreachable() : ApiError.network();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return ApiError.unknown('Request cancelled');

      case DioExceptionType.unknown:
        return ApiError.unknown(error.message ?? 'Unknown error');

      default:
        return ApiError.unknown('Unexpected error');
    }
  }

  /// Distinguishes "server process is down" from "device has no internet".
  /// Dio wraps both as [DioExceptionType.connectionError], but only the
  /// former carries a [SocketException] with `errno == ECONNREFUSED`
  /// (the OS actively rejected the connection, meaning the host was
  /// reachable — the API just wasn't listening). This is checked directly
  /// against the failed request's own error rather than a separate
  /// pre-flight probe, so the result is never stale.
  static bool _isConnectionRefused(DioException error) {
    final inner = error.error;
    if (inner is SocketException) {
      return inner.osError?.errorCode == 61 || // macOS/iOS ECONNREFUSED
          inner.osError?.errorCode == 111 || // Android/Linux ECONNREFUSED
          inner.message.contains('Connection refused');
    }
    return false;
  }

  static ApiError _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // 401 handled by AuthInterceptor — shouldn't reach here, but fallback
    if (statusCode == 401) return ApiError.unauthorized();

    // 422 / 400 — validation errors
    if (statusCode == 422 || statusCode == 400) {
      if (data is Map) {
        // Backend formats vary — handle common ones
        final errors = _extractFieldErrors(data);
        if (errors.isNotEmpty) return ApiError.validation(errors);
      }
      return ApiError.server(_extractMessage(data, 'Validation failed'), statusCode);
    }

    // 5xx or other
    return ApiError.server(_extractMessage(data, 'Server error'), statusCode);
  }

  /// Safely pulls `detail`/`message` out of an error body. The body is NOT
  /// guaranteed to be JSON [Map] — proxies/load balancers can return plain
  /// strings or HTML pages, and indexing those with `[]` would throw inside
  /// this mapper, escaping the caller's catch block.
  static String _extractMessage(Object? data, String fallback) {
    if (data is Map) {
      final detail = data['detail'] ?? data['message'];
      if (detail != null && detail.toString().isNotEmpty) {
        return detail.toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }

  static Map<String, String> _extractFieldErrors(Map data) {
    final errors = <String, String>{};

    // FastAPI / typical format: {"detail": [{"loc": ["body", "field"], "msg": "..."}]}
    if (data['detail'] is List) {
      for (final item in data['detail'] as List) {
        if (item is Map && item['loc'] is List && item['msg'] is String) {
          final loc = item['loc'] as List;
          if (loc.length >= 2) {
            errors[loc.last.toString()] = item['msg'] as String;
          }
        }
      }
    }

    // Alternative: {"errors": {"field": "message"}}
    if (data['errors'] is Map) {
      for (final entry in (data['errors'] as Map).entries) {
        errors[entry.key.toString()] = entry.value.toString();
      }
    }

    // RFC7807-style: {"errors": [{"field": "username", "message": "..."}]}
    if (data['errors'] is List) {
      for (final item in data['errors'] as List) {
        if (item is Map &&
            item['field'] is String &&
            item['message'] is String) {
          errors[item['field'] as String] =
              '${item['field'] as String} ${item['message'] as String}';
        }
      }
    }

    return errors;
  }
}
