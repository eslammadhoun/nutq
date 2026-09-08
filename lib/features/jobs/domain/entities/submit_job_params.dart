import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

part 'submit_job_params.freezed.dart';

/// Built by [NewJobCubit] and persisted directly by
/// `JobsRepositoryImpl.submitJob` — no wire request to map to, everything
/// is written straight to the local DB.
@freezed
sealed class SubmitJobParams with _$SubmitJobParams {
  const factory SubmitJobParams({
    required String sourceType,
    @Default('ar') String language,
    String? sourceUrl,
    @Default(false) bool forceWhisper,
    String? text,
    String? filename,
    String? contentType,
    int? sizeHint,
    String? idempotencyKey,

    /// The locally-picked file for `sourceType: upload` — its cache path
    /// is copied into permanent app storage during submission.
    UploadFile? file,
  }) = _SubmitJobParams;
}
