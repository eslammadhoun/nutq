import 'package:flutter/foundation.dart';

/// Development-only metadata; never shown to normal users.
@immutable
class SummaryDebugInfo {
  const SummaryDebugInfo({
    required this.sectionCount,
    required this.processingTimeMs,
    this.retries = 0,
    this.droppedSections = 0,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.generationTimeMs = 0,
    this.prefillTimeMs = 0,
    this.summaryRatio = 0,
    this.coverage,
  });

  final int sectionCount;

  /// Sections retried with only their key points after writing too little.
  final int retries;

  /// Sections that added nothing, even after a retry.
  final int droppedSections;
  final int processingTimeMs;
  final int inputTokens;
  final int outputTokens;
  final int generationTimeMs;
  final int prefillTimeMs;
  final double summaryRatio;

  /// Lexical coverage of the key points, 0–1. A rough signal only: a summary
  /// that says a point in other words reads as low.
  final double? coverage;

  int get decodeTimeMs => generationTimeMs - prefillTimeMs;

  double get prefillTokensPerSecond => prefillTimeMs == 0 ? 0 : inputTokens * 1000 / prefillTimeMs;

  double get decodeTokensPerSecond => decodeTimeMs <= 0 ? 0 : outputTokens * 1000 / decodeTimeMs;
}

@immutable
class SummaryResult {
  const SummaryResult({
    required this.summary,
    required this.debug,
    this.keyPoints = const [],
    this.needsReview = false,
  });

  final String summary;
  final List<String> keyPoints;

  /// Part of the source could not be summarized (see
  /// [SummaryDebugInfo.droppedSections]).
  final bool needsReview;
  final SummaryDebugInfo debug;
}
