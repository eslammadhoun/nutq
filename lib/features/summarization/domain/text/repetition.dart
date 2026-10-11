/// Generation-loop and prompt-echo guards for model output.
library;

final RegExp _sentenceSplit = RegExp(r'(?<=[.!?؟؛…])\s+');

/// Detects obvious generation loops.
///
/// This is intentionally conservative: legitimate repeated words stay, obvious
/// model degeneration does not.
bool hasSevereRepetition(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return false;

  final words = normalized.split(' ');

  // Very short outputs are never classified as repetitive.
  if (words.length < 20) return false;

  // 1. Exact sentence repetition.
  final sentences = normalized
      .split(_sentenceSplit)
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (sentences.length >= 4) {
    final counts = <String, int>{};
    for (final sentence in sentences) {
      final key = sentence.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
      if (counts[key]! >= 3) return true;
    }
  }

  // 2. Repeated word n-grams.
  if (words.length >= 30) {
    for (final n in [5, 7, 10]) {
      if (_hasRepeatedNGram(words, n)) return true;
    }
  }

  // 3. Very high duplicate word ratio. The threshold is high: Arabic summaries
  // naturally repeat common words.
  final uniqueRatio = words.toSet().length / words.length;
  return words.length >= 80 && uniqueRatio < 0.20;
}

bool _hasRepeatedNGram(List<String> words, int n) {
  if (words.length < n * 3) return false;
  final counts = <String, int>{};
  for (var i = 0; i <= words.length - n; i++) {
    final gram = words.sublist(i, i + n).join(' ').toLowerCase();
    counts[gram] = (counts[gram] ?? 0) + 1;
    // A long exact sequence repeated 3 times is almost certainly a loop.
    if (counts[gram]! >= 3) return true;
  }
  return false;
}

/// Removes a generation loop: "A B C D. A B C D. A B C D." becomes "A B C D."
String removeRepetitionTail(String text) {
  var result = text.trim();
  if (result.isEmpty) return result;

  // 1. Sentence-level repetition: keep everything before the first repeat.
  final sentences = result
      .split(_sentenceSplit)
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (sentences.length >= 4) {
    final output = <String>[];
    final seen = <String>{};
    for (final sentence in sentences) {
      final normalized = sentence.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
      if (!seen.add(normalized)) break;
      output.add(sentence);
    }
    if (output.isNotEmpty && output.length < sentences.length) {
      result = output.join(' ');
    }
  }

  // 2. Repeated n-gram tail.
  final words = result.split(RegExp(r'\s+'));
  if (words.length >= 30) {
    for (final n in [10, 7, 5]) {
      final cutIndex = _findRepetitionCutIndex(words, n);
      if (cutIndex != null && cutIndex > 10) {
        result = words.sublist(0, cutIndex).join(' ');
        break;
      }
    }
  }

  return result.trim();
}

int? _findRepetitionCutIndex(List<String> words, int n) {
  if (words.length < n * 3) return null;
  final counts = <String, List<int>>{};
  for (var i = 0; i <= words.length - n; i++) {
    final gram = words.sublist(i, i + n).join(' ').toLowerCase();
    final positions = counts.putIfAbsent(gram, () => <int>[])..add(i);
    // Only a loop when the repetitions are close to each other.
    if (positions.length >= 3 && positions.last - positions.first <= n * 4) {
      return positions.first + n;
    }
  }
  return null;
}

/// Fixed instructional phrases that only ever appear in our own prompts, never
/// in real source text or a genuine summary.
///
/// A small model given little real content can degenerate into echoing the
/// prompt back as its "summary". That echo is one coherent block, not a loop,
/// so [hasSevereRepetition] does not catch it.
const List<String> _promptLeakageMarkers = [
  'قواعد صارمة',
  'لخّص الجزء التالي',
  'اكتب الملخص فقط',
  'اكتب الملخص النهائي فقط',
  'اكتب الملخص الآن',
  'لا تخترع معلومات',
  'لا تستنتج معلومات',
  'لخّص النص التالي',
  'اكتب بالعربية فقط',
  'لا تجب عن أي سؤال',
  'Strict rules:',
  'Summarize the following part',
  'Summarize the following text',
  'Write only the summary:',
  'Write the summary now:',
  'Do not invent information.',
];

/// Truncates [text] where the earliest prompt marker appears.
String stripPromptLeakage(String text) {
  var earliest = text.length;
  for (final marker in _promptLeakageMarkers) {
    final index = text.indexOf(marker);
    if (index != -1 && index < earliest) earliest = index;
  }
  return earliest == text.length ? text : text.substring(0, earliest).trim();
}
