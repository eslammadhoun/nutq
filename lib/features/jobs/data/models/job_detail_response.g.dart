// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobDetailResponse _$JobDetailResponseFromJson(Map<String, dynamic> json) =>
    _JobDetailResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      sourceType: json['source_type'] as String,
      language: json['language'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      errorCode: json['error_code'] as String?,
      errorDetail: json['error_detail'] as String?,
      uploadSlot: json['upload_slot'] == null
          ? null
          : UploadSlotResponse.fromJson(
              json['upload_slot'] as Map<String, dynamic>,
            ),
      transcript: json['transcript'] == null
          ? null
          : TranscriptResponse.fromJson(
              json['transcript'] as Map<String, dynamic>,
            ),
      summary: json['summary'] == null
          ? null
          : SummaryResponse.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobDetailResponseToJson(_JobDetailResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'source_type': instance.sourceType,
      'language': instance.language,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'error_code': instance.errorCode,
      'error_detail': instance.errorDetail,
      'upload_slot': instance.uploadSlot,
      'transcript': instance.transcript,
      'summary': instance.summary,
    };
