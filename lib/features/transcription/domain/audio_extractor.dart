import 'dart:io';

import 'package:flutter/foundation.dart';

/// 16 kHz mono PCM audio ready for speech recognition, in a temporary file.
@immutable
class ExtractedAudio {
  const ExtractedAudio({required this.path, required this.duration});

  final String path;
  final Duration duration;

  Future<void> delete() async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

/// Turns any audio or video file into audio a [SpeechRecognizer] can read.
abstract interface class AudioExtractor {
  /// Decodes the audio track of [inputPath].
  ///
  /// Throws [AudioExtractionException] when the file has no readable audio and
  /// `CancelledException` after [cancel].
  Future<ExtractedAudio> extract(String inputPath);

  /// Stops the extraction in flight, if any. Never throws.
  Future<void> cancel();

  /// Deletes extracted audio left behind by runs that ended without cleaning
  /// up, such as one killed mid-transcription.
  Future<void> deleteLeftovers();
}

/// The input could not be decoded. [message] is developer detail only.
class AudioExtractionException implements Exception {
  const AudioExtractionException(this.message);

  final String message;

  @override
  String toString() => 'AudioExtractionException: $message';
}
