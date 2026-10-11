import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/key_line_extractor.dart';

/// A fake lecture in Moonshine's shape: one short line per `\n`, several
/// topics in a row, each padded with spoken filler.
String _lecture({int repeats = 1}) {
  const topics = [
    [
      'الشبكات العصبية تتكون من طبقات من الخلايا العصبية الاصطناعية',
      'كل خلية عصبية تستقبل مدخلات وتضربها في أوزان',
      'الشبكات العصبية تتعلم عن طريق تعديل الأوزان',
    ],
    [
      'خوارزمية الانحدار التدريجي تقلل دالة الخسارة خطوة بخطوة',
      'معدل التعلم يحدد حجم الخطوة في الانحدار التدريجي',
      'إذا كان معدل التعلم كبيرا جدا فإن الخسارة لا تتقارب',
    ],
    [
      'البيانات تقسم إلى تدريب واختبار بنسبة 80 إلى 20 بالمئة',
      'بيانات الاختبار لا يراها النموذج أثناء التدريب',
      'الإفراط في التدريب يعني أن النموذج يحفظ بيانات التدريب',
    ],
    [
      'المحولات تعتمد على آلية الانتباه بدل التكرار',
      'آلية الانتباه تحسب أهمية كل كلمة بالنسبة للكلمات الأخرى',
      'نماذج اللغة الكبيرة مبنية على المحولات',
    ],
  ];

  const filler = 'طيب يعني زي ما قلنا كده يعني تمام خلاص';

  final lines = <String>[];
  for (var r = 0; r < repeats; r++) {
    for (final topic in topics) {
      for (final line in topic) {
        lines
          ..add(filler)
          ..add(line)
          ..add(filler);
      }
    }
  }
  return lines.join('\n');
}

int _words(String text) => text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

void main() {
  const extractor = KeyLineExtractor(sectionCount: 4);

  test('text within budget is returned whole', () {
    const text = 'سطر أول قصير\nسطر ثان قصير';
    final result = extractor.extract(text, maxWords: 100);

    expect(result.wasReduced, isFalse);
    expect(result.text, 'سطر أول قصير سطر ثان قصير');
  });

  test('stays within the word budget', () {
    final text = _lecture(repeats: 5);
    final result = extractor.extract(text, maxWords: 150);

    expect(result.wasReduced, isTrue);
    expect(result.keptWords, lessThanOrEqualTo(150));
    expect(_words(result.text), result.keptWords);
    expect(result.keptWords, greaterThan(100), reason: 'budget mostly used');
  });

  test('covers every topic, beginning to end', () {
    final result = extractor.extract(_lecture(repeats: 3), maxWords: 120);

    for (final keyword in ['العصبية', 'الانحدار', 'الاختبار', 'الانتباه']) {
      expect(result.text, contains(keyword), reason: keyword);
    }
  });

  test('keeps picked lines in source order', () {
    final text = _lecture(repeats: 2);
    final source = text.replaceAll(RegExp(r'\s+'), ' ');
    final result = extractor.extract(text, maxWords: 120);

    // Each picked unit must be found after the previous one.
    var from = 0;
    for (final unit in result.text.split('\n')) {
      final at = source.indexOf(unit, from);
      expect(at, greaterThanOrEqualTo(0), reason: unit);
      from = at + unit.length;
    }
  });

  test('does not pick the same content twice', () {
    final result = extractor.extract(_lecture(repeats: 6), maxWords: 200);
    final units = result.text.split('\n');

    expect(units.toSet().length, units.length);
  });

  test('normalize folds Arabic spelling variants and the article', () {
    expect(KeyLineExtractor.normalize('الإفراط'), KeyLineExtractor.normalize('افراط'));
    expect(KeyLineExtractor.normalize('بالشبكة'), KeyLineExtractor.normalize('شبكه'));
    expect(KeyLineExtractor.normalize('مَعْدَل'), 'معدل');
  });

  test('a 2-hour lecture is reduced in well under a second', () {
    // ~23k words, the size of the 2h17m Moonshine run (22,727 words).
    final text = _lecture(repeats: 80);
    expect(_words(text), greaterThan(20000));

    final clock = Stopwatch()..start();
    final result = const KeyLineExtractor().extract(text, maxWords: 1200);
    clock.stop();

    // The fake lecture is 12 distinct lines repeated, so the redundancy
    // filter rightly keeps far fewer than 1200 words; a real one fills it.
    expect(result.keptWords, lessThanOrEqualTo(1200));
    expect(clock.elapsedMilliseconds, lessThan(1000));
    // ignore: avoid_print
    print(
      'extract ${_words(text)} words -> ${result.keptWords} '
      'in ${clock.elapsedMilliseconds} ms',
    );
  });
}
