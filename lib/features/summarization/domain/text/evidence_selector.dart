import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Picks bounded source excerpts that ground a merge step: the chunk
/// sentences that share the most content words / numbers with the facts.
class EvidenceSelector {
  const EvidenceSelector(this._counter);

  final TokenCounter _counter;

  static final _hasDigit = RegExp(r'[0-9٠-٩]');

  Future<List<String>> select({
    required List<TranscriptChunk> chunks,
    required List<String> facts,
    required int tokenBudget,
  }) async {
    final factTokens = <String>{
      for (final f in facts) ...ArabicNormalizer.contentTokens(f),
    };

    final candidates = <_Candidate>[];
    var order = 0;
    for (final chunk in chunks) {
      final sentences = const SentenceSegmenter(maxWords: 1000).segment(chunk.text);
      for (var i = 0; i < sentences.length; i++) {
        final text = sentences[i].text;
        final tokens = ArabicNormalizer.contentTokens(text);
        var score = tokens.where(factTokens.contains).length;
        if (_hasDigit.hasMatch(text)) score += 2;
        // Lead sentence of each chunk is the fallback when nothing overlaps.
        candidates.add(_Candidate(order++, text, score, i == 0));
      }
    }

    final ranked = [...candidates]
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.order.compareTo(b.order);
      });

    final picked = <_Candidate>[];
    var used = 0;
    for (final c in ranked) {
      if (c.score == 0 && !c.isLead) continue;
      final cost = await _counter.count(c.text);
      if (used + cost > tokenBudget) continue;
      picked.add(c);
      used += cost;
    }
    picked.sort((a, b) => a.order.compareTo(b.order));
    return [for (final c in picked) c.text];
  }
}

class _Candidate {
  const _Candidate(this.order, this.text, this.score, this.isLead);

  final int order;
  final String text;
  final int score;
  final bool isLead;
}
