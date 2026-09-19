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
}
