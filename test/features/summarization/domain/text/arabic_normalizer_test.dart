import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';

void main() {
  test('removes diacritics and tatweel', () {
    expect(ArabicNormalizer.removeDiacritics('مُحَمَّدٌ'), 'محمد');
    expect(ArabicNormalizer.removeDiacritics('العـــربية'), 'العربية');
  });

  test('normalizes alef variants', () {
    expect(ArabicNormalizer.normalizeAlef('أحمد إبراهيم آدم'), 'احمد ابراهيم ادم');
  });

  test('maps Arabic-Indic and Persian digits to ASCII', () {
    expect(ArabicNormalizer.normalizeDigits('٢٠٢٤ و ۱۲۳'), '2024 و 123');
  });

  test('normalizes punctuation and whitespace', () {
    expect(ArabicNormalizer.normalize('هل   ذلك  صحيح؟ نعم،  ٥٪'), 'هل ذلك صحيح? نعم, 5%');
  });

  test('contentTokens drops stop words and stems the definite article', () {
    final tokens = ArabicNormalizer.contentTokens('في المدرسة الكبيرة');
    expect(tokens, ['مدرسة', 'كبيرة']);
  });

}
