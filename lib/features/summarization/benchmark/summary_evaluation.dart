import 'package:flutter/foundation.dart';

/// Quality scores on a 0.0–5.0 scale plus runtime numbers (plan §8).
///
/// Scores are `null` when they cannot be measured automatically:
/// [coherence] always needs a human rating.
@immutable
class SummaryEvaluation {
  SummaryEvaluation({
    this.coverage,
    this.faithfulness,
    this.factuality,
    this.coherence,
    this.conciseness,
    this.redundancy,
    this.arabicQuality,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.processingTimeMs = 0,
    this.tokensPerSecond = 0,
    this.chunkCount = 0,
  }) {
    for (final v in [coverage, faithfulness, factuality, coherence, conciseness, redundancy, arabicQuality]) {
      assert(v == null || (v >= 0 && v <= 5), 'scores are 0.0–5.0, got $v');
    }
  }

  final double? coverage;
  final double? faithfulness;
  final double? factuality;
  final double? coherence;
  final double? conciseness;

  /// Higher = less repetition.
  final double? redundancy;
  final double? arabicQuality;

  final int inputTokens;
  final int outputTokens;
  final int processingTimeMs;
  final double tokensPerSecond;
  final int chunkCount;

  /// Mean of the scores that were measured.
  double? get overall {
    final scores = [coverage, faithfulness, factuality, coherence, conciseness, redundancy, arabicQuality]
        .whereType<double>()
        .toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}
