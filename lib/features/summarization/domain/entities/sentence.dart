import 'package:flutter/foundation.dart';

/// One sentence-level unit of a transcript, in original order.
@immutable
class Sentence {
  const Sentence({
    required this.index,
    required this.text,
    this.endsParagraph = false,
  });

  final int index;
  final String text;

  /// True when a blank line (paragraph break) follows this sentence.
  final bool endsParagraph;
}
