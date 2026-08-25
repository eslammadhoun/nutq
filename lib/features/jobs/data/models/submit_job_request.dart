import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_job_request.freezed.dart';
part 'submit_job_request.g.dart';

@freezed
sealed class SubmitJobRequest with _$SubmitJobRequest {
  const factory SubmitJobRequest({
    @JsonKey(name: 'source_type') required String sourceType,
    @Default('ar') String language,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'force_whisper') @Default(false) bool forceWhisper,
    String? text,
    String? filename,
    @JsonKey(name: 'content_type') String? contentType,
    @JsonKey(name: 'size_hint') int? sizeHint,
    @JsonKey(name: 'idempotency_key') String? idempotencyKey,
  }) = _SubmitJobRequest;

  factory SubmitJobRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitJobRequestFromJson(json);
}
