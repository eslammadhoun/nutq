// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_slot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadSlotResponse _$UploadSlotResponseFromJson(Map<String, dynamic> json) =>
    _UploadSlotResponse(
      uploadUrl: json['upload_url'] as String,
      uploadToken: json['upload_token'] as String,
      expiresInSeconds: (json['expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$UploadSlotResponseToJson(_UploadSlotResponse instance) =>
    <String, dynamic>{
      'upload_url': instance.uploadUrl,
      'upload_token': instance.uploadToken,
      'expires_in_seconds': instance.expiresInSeconds,
    };
