import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/utils/validators.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

part 'new_job_state.freezed.dart';

/// The four New-Job sheet tabs, in display order.
enum NewJobSourceType { text, video, audio, youtube }

enum JobLanguage { ar, en }

enum NewJobStatus { idle, submitting, success, failure }

extension NewJobSourceTypeX on NewJobSourceType {
  /// Wire value expected by POST /jobs (`source_type`). Video and audio both
  /// use the backend's generic "upload" type.
  String get wireValue => switch (this) {
    NewJobSourceType.text => 'text',
    NewJobSourceType.video => 'upload',
    NewJobSourceType.audio => 'upload',
    NewJobSourceType.youtube => 'youtube',
  };
}

extension JobLanguageX on JobLanguage {
  String get wireValue => name;
}

@freezed
abstract class NewJobState with _$NewJobState {
  const factory NewJobState({
    @Default(NewJobSourceType.text) NewJobSourceType sourceType,
    @Default(JobLanguage.ar) JobLanguage language,
    @Default('') String text,
    UploadFile? pickedFile,
    @Default('') String sourceUrl,
    @Default(false) bool forceWhisper,
    @Default(true) bool idempotencyEnabled,
    String? idempotencyKey,
    @Default(false) bool fileTooLarge,
    @Default(NewJobStatus.idle) NewJobStatus status,
    ApiError? lastError,
    String? submittedJobId,
  }) = _NewJobState;

  const NewJobState._();

  static const int maxTextLength = 500000;

  bool get canSubmit => switch (sourceType) {
    NewJobSourceType.text =>
      text.trim().isNotEmpty && text.length <= maxTextLength,
    NewJobSourceType.video ||
    NewJobSourceType.audio => pickedFile != null && pickedFile!.sizeBytes <= UploadFile.maxBytes,
    NewJobSourceType.youtube => Validators.isValidYouTubeUrl(sourceUrl),
  };
}
