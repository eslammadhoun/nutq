import 'package:flutter/foundation.dart';

/// The text a source produced for a job, and how it was produced.
@immutable
class SourceTranscript {
  const SourceTranscript(this.text, {this.modelName, this.modelVersion});

  final String text;

  /// The speech-recognition model, for media sources.
  final String? modelName;
  final String? modelVersion;
}
