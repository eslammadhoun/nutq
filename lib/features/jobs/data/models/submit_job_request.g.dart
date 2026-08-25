// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_job_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitJobRequest _$SubmitJobRequestFromJson(Map<String, dynamic> json) =>
    _SubmitJobRequest(
      sourceType: json['source_type'] as String,
      language: json['language'] as String? ?? 'ar',
      sourceUrl: json['source_url'] as String?,
      forceWhisper: json['force_whisper'] as bool? ?? false,
      text: json['text'] as String?,
      filename: json['filename'] as String?,
      contentType: json['content_type'] as String?,
      sizeHint: (json['size_hint'] as num?)?.toInt(),
      idempotencyKey: json['idempotency_key'] as String?,
    );

Map<String, dynamic> _$SubmitJobRequestToJson(_SubmitJobRequest instance) =>
    <String, dynamic>{
      'source_type': instance.sourceType,
      'language': instance.language,
      'source_url': instance.sourceUrl,
      'force_whisper': instance.forceWhisper,
      'text': instance.text,
      'filename': instance.filename,
      'content_type': instance.contentType,
      'size_hint': instance.sizeHint,
      'idempotency_key': instance.idempotencyKey,
    };
