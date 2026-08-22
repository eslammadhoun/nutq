// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranscriptResponse _$TranscriptResponseFromJson(Map<String, dynamic> json) =>
    _TranscriptResponse(
      language: json['language'] as String,
      wordCount: (json['word_count'] as num?)?.toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
      modelName: json['model_name'] as String,
      modelVersion: json['model_version'] as String,
      quantization: json['quantization'] as String?,
      downloadUrl: json['download_url'] as String?,
    );

Map<String, dynamic> _$TranscriptResponseToJson(_TranscriptResponse instance) =>
    <String, dynamic>{
      'language': instance.language,
      'word_count': instance.wordCount,
      'duration_seconds': instance.durationSeconds,
      'model_name': instance.modelName,
      'model_version': instance.modelVersion,
      'quantization': instance.quantization,
      'download_url': instance.downloadUrl,
    };
