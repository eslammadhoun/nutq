import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript.freezed.dart';

/// The text a job summarizes.
@freezed
sealed class Transcript with _$Transcript {
  const factory Transcript({
    required String text,
    required int wordCount,

    /// Metadata that only exists for transcribed (audio/video) jobs; null for
    /// pasted text.
    double? durationSeconds,
    String? modelName,
    String? modelVersion,
    String? quantization,
    String? downloadUrl,
  }) = _Transcript;
}
