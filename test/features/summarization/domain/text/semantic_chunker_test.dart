import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/entities/sentence.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/text/semantic_chunker.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// One token per word, so budgets in tests are exact and easy to reason about.
class _WordCounter implements TokenCounter {
  @override
  Future<int> count(String text) async => text.trim().split(RegExp(r'\s+')).length;
}

List<Sentence> _sentences(int count, {int words = 10, Set<int> paragraphEnds = const {}}) => [
  for (var i = 0; i < count; i++)
    Sentence(
      index: i,
      text: '${List.filled(words - 1, 'كلمة').join(' ')} $i.',
      endsParagraph: paragraphEnds.contains(i),
    ),
];

const _config = SummarizationConfig(
  targetTokens: 100,
  overlapTokens: 20,
  minTokens: 60,
  maxTokens: 150,
);

void main() {
  final chunker = SemanticChunker(_WordCounter());

  test('case 1: short transcript → exactly one chunk', () async {
    final chunks = await chunker.chunk(_sentences(3), _config);
    expect(chunks, hasLength(1));
    expect(chunks.single.id, 0);
    expect(chunks.single.startSentenceIndex, 0);
    expect(chunks.single.endSentenceIndex, 2);
  });

  test('case 2: long transcript → multiple ordered chunks with sequential ids', () async {
    final chunks = await chunker.chunk(_sentences(60), _config);
    expect(chunks.length, greaterThan(3));
    expect([for (final c in chunks) c.id], List.generate(chunks.length, (i) => i));
    for (var i = 1; i < chunks.length; i++) {
      expect(chunks[i].startSentenceIndex, greaterThan(chunks[i - 1].startSentenceIndex));
      expect(chunks[i].endSentenceIndex, greaterThan(chunks[i - 1].endSentenceIndex));
    }
    expect(chunks.last.endSentenceIndex, 59);
  });

  test('every sentence is covered and chunks never exceed max (within tail slack)', () async {
    final chunks = await chunker.chunk(_sentences(60), _config);
    final covered = <int>{};
    for (final c in chunks) {
      for (var i = c.startSentenceIndex; i <= c.endSentenceIndex; i++) {
        covered.add(i);
      }
      expect(c.tokenCount, lessThanOrEqualTo((_config.maxTokens * 1.25).ceil()));
    }
    expect(covered, {for (var i = 0; i < 60; i++) i});
  });

  test('case 3: never cuts inside a sentence', () async {
    final sentences = _sentences(40);
    final chunks = await chunker.chunk(sentences, _config);
    for (final c in chunks) {
      final expected = sentences
          .sublist(c.startSentenceIndex, c.endSentenceIndex + 1)
          .map((s) => s.text)
          .join(' ');
      expect(c.text, expected);
    }
  });

  test('case 4: one large paragraph splits safely on sentence boundaries', () async {
    final sentences = _sentences(50); // no paragraph ends at all
    final chunks = await chunker.chunk(sentences, _config);
    expect(chunks.length, greaterThan(1));
    for (final c in chunks) {
      for (final s in sentences.sublist(c.startSentenceIndex, c.endSentenceIndex + 1)) {
        expect(c.text, contains(s.text));
      }
    }
  });

  test('case 5: numbers survive chunking verbatim', () async {
    const sentences = [
      Sentence(index: 0, text: 'بلغت الإيرادات 1,250,000 دولار في 2024.'),
      Sentence(index: 1, text: 'وارتفعت النسبة إلى 37.5% مقارنة بالعام السابق.'),
    ];
    final chunks = await chunker.chunk(sentences, _config);
    final text = chunks.map((c) => c.text).join(' ');
    expect(text, contains('1,250,000'));
    expect(text, contains('2024'));
    expect(text, contains('37.5%'));
  });

  test('consecutive chunks overlap by whole sentences within the overlap budget', () async {
    final chunks = await chunker.chunk(_sentences(60), _config);
    for (var i = 1; i < chunks.length; i++) {
      final prev = chunks[i - 1];
      final cur = chunks[i];
      expect(
        cur.overlapSentenceCount,
        cur.startSentenceIndex <= prev.endSentenceIndex
            ? prev.endSentenceIndex - cur.startSentenceIndex + 1
            : 0,
      );
      expect(cur.overlapSentenceCount * 10, lessThanOrEqualTo(_config.overlapTokens));
    }
  });

  test('zero overlap produces disjoint chunks', () async {
    final chunks = await chunker.chunk(
      _sentences(60),
      const SummarizationConfig(targetTokens: 100, overlapTokens: 0, minTokens: 60, maxTokens: 150),
    );
    for (var i = 1; i < chunks.length; i++) {
      expect(chunks[i].startSentenceIndex, chunks[i - 1].endSentenceIndex + 1);
    }
  });

  test('prefers a paragraph boundary near the target size', () async {
    // Paragraph ends after sentence 8 (90 tokens ≥ 85% of target 100).
    final sentences = _sentences(30, paragraphEnds: {8});
    final chunks = await chunker.chunk(sentences, _config);
    expect(chunks.first.endSentenceIndex, 8);
  });

  test('avoids a tiny trailing chunk', () async {
    final chunks = await chunker.chunk(_sentences(11), _config); // 110 tokens
    expect(chunks, hasLength(1));
  });

  test('empty input yields no chunks', () async {
    expect(await chunker.chunk(const [], _config), isEmpty);
  });

  test('a single oversized sentence becomes its own chunk', () async {
    final sentences = [
      Sentence(index: 0, text: List.filled(400, 'كلمة').join(' ')),
      const Sentence(index: 1, text: 'جملة قصيرة.'),
    ];
    final chunks = await chunker.chunk(sentences, _config);
    expect(chunks.first.startSentenceIndex, 0);
    expect(chunks.first.tokenCount, 400);
  });
}
