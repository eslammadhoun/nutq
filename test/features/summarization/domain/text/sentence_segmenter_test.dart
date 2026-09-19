import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';

void main() {
  const segmenter = SentenceSegmenter();
  List<String> texts(String s) => segmenter.segment(s).map((e) => e.text).toList();

  test('splits on Arabic and Latin terminators', () {
    expect(
      texts('ما هو الذكاء الاصطناعي؟ هو علم حديث. مهم جدا! نعم؛ بالتأكيد.'),
      ['ما هو الذكاء الاصطناعي؟', 'هو علم حديث.', 'مهم جدا!', 'نعم؛', 'بالتأكيد.'],
    );
  });

  test('does not split inside decimals or version numbers', () {
    expect(texts('بلغت النسبة 3.5 في المئة في الإصدار 1.2.3 من النظام.'), hasLength(1));
  });

  test('does not split after abbreviations or list markers', () {
    expect(texts('قال د. أحمد إن النتيجة جيدة.'), hasLength(1));
    expect(texts('1. الخطوة الأولى مهمة'), hasLength(1));
  });

  test('treats line breaks as boundaries and blank lines as paragraph ends', () {
    final s = segmenter.segment('السطر الأول\nالسطر الثاني\n\nفقرة جديدة');
    expect(s.map((e) => e.text), ['السطر الأول', 'السطر الثاني', 'فقرة جديدة']);
    expect(s.map((e) => e.endsParagraph), [false, true, true]);
    expect(s.map((e) => e.index), [0, 1, 2]);
  });

  test('commas and colons alone are not sentence boundaries', () {
    expect(texts('أولا، ثانيا: ثالثا'), hasLength(1));
  });

  test('splits a long punctuation-free run-on at clause punctuation', () {
    final clause = List.filled(25, 'كلمة').join(' ');
    final text = '$clause، $clause، $clause، $clause';
    final parts = const SentenceSegmenter(maxWords: 60).segment(text);
    expect(parts.length, greaterThan(1));
    expect(parts.every((p) => p.text.split(' ').length <= 60), isTrue);
  });

  test('hard-splits a long run-on with no punctuation at all', () {
    final text = List.filled(200, 'كلمة').join(' ');
    final parts = const SentenceSegmenter(maxWords: 50).segment(text);
    expect(parts.length, greaterThanOrEqualTo(4));
    expect(parts.map((p) => p.text).join(' '), text);
  });

  test('empty input yields no sentences', () {
    expect(segmenter.segment('   \n\n  '), isEmpty);
  });
}
