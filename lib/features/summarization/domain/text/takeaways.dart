import 'dart:math' as math;

import 'package:nutq/features/summarization/domain/text/key_line_extractor.dart';

final RegExp _sentenceEnd = RegExp(r'(?<=[.!?؟؛…])\s+|\n+');

/// A complete sentence ends with one of these, possibly before a closing
/// quote. A paragraph cut short at the model's output cap does not.
final RegExp _complete = RegExp(r'[.!?؟…]["»”)]*$');

/// The summary's own sentences that carry the most of what the source keeps
/// coming back to, for the "Key takeaways" list.
///
/// Extractive on purpose: the model is fine-tuned to write summaries with one
/// fixed instruction and would need another slow call to write a list, which
/// it was never trained for. Picking from the summary keeps every takeaway in
/// words the summary already stands behind, in the summary's language, at no
/// cost.
///
/// A word weighs as many [keySources] (the source's key sentences) as use it;
/// [ignore] (words found nearly everywhere, such as the subject's name) weighs
/// nothing. A sentence scores by its words' weight. The best complete sentences
/// are taken, skipping any that mostly repeat one already taken, and returned
/// in summary order.
List<String> pickTakeaways(
  String summary, {
  required Iterable<SourceUnit> keySources,
  Set<String> ignore = const {},
  int max = 5,
  int minWords = 6,
  int maxWords = 40,
  int minKeyTerms = 2,
}) {
  final weight = <String, int>{};
  for (final unit in keySources) {
    for (final term in unit.keyTerms) {
      if (!ignore.contains(term)) weight[term] = (weight[term] ?? 0) + 1;
    }
  }

  final candidates = <({int index, String text, Set<String> terms, double score})>[];
  final sentences = summary.split(_sentenceEnd).map((s) => s.trim()).toList();
  for (var i = 0; i < sentences.length; i++) {
    final text = sentences[i];
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words < minWords || words > maxWords || !_complete.hasMatch(text)) continue;
    final terms = KeyLineExtractor.termsOf(text).difference(ignore);
    // One shared word can be chance; a takeaway shares at least [minKeyTerms].
    final keyed = terms.where((t) => (weight[t] ?? 0) > 0).length;
    if (keyed < minKeyTerms) continue;
    final score = terms.fold<double>(0, (sum, t) => sum + (weight[t] ?? 0));
    candidates.add((index: i, text: text, terms: terms, score: score));
  }
  candidates.sort((a, b) => b.score.compareTo(a.score));

  final picked = <({int index, String text, Set<String> terms, double score})>[];
  for (final c in candidates) {
    if (picked.length == max) break;
    final repeats = picked.any(
      (p) => c.terms.intersection(p.terms).length / math.max(1, c.terms.length) > 0.5,
    );
    if (!repeats) picked.add(c);
  }
  picked.sort((a, b) => a.index.compareTo(b.index));
  return [for (final p in picked) p.text];
}
