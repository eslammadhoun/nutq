import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/fact_extractor.dart';

void main() {
  const extractor = FactExtractor();

  test('extracts plain numbers (incl. Arabic-Indic digits)', () {
    final facts = extractor.extract('حضر ٢٥٠ شخصا وتبرعوا بمبلغ 1,500 دولار');
    expect(facts.numbers, containsAll(['250', '1.500']));
  });

  test('extracts percentages separately from numbers', () {
    final facts = extractor.extract('ارتفعت المبيعات 37.5% وانخفضت التكلفة 12 بالمئة');
    expect(facts.percentages, containsAll(['37.5%', '12بالمئة']));
    expect(facts.numbers, isEmpty);
  });

  test('extracts dates, years and day+month', () {
    final facts = extractor.extract('في 15/03/2024 وفي 5 مارس 2023 وعام 1999');
    expect(facts.dates, containsAll(['15/03/2024', '5 مارس 2023', '1999']));
    expect(facts.numbers, isEmpty);
  });

  test('extracts version strings', () {
    final facts = extractor.extract('استخدمنا Flutter v3 و النسخة 1.2.3');
    expect(facts.versions, containsAll(['v3', '1.2.3']));
  });

  test('extracts Latin technical terms, lowercased', () {
    final facts = extractor.extract('نستخدم Flutter مع BLoC و REST API');
    expect(facts.terms, containsAll(['flutter', 'bloc', 'rest', 'api']));
  });

  test('extracts Arabic entities after title / institution markers', () {
    final facts = extractor.extract('قال الدكتور أحمد محمد في جامعة القاهرة إن شركة أرامكو مهمة');
    expect(facts.entities, contains('الدكتور احمد محمد'));
    expect(facts.entities, contains('جامعة القاهرة'));
    expect(facts.entities, contains('شركة ارامكو'));
  });

  test('plain text yields empty sets', () {
    final facts = extractor.extract('هذا نص عادي بلا أرقام');
    expect(facts.numbers, isEmpty);
    expect(facts.dates, isEmpty);
    expect(facts.terms, isEmpty);
  });
}
