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

  /// 422 / 400 — backend validation errors (field → message)
  const factory ApiError.validation(Map<String, String> fieldErrors) = ValidationError;

  /// 5xx or non-2xx with a message from backend
  const factory ApiError.server(String message, int? statusCode) = ServerError;

  /// Anything else (parse errors, unexpected exceptions)
  const factory ApiError.unknown(String message) = UnknownError;

  /// The on-device model required for this operation hasn't been
  /// downloaded yet.
  const factory ApiError.modelNotDownloaded(String modelId) = ModelNotDownloadedError;

  /// Not enough free disk space to proceed (e.g. download or export).
  const factory ApiError.insufficientStorage() = InsufficientStorageError;

  /// Not enough available memory to run local inference.
  const factory ApiError.insufficientMemory() = InsufficientMemoryError;

  /// The user cancelled an in-progress local processing operation.
  const factory ApiError.processingCancelled() = ProcessingCancelledError;

  /// Audio could not be decoded (unsupported/corrupt file).
  const factory ApiError.audioDecodeFailed(String detail) = AudioDecodeFailedError;

  /// The native transcription/LLM engine failed unexpectedly.
  const factory ApiError.nativeEngineFailure(String detail) = NativeEngineFailureError;

  /// The device has no network connectivity (needed for a
  /// network-dependent operation, e.g. model download).
  const factory ApiError.deviceOffline() = DeviceOfflineError;
}