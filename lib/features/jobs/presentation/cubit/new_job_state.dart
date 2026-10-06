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

    /// Source types the app can process (the registered transcript sources).
    @Default({JobSourceType.text}) Set<JobSourceType> supportedSources,
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

  /// Whether a source is registered for the chosen tab: pasted text always,
  /// audio and video where on-device speech recognition exists (iOS).
  bool get isSourceSupported => supportedSources.contains(sourceType);

  /// Whether the chosen source has valid input. Only sources in
  /// [supportedSources] can be submitted.
  bool get canSubmit =>
      isSourceSupported &&
      switch (sourceType) {
        JobSourceType.text => text.trim().isNotEmpty && text.length <= maxTextLength,
        JobSourceType.youtube => sourceUrl.trim().isNotEmpty,
        JobSourceType.audio || JobSourceType.video => pickedFile != null && !fileTooLarge,
      };
}
