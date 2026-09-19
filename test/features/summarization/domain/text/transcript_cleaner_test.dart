import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/transcript_cleaner.dart';

void main() {
  const cleaner = TranscriptCleaner();

  test('normalizes whitespace and line endings', () {
    expect(cleaner.clean('مرحبا   بكم\r\nفي   الدرس\t\tاليوم'), 'مرحبا بكم\nفي الدرس اليوم');
  });

  test('collapses repeated punctuation', () {
    expect(cleaner.clean('ماذا؟؟؟ نعم!!! حسنا،،، ثم....... انتهى'), 'ماذا؟ نعم! حسنا، ثم... انتهى');
  });

  test('removes bracketed sound tags and invisible characters', () {
    expect(cleaner.clean('بدأنا [موسيقى] الدرس (تصفيق) الآن​'), 'بدأنا الدرس الآن');
  });

  test('keeps at most two consecutive repeats of a word', () {
    expect(cleaner.clean('جدا جدا جدا جدا مهم'), 'جدا جدا مهم');
  });

  test('preserves discourse words', () {
    const text = 'يعني طيب لكن لذلك بالتالي نبدأ';
    expect(cleaner.clean(text), text);
  });

  test('preserves numbers, dates, English terms and code-like tokens', () {
    const text = 'في 15/03/2024 استخدمنا Flutter 3.44 و state_management و 100 100 100';
    expect(cleaner.clean(text), text);
  });

  test('keeps paragraph breaks but collapses extra blank lines', () {
    expect(cleaner.clean('الفقرة الأولى\n\n\n\n\nالفقرة الثانية'), 'الفقرة الأولى\n\nالفقرة الثانية');
  });

  test('empty and whitespace-only input yield an empty string', () {
    expect(cleaner.clean(''), '');
    expect(cleaner.clean('  \n \t '), '');
  });
}
