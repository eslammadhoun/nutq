/// Turns the fine-tuned model's markdown into plain text the summary view
/// can show as-is.
///
/// The model sometimes answers with `**bold**` terms and numbered lists
/// written inline (`… المختلفة: 1. **X:** … 2. **Y:** …`). The view is plain
/// text, so the asterisks showed literally and the list ran together. Bold
/// markers are dropped, and each list item starts its own line.
String plainSummaryText(String text) {
  var t = text
      .replaceAll(RegExp(r'\*\*|__'), '')
      .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '• ');

  // A number followed by ". " starts a list item when it comes after a
  // colon, a sentence end or another item, not in the middle of a phrase
  // such as "سنة 1950. وفي".
  t = t.replaceAllMapped(
    RegExp(r'([:.!?؟؛…])\s+(\d{1,2}\.\s)'),
    (m) => '${m[1]}\n${m[2]}',
  );

  return t.replaceAll(RegExp(r'[ \t]+\n'), '\n').trim();
}

/// Drops the chat-style lines the model introduces a summary with instead of
/// writing it: "Here's an analysis-oriented summary:", "This text",
/// "إليك ملخص النص:". A line is only dropped when it is short and names the
/// summary or the text itself, so a real lead-in such as
/// "ينقسم التعلم إلى ثلاثة أنواع:" stays.
String stripChatPreamble(String text) {
  final kept = text.split('\n').where((line) => !_isPreamble(line.trim()));
  return kept.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

bool _isPreamble(String line) {
  if (line.isEmpty) return false;
  final words = line.split(RegExp(r'\s+')).length;
  if (words > 12) return false;
  if (line.endsWith(':') && _preambleIntro.hasMatch(line)) return true;
  return words <= 3 && _preambleStub.hasMatch(line);
}

final RegExp _preambleIntro = RegExp(
  r"\b(summary|summarize|here(['’]s)?)\b|ملخص|تلخيص|إليك",
  caseSensitive: false,
);

final RegExp _preambleStub = RegExp(
  r'^((this|the) (text|passage|lecture)|summary|الملخص|ملخص|ملخص النص)[:.]?$',
  caseSensitive: false,
);

/// Share of the letters in [text] that are Latin. Arabic lecture summaries
/// keep English terms (Overfitting, Tokens), which stays well under half.
double latinShare(String text) {
  final latin = _latinLetter.allMatches(text).length;
  final all = _anyLetter.allMatches(text).length;
  return all == 0 ? 0 : latin / all;
}

/// Drops paragraphs written mostly in Latin script. On passages dense with
/// English terms the 1B models sometimes switch to English mid-summary
/// ("This text discusses overfitting…"); for an Arabic source that paragraph
/// is dropped, and the points it was about stay uncovered for the gap pass
/// to send again.
String dropOffLanguageParagraphs(String text) {
  final kept = text
      .split(RegExp(r'\n\s*\n'))
      .where((p) => p.trim().isNotEmpty && latinShare(p) <= 0.5);
  return kept.join('\n\n').trim();
}

final RegExp _latinLetter = RegExp(r'[A-Za-z]');
final RegExp _anyLetter = RegExp(r'\p{L}', unicode: true);

/// Output that is not language at all, which is what a model whose arithmetic
/// is broken writes — the GPU backend on the iOS Simulator produced
/// `ৈতন্য بالcameraAutoFocus SRPGoGet <unused607> 𒄝…`: control tokens that
/// never belong in text, and letters from many unrelated scripts at once.
/// Real summaries, even Arabic with English terms, use one or two scripts.
bool looksCorrupted(String text) {
  if (_controlToken.hasMatch(text)) return true;
  if (_anyLetter.allMatches(text).length < 30) return false;
  final scripts = _scripts.where((s) => s.allMatches(text).length >= 3).length;
  return scripts >= 4;
}

final RegExp _controlToken = RegExp(r'<unused\d+>|<bos>|<pad>');

final List<RegExp> _scripts = [
  for (final script in const [
    'Latin',
    'Arabic',
    'Cyrillic',
    'Greek',
    'Hebrew',
    'Devanagari',
    'Bengali',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Thai',
    'Hangul',
    'Han',
    'Hiragana',
    'Katakana',
    'Cuneiform',
    'Georgian',
    'Armenian',
  ])
    RegExp('\\p{Script=$script}', unicode: true),
];

/// Removes the reporting phrase a paragraph opens with — "يتحدث الكاتب عن",
/// "يتحدث النص عن", "يستعرض", "يشير إلى أن" — so it starts with what was
/// said. Each section is summarized on its own, and the news-trained model
/// opened every one of a long talk's 23 paragraphs with "يتحدث الكاتب عن…";
/// the source may be a video, so "الكاتب" was wrong as well as repetitive.
/// A sentence that is nothing but the phrase is left as it was.
String stripReportingPhrases(String paragraph) {
  var p = paragraph.replaceAll(_reportedBy, '');
  p = p.replaceFirst(_reportingStart, '');
  p = p.replaceAll(_reportedClause, '');
  p = p.replaceFirst(RegExp(r'^[\s،,:؛-]+'), '').trim();
  return p.isEmpty ? paragraph.trim() : p;
}

const _verb =
    'يتحدث|يتناول|يستعرض|يناقش|يعرض|يركز|يشرح|يصف|يوضح|يؤكد|يشير|'
    'يتطرق|يسلط الضوء';
const _who =
    'الكاتب|الكاتبة|المؤلف|النص|المقال|المتحدث|المتحدثة|المحاضر|'
    'المحاضرة|الفيديو|المقطع|المحتوى|الحلقة|البرنامج|التقرير';
const _also = r'(?:\s+(?:أيضًا|أيضا))?';
const _prep = r'(?:(?:عن|حول|على|إلى أن|إلى|أن)\s+)?';
const _sentenceStart = r'(?:^|(?<=[.!?؟؛…]\s))';

/// "يتحدث الكاتب عن …", "يتحدث الكاتب، ففا، عن …" at any sentence start.
final RegExp _reportedBy = RegExp(
  '$_sentenceStart(?:كما\\s+)?(?:$_verb)\\s+(?:$_who)$_also'
  r'(?:\s*،\s*[^\s،."«»]+(?:\s+[^\s،."«»]+){0,2}\s*،)?(?:\s*،)?\s*'
  '$_prep',
  multiLine: true,
);

/// "يستعرض تجربة …" with no subject, at the paragraph start only.
final RegExp _reportingStart = RegExp(
  '^(?:كما\\s+)?(?:يتحدث|يتناول|يستعرض|يناقش|يتطرق)$_also'
  r'\s+(?:(?:عن|حول|إلى)\s+)?',
);

/// "يشير إلى أن البيانات …" at a sentence start: the clause after "أن" is
/// a full statement on its own.
final RegExp _reportedClause = RegExp(
  '$_sentenceStart(?:كما\\s+)?(?:يشير|يؤكد|يوضح)\\s+(?:إلى\\s+)?أن\\s+',
  multiLine: true,
);
