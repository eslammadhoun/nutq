import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/data/models/upload_slot_response.dart';

part 'job_response.freezed.dart';
part 'job_response.g.dart';

/// Raw job envelope returned by the jobs API (list + submit + cancel).
@freezed
sealed class JobResponse with _$JobResponse {
  const factory JobResponse({
    required String id,
    required String status,
    @JsonKey(name: 'source_type') required String sourceType,
    required String language,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'error_code') String? errorCode,
    @JsonKey(name: 'error_detail') String? errorDetail,
    @JsonKey(name: 'content_type') String? contentType,
    @JsonKey(name: 'upload_slot') UploadSlotResponse? uploadSlot,
    @JsonKey(name: 'preview') String? preview,
  }) = _JobResponse;

  factory JobResponse.fromJson(Map<String, dynamic> json) =>
      _$JobResponseFromJson(json);
}
