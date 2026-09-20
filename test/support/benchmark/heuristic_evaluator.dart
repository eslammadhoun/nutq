import 'dart:math';

import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';

import 'benchmark_fixture.dart';
import 'summary_evaluation.dart';

/// Deterministic proxy scores (0–5). They make configurations comparable
/// and catch regressions, but they are **not** a substitute for human
/// ratings: coherence is left `null`, and every other score is a proxy for
/// the named quality, not a measurement of it.
class HeuristicSummaryEvaluator {
  const HeuristicSummaryEvaluator({this.idealCompression = 0.25});

  /// Summary-to-source word ratio at or below which conciseness is full marks.
  final double idealCompression;

  static final _arabicLetter = RegExp(r'[؀-ۿ]');
  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _artifacts = RegExp(
    r'MAIN:|POINTS:|FACTS:|SOURCE:|<end_of_turn>|<start_of_turn>|LOCAL SUMMARIES',
  );

  SummaryEvaluation evaluate(BenchmarkFixture fixture, SummaryResult result) {
    final summary = result.summary;
    return SummaryEvaluation(
      coverage: _coverage(fixture, summary),
      faithfulness: _faithfulness(result.validation),
      factuality: _factuality(result.validation),
      conciseness: _conciseness(fixture.transcript, summary),
      redundancy: _redundancy(summary),
      arabicQuality: _arabicQuality(summary),
      inputTokens: result.debug.inputTokens,
      outputTokens: result.debug.outputTokens,
      processingTimeMs: result.debug.processingTimeMs,
      tokensPerSecond: result.debug.tokensPerSecond,
      chunkCount: result.debug.chunkCount,
    );
  }

  /// Share of important facts / entities / numbers present in the summary.
  double _coverage(BenchmarkFixture fixture, String summary) {
    final normalized = ArabicNormalizer.normalize(summary);
    final summaryTokens = ArabicNormalizer.contentTokens(summary).toSet();

    final ratios = <double>[];
    if (fixture.importantFacts.isNotEmpty) {
      var hit = 0;
      for (final fact in fixture.importantFacts) {
        final tokens = ArabicNormalizer.contentTokens(fact);
        if (tokens.isEmpty) continue;
        final overlap = tokens.where(summaryTokens.contains).length / tokens.length;
        if (overlap >= 0.5) hit++;
      }
      ratios.add(hit / fixture.importantFacts.length);
    }
    for (final group in [fixture.importantEntities, fixture.importantNumbers]) {
      if (group.isEmpty) continue;
      final hit = group.where((v) => normalized.contains(ArabicNormalizer.normalize(v))).length;
      ratios.add(hit / group.length);
    }
    if (ratios.isEmpty) return 0;
    return 5 * ratios.reduce((a, b) => a + b) / ratios.length;
  }

  /// Mean heuristic claim support.
  double _faithfulness(ValidationReport report) {
    if (report.claims.isEmpty) return 5;
    final mean = report.claims.map((c) => c.score).reduce((a, b) => a + b) / report.claims.length;
    return (5 * mean).clamp(0, 5);
  }

  double _factuality(ValidationReport report) {
    final high = report.highSeverityCount;
    final medium = report.issues.length - high;
    return (5 - high * 1.5 - medium * 0.5).clamp(0, 5).toDouble();
  }

  double _conciseness(String source, String summary) {
    final sourceWords = _words(source);
    final summaryWords = _words(summary);
    if (sourceWords == 0 || summaryWords == 0) return 0;
    final ratio = summaryWords / sourceWords;
    if (ratio <= idealCompression) return ratio < 0.02 ? 3 : 5;
    return (5 * (1 - ratio) / (1 - idealCompression)).clamp(0, 5).toDouble();
  }

  /// 5 × the share of unique word trigrams (repetition lowers it).
  double _redundancy(String summary) {
    final tokens = ArabicNormalizer.normalize(
      summary,
    ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.length < 3) return 5;
    final grams = <String>[
      for (var i = 0; i + 2 < tokens.length; i++) '${tokens[i]} ${tokens[i + 1]} ${tokens[i + 2]}',
    ];
    return 5 * grams.toSet().length / grams.length;
  }

  /// Share of Arabic letters, minus a penalty for leaked prompt/template text.
  double _arabicQuality(String summary) {
    final letters = _letter.allMatches(summary).length;
    if (letters == 0) return 0;
    final arabic = _arabicLetter.allMatches(summary).length;
    var score = 5 * min(1.0, (arabic / letters) / 0.8);
    if (_artifacts.hasMatch(summary)) score -= 2;
    return score.clamp(0, 5).toDouble();
  }

  int _words(String s) => s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
