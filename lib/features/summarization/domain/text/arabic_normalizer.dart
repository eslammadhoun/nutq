/// Arabic-aware normalization for **comparison only** (evaluation, fact
/// matching, claim support). Never apply it to user-visible text.
class ArabicNormalizer {
  const ArabicNormalizer._();

  static final _diacritics = RegExp(r'[\u064B-\u065F\u0670\u0640]');
  static final _alefVariants = RegExp(r'[\u0623\u0625\u0622\u0671]');
  static final _whitespace = RegExp(r'\s+');
  static final _wordSplit = RegExp(r'[^\p{L}\p{N}_+#]+', unicode: true);

  static const _arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  static const _persianIndic = '۰۱۲۳۴۵۶۷۸۹';

  /// Very small function-word list; enough to keep overlap scores from being
  /// dominated by particles.
  static const stopWords = <String>{
    'في', 'من', 'على', 'الى', 'إلى', 'عن', 'ان', 'أن', 'إن', 'ما', 'هذا',
    'هذه', 'ذلك', 'تلك', 'هو', 'هي', 'كان', 'كانت', 'التي', 'الذي', 'الذين',
    'ثم', 'او', 'أو', 'و', 'لا', 'لم', 'لن', 'قد', 'كل', 'مع', 'بعد', 'قبل',
    'عند', 'كما', 'لكن', 'اذا', 'إذا', 'حتى', 'هنا', 'هناك', 'يعني', 'طيب',
  };

  static String removeDiacritics(String s) => s.replaceAll(_diacritics, '');

  static String normalizeAlef(String s) => s.replaceAll(_alefVariants, 'ا');

  /// Arabic-Indic and Persian digits → ASCII digits.
  static String normalizeDigits(String s) {
    final out = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final a = _arabicIndic.indexOf(ch);
      final p = _persianIndic.indexOf(ch);
      out.write(a >= 0 ? '$a' : (p >= 0 ? '$p' : ch));
    }
    return out.toString();
  }

  static String normalizePunctuation(String s) => s
      .replaceAll('،', ',')
      .replaceAll('؛', ';')
      .replaceAll('؟', '?')
      .replaceAll('٪', '%')
      .replaceAll('٫', '.');

  /// Full comparison normalization: diacritics, alef variants, digits,
  /// punctuation, whitespace, lowercase Latin.
  static String normalize(String s) {
    var out = removeDiacritics(s);
    out = normalizeAlef(out);
    out = normalizeDigits(out);
    out = normalizePunctuation(out);
    out = out.toLowerCase();
    return out.replaceAll(_whitespace, ' ').trim();
  }

  /// Light prefix stripping (conjunction/preposition + definite article).
  static String stem(String token) {
    var t = token;
    for (final prefix in const ['وال', 'بال', 'كال', 'فال', 'لل', 'ال']) {
      if (t.startsWith(prefix) && t.length - prefix.length >= 2) {
        t = t.substring(prefix.length);
        break;
      }
    }
    if (t.startsWith('و') && t.length >= 5) t = t.substring(1);
    return t;
  }

  /// Normalized, stemmed, stop-word-free tokens used for overlap scoring.
  static List<String> contentTokens(String s) {
    final normalized = normalize(s);
    return normalized
        .split(_wordSplit)
        .where((t) => t.isNotEmpty && !stopWords.contains(t))
        .map(stem)
        .where((t) => t.length >= 2)
        .toList();
  }
}
