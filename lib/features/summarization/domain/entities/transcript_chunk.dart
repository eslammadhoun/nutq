import 'package:flutter/foundation.dart';

/// A contiguous, sentence-aligned slice of the cleaned transcript.
///
/// [startSentenceIndex]..[endSentenceIndex] are inclusive indices into the
/// segmented sentence list. Consecutive chunks may share up to
/// `overlapTokens` worth of leading sentences ([overlapSentenceCount]).
@immutable
class TranscriptChunk {
  const TranscriptChunk({
    required this.id,
    required this.text,
    required this.startSentenceIndex,
    required this.endSentenceIndex,
    required this.tokenCount,
    this.overlapSentenceCount = 0,
  });

  final int id;
  final String text;
  final int startSentenceIndex;
  final int endSentenceIndex;
  final int tokenCount;
  final int overlapSentenceCount;
}
