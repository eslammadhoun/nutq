import 'dart:math' as math;

import 'package:nutq/features/summarization/domain/text/key_line_extractor.dart';

/// Decides when a summary is finished: when it covers every important part
/// of the source, not when it reaches a word count.
///
/// The source is split into units ([KeyLineExtractor.analyze]). A unit
/// scoring far below the typical unit — greetings, hand-overs, "طيب، خلينا
/// نحكي…" — is *filler* and is not sent to the model at all ([substantive]).
/// A unit scoring at least [importanceFactor] × the median is *important*: a
/// key point the summary must cover. A unit is *covered* when the summary
/// contains at least [coveredFraction] of its distinctive terms
/// ([SourceUnit.keyTerms]): a summary compresses, so it keeps a few of a
/// part's words, but a part it skipped shares almost none.
///
/// Matching is lexical, so a paraphrase can hide a covered unit; to allow for
/// that a term also matches a summary word sharing its first four letters
/// (`ارهابيين` / `ارهابيه`).
class CoverageTracker {
  CoverageTracker(
    this.units, {
    this.importanceFactor = 0.6,
    this.fillerFactor = 0.6,
    this.coveredFraction = 0.25,
  }) {
    final scores = units.map((u) => u.score).where((s) => s > 0).toList()..sort();
    final median = scores.isEmpty ? 0.0 : scores[scores.length ~/ 2];
    List<SourceUnit> scoring(double factor) => [
      for (final u in units)
        if (u.keyTerms.isNotEmpty && u.score >= median * factor) u,
    ];
    important = scoring(importanceFactor);
    substantive = scoring(fillerFactor);

    final df = <String, int>{};
    for (final u in units) {
      for (final t in KeyLineExtractor.termsOf(u.text)) {
        df[t] = (df[t] ?? 0) + 1;
      }
    }
    topicTerms = {
      for (final e in df.entries)
        if (units.length >= 8 && e.value / units.length > 0.25) e.key,
    };
  }

  final List<SourceUnit> units;

  /// A unit scoring at least this fraction of the median score is a key
  /// point the summary must cover.
  final double importanceFactor;

  /// A unit scoring below this fraction of the median score is filler.
  final double fillerFactor;

  /// Share of a unit's distinctive terms the summary must contain.
  final double coveredFraction;

  late final List<SourceUnit> important;

  /// Every unit that is not filler, in source order: what the model reads.
  late final List<SourceUnit> substantive;

  /// Terms found across much of the source (the lecture's subject itself).
  /// Every paragraph uses them, so they say nothing about whether a sentence
  /// is new.
  late final Set<String> topicTerms;

  /// Important units [summary] does not yet cover, in source order.
  List<SourceUnit> uncovered(String summary) {
    final terms = KeyLineExtractor.termsOf(summary);
    final prefixes = {
      for (final t in terms)
        if (t.length >= 4) t.substring(0, 4),
    };

    bool has(String term) =>
        terms.contains(term) || (term.length >= 4 && prefixes.contains(term.substring(0, 4)));

    return [
      for (final unit in important)
        if (unit.keyTerms.where(has).length <
            math.max(1, (unit.keyTerms.length * coveredFraction).ceil()))
          unit,
    ];
  }

  /// Covered share of the important units, 0..1.
  double ratio(String summary) =>
      important.isEmpty ? 1 : 1 - uncovered(summary).length / important.length;
}

/// Removes sentences of [addition] that only restate what [existing] already
/// says, so a new paragraph does not repeat earlier ones.
///
/// A sentence is a restatement when most of its distinctive terms — all its
/// terms minus [ignore], the subject-wide ones every sentence shares — are
/// already in [existing]. Line breaks (list items) are kept.
String dropRestatedSentences(
  String addition,
  String existing, {
  Set<String> ignore = const {},
  double threshold = 0.7,
}) {
  if (existing.trim().isEmpty) return addition.trim();

  final known = KeyLineExtractor.termsOf(existing);
  final lines = <String>[];

  for (final line in addition.split('\n')) {
    final kept = line.split(_sentenceEnd).where((sentence) {
      final terms = KeyLineExtractor.termsOf(sentence).difference(ignore);
      if (terms.length < 4) return true;
      return terms.where(known.contains).length / terms.length < threshold;
    });
    final joined = kept.join(' ').trim();
    if (joined.isNotEmpty || line.trim().isEmpty) lines.add(joined);
  }

  return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

final RegExp _sentenceEnd = RegExp(r'(?<=[.!?؟؛…])\s+');
