import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript_response.freezed.dart';
part 'transcript_response.g.dart';

@freezed
sealed class TranscriptResponse with _$TranscriptResponse {
  const factory TranscriptResponse({
    required String language,
    @JsonKey(name: 'word_count') int? wordCount,
    @JsonKey(name: 'duration_seconds') double? durationSeconds,
    @JsonKey(name: 'model_name') required String modelName,
    @JsonKey(name: 'model_version') required String modelVersion,
    String? quantization,
    @JsonKey(name: 'download_url') String? downloadUrl,
  }) = _TranscriptResponse;

  factory TranscriptResponse.fromJson(Map<String, dynamic> json) =>
      _$TranscriptResponseFromJson(json);
}
