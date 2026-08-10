// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSlotModel _$UploadSlotModelFromJson(Map<String, dynamic> json) =>
    UploadSlotModel(
      uploadUrl: json['upload_url'] as String,
      uploadToken: json['upload_token'] as String,
      expiresInSeconds: (json['expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$UploadSlotModelToJson(UploadSlotModel instance) =>
    <String, dynamic>{
      'upload_url': instance.uploadUrl,
      'upload_token': instance.uploadToken,
      'expires_in_seconds': instance.expiresInSeconds,
    };

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
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
      : UploadSlotModel.fromJson(json['upload_slot'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'source_type': instance.sourceType,
  'language': instance.language,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'error_code': instance.errorCode,
  'error_detail': instance.errorDetail,
  'upload_slot': instance.uploadSlot,
};

JobListResponseModel _$JobListResponseModelFromJson(
  Map<String, dynamic> json,
) => JobListResponseModel(
  items: (json['items'] as List<dynamic>)
      .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$JobListResponseModelToJson(
  JobListResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
};

SubmitJobRequestModel _$SubmitJobRequestModelFromJson(
  Map<String, dynamic> json,
) => SubmitJobRequestModel(
  sourceType: json['source_type'] as String,
  language: json['language'] as String? ?? 'ar',
  text: json['text'] as String?,
  idempotencyKey: json['idempotency_key'] as String?,
);

Map<String, dynamic> _$SubmitJobRequestModelToJson(
  SubmitJobRequestModel instance,
) => <String, dynamic>{
  'source_type': instance.sourceType,
  'language': instance.language,
  'text': ?instance.text,
  'idempotency_key': ?instance.idempotencyKey,
};
