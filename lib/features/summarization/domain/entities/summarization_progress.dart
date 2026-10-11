import 'package:flutter/foundation.dart';

enum SummarizationStage {
  preparing,
  analyzing,
  summarizing,
  combining,
  checking,
  finalizing,
  completed,
}

@immutable
class SummarizationProgress {
  const SummarizationProgress(
    this.stage, {
    this.processedChunks,
    this.totalChunks,
  });

  final SummarizationStage stage;
  final int? processedChunks;
  final int? totalChunks;

  /// Rough overall completion, 0.0–1.0: chunk work is the bulk of the job,
  /// merging/finalizing/checking make up the tail.
  double get fraction {
    final processed = processedChunks;
    final total = totalChunks;
    final chunkShare = (processed != null && total != null && total > 0)
        ? (processed / total).clamp(0.0, 1.0)
        : 0.0;
    return switch (stage) {
      SummarizationStage.preparing => 0.02,
      SummarizationStage.analyzing || SummarizationStage.summarizing => 0.05 + 0.65 * chunkShare,
      SummarizationStage.combining => 0.75,
      SummarizationStage.finalizing => 0.85,
      SummarizationStage.checking => 0.95,
      SummarizationStage.completed => 1.0,
    };
  }
}
