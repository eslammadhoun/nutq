import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_job_params.freezed.dart';

/// Domain equivalent of [SubmitJobRequest] — built by [NewJobCubit] and
/// mapped to the wire request in the repository implementation.
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
  }) = _SubmitJobParams;
}
