import 'package:flutter/foundation.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';

/// Development-only metadata; never shown to normal users.
@immutable
class SummaryDebugInfo {
  const SummaryDebugInfo({
    required this.jobId,
    required this.chunkCount,
    required this.failedChunkCount,
    required this.processingTimeMs,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.generationTimeMs = 0,
    this.mergeRounds = 0,
  });

  final String jobId;
  final int chunkCount;
  final int failedChunkCount;
  final int processingTimeMs;
  final int inputTokens;
  final int outputTokens;
  final int generationTimeMs;
  final int mergeRounds;

  double get tokensPerSecond => generationTimeMs == 0 ? 0 : outputTokens * 1000 / generationTimeMs;
}

@immutable
class SummaryResult {
  const SummaryResult({
    required this.summary,
    required this.validation,
    required this.debug,
    this.keyPoints = const [],
    this.importantFacts = const [],
  });

  final String summary;
  final List<String> keyPoints;
  final List<String> importantFacts;
  final ValidationReport validation;
  final SummaryDebugInfo debug;
}
