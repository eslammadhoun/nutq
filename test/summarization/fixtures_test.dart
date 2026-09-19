import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/benchmark/benchmark_fixture.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';

Future<List<BenchmarkFixture>> loadFixtures() => BenchmarkFixture.loadDirectory(Directory('test/summarization/fixtures'));

void main() {
  test('dataset has 3 short, 3 medium and 3 long fixtures', () async {
    final fixtures = await loadFixtures();
    int count(String size) => fixtures.where((f) => f.size == size).length;
    expect(fixtures, hasLength(9));
    expect([count('short'), count('medium'), count('long')], [3, 3, 3]);
    expect(fixtures.map((f) => f.id).toSet(), hasLength(9));
  });

  test('every fixture is well-formed Arabic with reference material', () async {
    for (final f in await loadFixtures()) {
      expect(f.language, 'ar', reason: f.id);
      expect(f.transcript.trim(), isNotEmpty, reason: f.id);
      expect(f.referenceSummary.trim(), isNotEmpty, reason: f.id);
      expect(f.importantFacts, isNotEmpty, reason: f.id);
      expect(f.importantNumbers, isNotEmpty, reason: f.id);
      expect(f.durationMinutes, greaterThan(0), reason: f.id);
      expect(RegExp(r'[؀-ۿ]').hasMatch(f.transcript), isTrue, reason: f.id);
    }
  });

  test('all important numbers and entities really occur in the transcript', () async {
    for (final f in await loadFixtures()) {
      final transcript = ArabicNormalizer.normalize(f.transcript);
      for (final v in [...f.importantNumbers, ...f.importantEntities]) {
        expect(transcript, contains(ArabicNormalizer.normalize(v)), reason: '${f.id}: "$v"');
      }
    }
  });

  test('reference summaries are shorter than their transcripts', () async {
    for (final f in await loadFixtures()) {
      expect(f.referenceSummary.length, lessThan(f.transcript.length), reason: f.id);
    }
  });

  test('coverage of the dataset spans the required categories', () async {
    final tags = (await loadFixtures()).expand((f) => f.category.split(',')).toSet();
    for (final t in ['msa', 'levantine', 'conversational', 'technical', 'educational', 'numbers', 'dates', 'english_terms', 'repetition', 'long_context']) {
      expect(tags, contains(t));
    }
  });
}
