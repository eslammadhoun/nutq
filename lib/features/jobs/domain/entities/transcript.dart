import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript.freezed.dart';

/// Domain equivalent of [TranscriptResponse].
@freezed
sealed class Transcript with _$Transcript {
  const factory Transcript({
    required String language,
    int? wordCount,
    double? durationSeconds,
    required String modelName,
    required String modelVersion,
    String? quantization,
    String? downloadUrl,

    /// Inlined by the REST detail response and the WS `snapshot`/`done`
    /// frames — the presigned [downloadUrl] fetch is now only a fallback
    /// for when the backend hasn't inlined the body.
    String? text,
  }) = _Transcript;
}
