import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/l10n/app_localizations.dart';

extension ApiErrorL10n on AppLocalizations {
  /// User-facing message for any [ApiError] surfaced by a cubit.
  String jobsErrorMessage(ApiError error) => switch (error) {
    NetworkError() => errorNoConnection,
    ServerUnreachableError() => errorServerUnreachable,
    TimeoutError() => errorTimeout,
    ValidationError(:final fieldErrors) =>
      fieldErrors.values.isNotEmpty ? fieldErrors.values.first : somethingWentWrong,
    ServerError(:final message) =>
      message.isEmpty ? somethingWentWrong : message,
    UnknownError(:final message) =>
      message.isEmpty ? somethingWentWrong : message,
    ModelNotDownloadedError() => errorModelNotDownloaded,
    InsufficientStorageError() => errorInsufficientStorage,
    StorageError() => errorStorage,
    InsufficientMemoryError() => errorInsufficientMemory,
    ProcessingCancelledError() => errorProcessingCancelled,
    AudioDecodeFailedError() => errorAudioDecodeFailed,
    NativeEngineFailureError() => errorNativeEngineFailure,
    DeviceOfflineError() => errorDeviceOffline,
  };
}
