// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SummaryResponse _$SummaryResponseFromJson(Map<String, dynamic> json) =>
    _SummaryResponse(
      summaryText: json['summary_text'] as String,
      toneAndFormat: json['tone_and_format'] as String,
      takeaways: (json['takeaways'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      modelName: json['model_name'] as String,
      promptVersion: json['prompt_version'] as String,
      tokensIn: (json['tokens_in'] as num?)?.toInt(),
      tokensOut: (json['tokens_out'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SummaryResponseToJson(_SummaryResponse instance) =>
    <String, dynamic>{
      'summary_text': instance.summaryText,
      'tone_and_format': instance.toneAndFormat,
      'takeaways': instance.takeaways,
      'model_name': instance.modelName,
      'prompt_version': instance.promptVersion,
      'tokens_in': instance.tokensIn,
      'tokens_out': instance.tokensOut,
    };
