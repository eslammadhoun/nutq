import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

part 'new_job_state.freezed.dart';

/// The four New-Job sheet tabs, in display order.
enum JobLanguage { ar, en }

enum NewJobStatus { idle, submitting, success, failure }

extension JobLanguageX on JobLanguage {
  String get wireValue => name;
}

@freezed
abstract class NewJobState with _$NewJobState {
  const factory NewJobState({
    @Default(JobSourceType.text) JobSourceType sourceType,
    @Default(JobLanguage.ar) JobLanguage language,
    @Default('') String text,
    UploadFile? pickedFile,
    @Default('') String sourceUrl,
    @Default(false) bool fileTooLarge,
    @Default(NewJobStatus.idle) NewJobStatus status,
    AppError? lastError,
    String? submittedJobId,
  }) = _NewJobState;

  const NewJobState._();

  static const int maxTextLength = 500000;

  /// Only pasted text can be processed on-device today; audio, video and
  /// YouTube sources need transcription, which is not available.
  bool get isSourceSupported => sourceType == JobSourceType.text;

  bool get canSubmit =>
      isSourceSupported &&
      text.trim().isNotEmpty &&
      text.length <= maxTextLength;
}
