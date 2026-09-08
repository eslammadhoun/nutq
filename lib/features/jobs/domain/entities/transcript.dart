import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript.freezed.dart';

/// Domain transcript — backed by a `Transcripts` DB row when the job has
/// completed local processing.
@freezed
sealed class Transcript with _$Transcript {
  const factory Transcript({
    required String language,
    int? wordCount,
    double? durationSeconds,
    required String modelName,
    required String modelVersion,
    String? quantization,

    /// Always null for a locally-stored transcript — [text] is inlined
    /// directly from the DB. Kept only so `JobDetailCubit`'s WS-frame
    /// fallback path (`_maybeFetchTranscriptText`), which still parses the
    /// legacy `snapshot`/`done` wire shape, keeps compiling unchanged.
    String? downloadUrl,
    String? text,
  }) = _Transcript;
}
