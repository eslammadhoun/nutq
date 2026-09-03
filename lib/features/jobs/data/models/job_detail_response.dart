import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/data/models/summary_response.dart';
import 'package:nutq/features/jobs/data/models/transcript_response.dart';
import 'package:nutq/features/jobs/data/models/upload_slot_response.dart';

part 'job_detail_response.freezed.dart';
part 'job_detail_response.g.dart';

@freezed
sealed class JobDetailResponse with _$JobDetailResponse {
  const factory JobDetailResponse({
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
    TranscriptResponse? transcript,
    SummaryResponse? summary,
  }) = _JobDetailResponse;

  factory JobDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$JobDetailResponseFromJson(json);
}
