import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

/// Pipeline knobs, tuned on the Arabic AI lecture and Al Jazeera fixtures on an
/// iPhone XR (gemma_playground, 2026-09-27 – 10-01).
@immutable
class SummarizationConfig {
  const SummarizationConfig({
    this.length = SummaryLength.medium,
    this.language = ContentLanguage.ar,
    this.wordsPerCall = 80,
    this.keyPointFactor = 1.0,
    this.minWordsToSummarize = 20,
    this.debugLogging = !kReleaseMode,
  });

  final SummaryLength length;

  /// Language the summary is written in.
  final ContentLanguage language;

  /// Words one call writes, about the same whatever it reads or is asked for:
  /// a 1B model writes its paragraph, so the summary's length is set by how
  /// many sections there are, not by the prompt.
  final int wordsPerCall;

  /// A unit scoring at least this × the median is a key point; below it
  /// (examples, asides) the summary may leave it out. Key points are what a
  /// failed section is retried with.
  final double keyPointFactor;

  /// Below this there is nothing to condense, and a small model asked to
  /// summarize near-empty input echoes the prompt instead. The text is kept
  /// as its own summary.
  final int minWordsToSummarize;

  /// Logs one `[summarizer]` line per run, counts and timings only, never
  /// transcript content. On in debug and profile builds, so device benchmarks
  /// (`flutter run --profile`) report it.
  final bool debugLogging;

  /// Summary length as a share of the source: 15% for a few-minute clip,
  /// falling to 6% for a 100-minute lecture (~15,000 words), scaled by
  /// [length]. Writing is most of the run time — about 10 tokens/s on an
  /// iPhone XR on the CPU.
  double summaryRatio(int sourceWords) {
    final base = (0.15 * math.pow(600 / math.max(sourceWords, 1), 0.3)).clamp(0.06, 0.15);
    return (base * length.ratioScale).clamp(0.04, 0.25).toDouble();
  }

  /// Source words per section so the summary comes out near [summaryRatio].
  int sectionWords(double ratio) => (wordsPerCall / ratio).round();

  SummarizationConfig copyWith({
    SummaryLength? length,
    ContentLanguage? language,
    int? wordsPerCall,
    bool? debugLogging,
  }) => SummarizationConfig(
    length: length ?? this.length,
    language: language ?? this.language,
    wordsPerCall: wordsPerCall ?? this.wordsPerCall,
    keyPointFactor: keyPointFactor,
    minWordsToSummarize: minWordsToSummarize,
    debugLogging: debugLogging ?? this.debugLogging,
  );
}
