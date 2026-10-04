import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/coverage.dart';
import 'package:nutq/features/summarization/domain/text/key_line_extractor.dart';
import 'package:nutq/features/summarization/domain/text/transcript_cleaner.dart';

void main() {
  final source = cleanTranscriptSeams(
    File('test/features/summarization/fixtures/aljazeera_af_pk.txt').readAsStringSync(),
  );
  final tracker = CoverageTracker(const KeyLineExtractor().analyze(source));

  // What the fine-tuned v2 model wrote for this clip on 2026-09-26.
  const v2Summary =
      'أفاد مسؤولون أفغانيون بأن ثلاثة أشخاص قتلوا في غارات جوية على ولاية '
      'كونار شرقي، بينما أعلنت الباكستانية أن ثمانية وعشرين شخصا قتلوا في '
      'هجمات إرهابية على أفغانستان. في سياق متصل، أكدت الحكومة الأفغانية أنها '
      'لا تقبل هذه الأحداث، مشددة على أنها تضع العلاقات الأفغانية الباكستانية '
      'في وضع غير جيد بسبب تدهور الأوضاع في أفغانستان.';

  test('the source itself is fully covered', () {
    expect(tracker.ratio(source), 1);
  });

  test('an empty summary covers nothing', () {
    expect(tracker.ratio(''), 0);
  });

  test('the short v2 summary leaves the second half uncovered', () {
    final missing = tracker.uncovered(v2Summary);
    final ratio = tracker.ratio(v2Summary);

    // ignore: avoid_print
    print(
      'important ${tracker.important.length}/${tracker.units.length}, '
      'covered ${(ratio * 100).round()}%, missing:\n'
      '${missing.map((u) => '  [${u.index}] ${u.keyTerms} ${u.text.substring(0, 50)}').join('\n')}',
    );

    expect(ratio, lessThan(0.95));
    final missingText = missing.map((u) => u.text).join(' ');
    expect(missingText, contains('الهندية'), reason: 'India claim not covered');
    expect(missingText, contains('إغلاق الحدود'), reason: 'border closure not covered');
  });

  test('restated sentences are dropped, new ones kept', () {
    const existing = 'قتل ثلاثة أشخاص في غارات باكستانية على ولاية كونار شرقي أفغانستان.';
    const addition =
        'قتل ثلاثة أشخاص في غارات باكستانية على ولاية كونار. '
        'والحدود بين البلدين مغلقة منذ سنة كاملة وسط اتهامات بدعم هندي.';
    expect(
      dropRestatedSentences(addition, existing),
      'والحدود بين البلدين مغلقة منذ سنة كاملة وسط اتهامات بدعم هندي.',
    );
  });

  group('AI lecture: key points and filler', () {
    final units = const KeyLineExtractor().analyze(
      File('test/features/summarization/fixtures/ai_lecture_ar.txt').readAsStringSync(),
    );
    final lecture = CoverageTracker(units, importanceFactor: 1.0);
    int words(List<SourceUnit> us) => us.fold(0, (s, u) => s + u.wordCount);

    test('key points are about half the lecture, not nearly all of it', () {
      // ignore: avoid_print
      print(
        'units ${units.length} (${words(units)}w), '
        'key ${lecture.important.length} (${words(lecture.important)}w), '
        'read ${lecture.substantive.length} (${words(lecture.substantive)}w)',
      );
      expect(lecture.important.length, lessThan(units.length * 0.6));
      expect(lecture.important.length, greaterThan(units.length * 0.4));
    });

    test('filler is not read; every key point is', () {
      expect(lecture.substantive.length, lessThan(units.length));
      expect(lecture.substantive, containsAll(lecture.important));
    });
  });
}
