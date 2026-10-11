import 'package:flutter/foundation.dart';

/// What acquiring a source revealed about it. Only non-null fields are stored.
@immutable
class SourceInfo {
  const SourceInfo({this.title, this.filePath, this.mimeType, this.durationSeconds});

  final String? title;

  /// An app-owned file (for example a downloaded video); deleted with the job.
  final String? filePath;
  final String? mimeType;
  final double? durationSeconds;
}
