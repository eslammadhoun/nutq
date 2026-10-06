import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/coverage.dart';
import 'package:nutq/features/summarization/domain/text/key_line_extractor.dart';
import 'package:nutq/features/summarization/domain/text/takeaways.dart';

void main() {
  // A real Arabic lecture on AI: it keeps returning to data (بيانات) and
  // intelligence (ذكاء).
  final source = File('test/features/summarization/fixtures/ai_lecture_ar.txt').readAsStringSync();
  final tracker = CoverageTracker(const KeyLineExtractor().analyze(source));

  List<String> pick(String summary, {int max = 5}) =>
      pickTakeaways(summary, keySources: tracker.important, ignore: tracker.topicTerms, max: max);

  const onTopic = 'يعتمد الذكاء الاصطناعي على البيانات وجودتها في تدريب النماذج وتحسينها.';
  const offTopic = 'كان الجو مشمسا وارتدى الحضور ملابس صيفية خفيفة طوال اليوم.';

  test('picks the summary sentences about what the source keeps coming back to', () {
    expect(pick('$offTopic\n\n$onTopic', max: 1), [onTopic]);
  });

  test('keeps summary order and skips a sentence that mostly repeats one taken', () {
    const second = 'تحتاج نماذج الذكاء الاصطناعي إلى كميات كبيرة من البيانات للتعلم بشكل جيد.';
    const repeat = 'يعتمد الذكاء الاصطناعي على البيانات وجودتها في تدريب النماذج.';
    final picked = pick('$onTopic\n$repeat\n$second');
    expect(picked.first, onTopic, reason: 'summary order');
    expect(picked, isNot(contains(repeat)));
  });

  test('skips sentences cut short, too short or too long', () {
    final summary = [
      'يعتمد الذكاء الاصطناعي على البيانات وجودتها في تدريب النماذج', // cut at the cap
      'البيانات مهمة.', // too short
      '${List.filled(45, 'البيانات').join(' ')}.', // too long
    ].join('\n');
    expect(pick(summary), isEmpty);
  });

  test('returns at most max, and none when nothing matches', () {
    expect(pick(offTopic), isEmpty);
    final many = List.generate(
      8,
      (i) => 'في المثال رقم $i يستخدم الذكاء الاصطناعي البيانات بطريقة مختلفة عن غيره تماما.',
    ).join('\n');
    expect(pick(many, max: 3).length, lessThanOrEqualTo(3));
  });
}
