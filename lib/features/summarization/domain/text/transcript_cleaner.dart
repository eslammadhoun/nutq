/// Conservative ASR-transcript cleanup.
///
/// Normalizes whitespace and punctuation, strips bracketed sound tags and
/// invisible characters, and collapses only *runs* of the same word beyond
/// two repetitions. Discourse words (يعني، طيب، لكن…), numbers, dates, names,
/// English terms and code-like tokens are never removed.
class TranscriptCleaner {
  const TranscriptCleaner();

  static final _invisible = RegExp(r'[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]');
  static final _soundTag = RegExp(
    r'[\[\(]\s*(?:موسيقى|تصفيق|ضحك|ضحكات|ضجيج|صمت|music|applause|laughter|noise|silence|inaudible)\s*[\]\)]',
    caseSensitive: false,
  );
  static final _horizontalSpace = RegExp(r'[ \t ]+');
  static final _manyNewlines = RegExp(r'\n{3,}');
  static final _longEllipsis = RegExp(r'\.{4,}');
  static final _repeatedBang = RegExp(r'!{2,}');
  static final _repeatedQuestion = RegExp(r'([؟?]){2,}');
  static final _repeatedComma = RegExp(r'([،,]){2,}');
  static final _repeatedSemicolon = RegExp(r'([؛;]){2,}');
  static final _spaceBeforePunct = RegExp(r'[ ]+([،؛؟!?,;:.])(?=\s|$)');
  static final _protectedToken = RegExp(r'[\d`_=(){}\[\]<>/\\@#$]');

  String clean(String raw) {
    var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    text = text.replaceAll(_invisible, '');
    text = text.replaceAll(_soundTag, ' ');
    text = text.replaceAll(_horizontalSpace, ' ');

    text = text.replaceAll(_longEllipsis, '...');
    text = text.replaceAll(_repeatedBang, '!');
    text = text.replaceAllMapped(_repeatedQuestion, (m) => m[1]!);
    text = text.replaceAllMapped(_repeatedComma, (m) => m[1]!);
    text = text.replaceAllMapped(_repeatedSemicolon, (m) => m[1]!);

    final lines = text.split('\n').map((line) {
      final collapsed = _collapseRepeatedWords(line.trim());
      return collapsed.replaceAllMapped(_spaceBeforePunct, (m) => m[1]!);
    });
    text = lines.join('\n').replaceAll(_manyNewlines, '\n\n');
    return text.trim();
  }

  /// Keeps at most two consecutive copies of the same word ("جدا جدا جدا جدا"
  /// → "جدا جدا"), preserving deliberate emphasis. Tokens containing digits
  /// or code-like symbols are never touched.
  String _collapseRepeatedWords(String line) {
    if (line.isEmpty) return line;
    final tokens = line.split(' ');
    final out = <String>[];
    var run = 0;
    String? previous;
    for (final token in tokens) {
      final key = token.toLowerCase();
      if (previous != null && key == previous && !_protectedToken.hasMatch(token)) {
        run++;
        if (run >= 2) continue;
      } else {
        run = 0;
      }
      previous = key;
      out.add(token);
    }
    return out.join(' ');
  }
}
