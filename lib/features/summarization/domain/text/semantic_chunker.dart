import 'package:nutq/features/summarization/domain/entities/sentence.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Groups sentences into token-budgeted chunks.
///
/// Rules: never cut inside a sentence; prefer paragraph ends when one falls
/// near the target size; keep limited sentence-level overlap between
/// consecutive chunks; avoid a tiny trailing chunk; preserve order.
class SemanticChunker {
  const SemanticChunker(this._counter);

  final TokenCounter _counter;

  /// A paragraph end is preferred over the exact target if it is at least this
  /// fraction of the target.
  static const _paragraphPreference = 0.85;

  /// A tiny tail chunk is merged into its predecessor if the result stays
  /// within `maxTokens * _tailMergeSlack`.
  static const _tailMergeSlack = 1.25;

  Future<List<TranscriptChunk>> chunk(
    List<Sentence> sentences,
    SummarizationConfig config,
  ) async {
    if (sentences.isEmpty) return const [];

    final counts = <int>[];
    for (final s in sentences) {
      counts.add(await _counter.count(s.text));
    }

    final spans = <_Span>[];
    var start = 0;
    var overlap = 0;
    while (start < sentences.length) {
      var span = _nextSpan(sentences, counts, start, config, overlap);
      if (spans.isNotEmpty && span.end <= spans.last.end) {
        // Overlap left no room to advance; restart just after the last chunk.
        start = spans.last.end + 1;
        overlap = 0;
        span = _nextSpan(sentences, counts, start, config, overlap);
      }
      spans.add(span);
      if (span.end >= sentences.length - 1) break;
      start = _nextStart(counts, span, config.overlapTokens);
      overlap = span.end - start + 1;
    }

    _mergeTinyTail(spans, counts, config);

    return [
      for (var i = 0; i < spans.length; i++)
        TranscriptChunk(
          id: i,
          text: _join(sentences, spans[i].start, spans[i].end),
          startSentenceIndex: spans[i].start,
          endSentenceIndex: spans[i].end,
          tokenCount: _sum(counts, spans[i].start, spans[i].end),
          overlapSentenceCount: spans[i].overlap,
        ),
    ];
  }

  _Span _nextSpan(
    List<Sentence> sentences,
    List<int> counts,
    int start,
    SummarizationConfig config,
    int overlap,
  ) {
    var tokens = 0;
    var end = start;
    var bestBreak = -1;
    var bestBreakTokens = 0;
    var j = start;
    var hitMax = false;

    while (j < sentences.length) {
      final t = counts[j];
      if (tokens > 0 && tokens + t > config.maxTokens) {
        hitMax = true;
        break;
      }
      tokens += t;
      end = j;
      if (sentences[j].endsParagraph && tokens >= config.minTokens) {
        bestBreak = j;
        bestBreakTokens = tokens;
      }
      j++;
      if (tokens >= config.targetTokens) break;
    }

    if (j >= sentences.length) return _Span(start, end, overlap);

    if (hitMax || tokens < config.targetTokens) {
      if (bestBreak >= 0) end = bestBreak;
    } else if (bestBreak >= 0 &&
        bestBreak != end &&
        bestBreakTokens >= config.targetTokens * _paragraphPreference) {
      end = bestBreak;
    }
    return _Span(start, end, overlap);
  }

  /// First sentence of the next chunk: walk back from the end of [span]
  /// collecting whole sentences up to [overlapTokens], always advancing.
  int _nextStart(List<int> counts, _Span span, int overlapTokens) {
    var next = span.end + 1;
    if (overlapTokens <= 0) return next;
    var taken = 0;
    for (var k = span.end; k > span.start; k--) {
      if (taken + counts[k] > overlapTokens) break;
      taken += counts[k];
      next = k;
    }
    return next;
  }

  void _mergeTinyTail(
    List<_Span> spans,
    List<int> counts,
    SummarizationConfig config,
  ) {
    if (spans.length < 2) return;
    final last = spans.last;
    final prev = spans[spans.length - 2];
    final lastNew = _sum(counts, last.start + last.overlap, last.end);
    if (_sum(counts, last.start, last.end) >= config.minTokens &&
        lastNew >= config.minTokens ~/ 2) {
      return;
    }
    final mergedTokens = _sum(counts, prev.start, last.end);
    if (mergedTokens <= config.maxTokens * _tailMergeSlack) {
      spans.removeLast();
      spans[spans.length - 1] = _Span(prev.start, last.end, prev.overlap);
    }
  }

  int _sum(List<int> counts, int from, int to) {
    var total = 0;
    for (var i = from; i <= to; i++) {
      total += counts[i];
    }
    return total;
  }

  String _join(List<Sentence> sentences, int from, int to) {
    final buffer = StringBuffer();
    for (var i = from; i <= to; i++) {
      buffer.write(sentences[i].text);
      if (i < to) buffer.write(sentences[i].endsParagraph ? '\n\n' : ' ');
    }
    return buffer.toString();
  }
}

class _Span {
  const _Span(this.start, this.end, this.overlap);

  final int start;
  final int end;

  /// Leading sentences shared with the previous chunk.
  final int overlap;
}
