import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript.freezed.dart';

/// The text a job summarizes.
@freezed
sealed class Transcript with _$Transcript {
  const factory Transcript({
    required String text,
    required int wordCount,

    /// The speech-recognition model that produced the text; null for text the
    /// user pasted.
    String? modelName,
    String? modelVersion,
  }) = _Transcript;
}
