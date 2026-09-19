import 'package:flutter/foundation.dart';

/// Summary of one chunk (or of several merged chunks, once merging runs).
@immutable
class LocalSummary {
  const LocalSummary({
    required this.chunkIds,
    required this.text,
    this.failed = false,
  });

  /// Ids of the chunks this summary covers, ascending.
  final List<int> chunkIds;
  final String text;

  /// True when generation failed and [text] is cleaned source text used as
  /// fallback evidence instead of a model summary.
  final bool failed;
}
