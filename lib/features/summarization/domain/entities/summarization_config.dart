import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

/// Chunking and pipeline knobs. Values are experimental defaults (plan §11),
/// to be tuned by the benchmark, not final.
@immutable
class SummarizationConfig {
  const SummarizationConfig({
    this.length = SummaryLength.medium,
    this.language = ContentLanguage.ar,
    this.targetTokens = 400,
    this.overlapTokens = 50,
    this.minTokens = 250,
    this.maxTokens = 600,
    this.maxSentenceWords = 80,
    this.maxSummariesBeforeFinal = 3,
    this.evidenceTokensPerMerge = 250,
    this.maxFactsPerPrompt = 30,
    this.debugLogging = false,
  });

  final SummaryLength length;
  final ContentLanguage language;
  final int targetTokens;
  final int overlapTokens;
  final int minTokens;
  final int maxTokens;

  /// Sentences longer than this are split at clause punctuation (ASR output
  /// often has no sentence-final punctuation at all).
  final int maxSentenceWords;

  /// Hierarchical merging continues until at most this many summaries remain.
  final int maxSummariesBeforeFinal;

  /// Upper bound on source excerpts attached to one merge prompt.
  final int evidenceTokensPerMerge;
  final int maxFactsPerPrompt;

  /// Logs counts and timings only, never transcript content.
  final bool debugLogging;

  SummarizationConfig copyWith({
    SummaryLength? length,
    ContentLanguage? language,
    int? targetTokens,
    int? overlapTokens,
    int? minTokens,
    int? maxTokens,
    int? maxSummariesBeforeFinal,
    bool? debugLogging,
  }) => SummarizationConfig(
    length: length ?? this.length,
    language: language ?? this.language,
    targetTokens: targetTokens ?? this.targetTokens,
    overlapTokens: overlapTokens ?? this.overlapTokens,
    minTokens: minTokens ?? this.minTokens,
    maxTokens: maxTokens ?? this.maxTokens,
    maxSentenceWords: maxSentenceWords,
    maxSummariesBeforeFinal:
        maxSummariesBeforeFinal ?? this.maxSummariesBeforeFinal,
    evidenceTokensPerMerge: evidenceTokensPerMerge,
    maxFactsPerPrompt: maxFactsPerPrompt,
    debugLogging: debugLogging ?? this.debugLogging,
  );
}
