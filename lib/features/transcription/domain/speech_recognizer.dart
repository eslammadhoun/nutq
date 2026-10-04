import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/content_language.dart';

/// What a [SpeechRecognizer] heard, and which model heard it.
@immutable
class RecognizedSpeech {
  const RecognizedSpeech({
    required this.text,
    required this.modelName,
    required this.modelVersion,
  });

  /// One recognized line per row.
  final String text;
  final String modelName;
  final String modelVersion;
}

/// On-device speech-to-text.
abstract interface class SpeechRecognizer {
  /// Whether recognition works on this platform at all.
  bool get isAvailable;

  /// Transcribes a 16 kHz mono WAV file spoken in [language].
  ///
  /// [onProgress] receives 0.0–1.0 over the file. Throws
  /// [SpeechRecognitionException] on failure and `CancelledException` after
  /// [cancel].
  Future<RecognizedSpeech> transcribe({
    required String audioPath,
    required ContentLanguage language,
    void Function(double progress)? onProgress,
  });

  /// Stops a running [transcribe]. Never throws.
  Future<void> cancel();
}

/// Recognition failed. [message] is developer detail only.
class SpeechRecognitionException implements Exception {
  const SpeechRecognitionException(this.message);

  final String message;

  @override
  String toString() => 'SpeechRecognitionException: $message';
}
