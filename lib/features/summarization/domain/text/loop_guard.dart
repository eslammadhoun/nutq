/// Detects, while a summary is still streaming, that the model has started
/// repeating itself — so generation can be stopped there instead of running
/// to the token cap.
///
/// A 1B model that loops does not recover: in testing it filled all 512
/// output tokens with `من من من …` or `باللغة العربية باللغة العربية …`,
/// which was two thirds of the run's time spent on text that was then cut.
///
/// Returns the length of [text] to keep, or null if the tail looks healthy.
/// Checked on every streamed chunk, so it only needs to look at the tail.
int? loopCut(String text) {
  final matches = _word.allMatches(text).toList();
  if (matches.length < 4) return null;

  final words = [for (final m in matches) _bare(m.group(0)!)];
  final n = words.length;

  // 1. The same phrase back to back at the end: `من من من من`, or
  //    `باللغة العربية باللغة العربية باللغة العربية`.
  for (var size = 1; size <= 8; size++) {
    final copies = size == 1 ? 4 : 3;
    if (n < size * copies) continue;

    var looping = true;
    for (var copy = 1; copy < copies && looping; copy++) {
      for (var k = 0; k < size; k++) {
        if (words[n - 1 - k] != words[n - 1 - k - copy * size]) {
          looping = false;
          break;
        }
      }
    }

    // A run of the same word can include legitimate doubling; four in a row
    // cannot. Walk back to where the run began and keep the first copy only.
    if (looping) {
      bool sameAsLast(int from) {
        for (var k = 0; k < size; k++) {
          if (words[from + k] != words[n - size + k]) return false;
        }
        return true;
      }

      var start = n - size * copies;
      while (start - size >= 0 && sameAsLast(start - size)) {
        start -= size;
      }
      return matches[start + size - 1].end;
    }
  }

  // 2. The last eight words already appeared earlier as one phrase: the model
  //    is restating a sentence it has written. Legitimate prose almost never
  //    repeats eight words verbatim within one short summary.
  const phrase = 8;
  if (n >= phrase * 2) {
    final tail = words.sublist(n - phrase).join(' ');
    for (var i = 0; i + phrase <= n - phrase; i++) {
      if (words.sublist(i, i + phrase).join(' ') == tail) {
        final start = matches[n - phrase].start;
        return _sentenceStartBefore(text, start);
      }
    }
  }

  return null;
}

/// Cuts back to the start of the sentence containing [index], so a stopped
/// summary does not end mid-sentence with half of the repeated phrase.
int _sentenceStartBefore(String text, int index) {
  final end = text.substring(0, index).lastIndexOf(_sentenceEnd);
  return end == -1 ? index : end + 1;
}

final RegExp _word = RegExp(r'\S+');
final RegExp _sentenceEnd = RegExp(r'[.!?؟؛…]');
final RegExp _punctuation = RegExp(r'[^\p{L}\p{N}]', unicode: true);

String _bare(String word) => word.replaceAll(_punctuation, '').toLowerCase();
