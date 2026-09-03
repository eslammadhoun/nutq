// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobResponse _$JobResponseFromJson(Map<String, dynamic> json) => _JobResponse(
  id: json['id'] as String,
  status: json['status'] as String,
  sourceType: json['source_type'] as String,
  language: json['language'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  errorCode: json['error_code'] as String?,
  errorDetail: json['error_detail'] as String?,
  contentType: json['content_type'] as String?,
  uploadSlot: json['upload_slot'] == null
      ? null
      : UploadSlotResponse.fromJson(
          json['upload_slot'] as Map<String, dynamic>,
        ),
  preview: json['preview'] as String?,
);

Map<String, dynamic> _$JobResponseToJson(_JobResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'source_type': instance.sourceType,
      'language': instance.language,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'error_code': instance.errorCode,
      'error_detail': instance.errorDetail,
      'content_type': instance.contentType,
      'upload_slot': instance.uploadSlot,
      'preview': instance.preview,
    };
