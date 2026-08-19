import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/network/error/api_error.dart';

part 'api_result.freezed.dart';

@freezed
sealed class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.failure(ApiError error) = Failure<T>;
}

extension ApiResultX<T> on ApiResult<T> {
  /// Transform successful result with a mapping function.
  /// If this is a Failure, returns it unchanged.
  /// Supports both sync and async transforms (e.g. token persistence).
  Future<ApiResult<R>> mapSuccess<R>(
    FutureOr<R> Function(T data) transform,
  ) async {
    return switch (this) {
      Success(:final data) => ApiResult.success(await transform(data)),
      Failure(:final error) => ApiResult.failure(error),
    };
  }
}