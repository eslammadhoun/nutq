/// Shared sample transcripts, so tests describe *what* they need (several
/// chunks of Arabic, an English lecture) instead of each re-declaring the same
/// generator.
library;

/// [paragraphs] paragraphs of Arabic meeting notes containing a number, a year
/// and a named person, so number/date/entity checks have something to find.
/// Six paragraphs become several chunks under the small test budgets.
String arabicTranscript(int paragraphs) => List.generate(
  paragraphs,
  (i) =>
      'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024 وقال الدكتور أحمد محمد إن النتائج جيدة.',
).join('\n\n');

/// English equivalent of [arabicTranscript].
String englishTranscript(int paragraphs) => List.generate(
  paragraphs,
  (i) =>
      'In section $i we discuss machine learning. Attendance reached 250 people in 2024 and Dr Smith said results were good.',
).join('\n\n');

/// A long run of distinct Arabic words with sentence punctuation, for size and
/// performance tests (about [words] words).
String longArabicText(int words) =>
    List.generate(words, (i) => 'كلمة$i${i % 17 == 16 ? '.' : ''}').join(' ');
