import 'package:freezed_annotation/freezed_annotation.dart';
part 'new_job_state.freezed.dart';

enum JobUploadType { text, videoFile, audio, youtube }

enum JobLanguage { ar, en }

@freezed
abstract class NewJobState with _$NewJobState {
  const factory NewJobState({
    @Default(JobUploadType.text) JobUploadType jobUploadType,
    @Default(JobLanguage.ar) JobLanguage jobLanguage,
    @Default(false) bool idempotencyKey,
  }) = _NewJobState;
}
