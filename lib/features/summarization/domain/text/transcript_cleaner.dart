/// Removes the seams Moonshine's streaming output leaves between lines.
///
/// When a line is cut mid-phrase, the word at the cut is emitted twice: once
/// (often truncated) at the end of the line and again, complete, at the start
/// of the next:
///
///     ...في غارات باكستانية على ولاية كونار شرقي البلاد
///     البلاد.
///     ...على
///     على الرغم من أن الحكومة الأفغانية ... ح
///     حول الهجمة ...
///
/// A small model reads those doubled words as a pattern and starts repeating
/// itself, so they are dropped before the text reaches it: when a line's last
/// word equals, or is the start of, the next line's first word, the last word
/// goes and the complete one is kept.
///
/// Text without such seams (a pasted article) passes through unchanged.
String cleanTranscriptSeams(String text) {
  final lines = text.split('\n');

  for (var i = 0; i < lines.length - 1; i++) {
    final current = lines[i].trimRight();
    final next = lines[i + 1].trimLeft();
    if (current.isEmpty || next.isEmpty) continue;

    final lastSpace = current.lastIndexOf(' ');
    final lastWord = _bare(current.substring(lastSpace + 1));
    final firstWord = _bare(next.split(' ').first);
    if (lastWord.isEmpty || firstWord.isEmpty) continue;

    if (firstWord == lastWord || firstWord.startsWith(lastWord)) {
      lines[i] = lastSpace == -1 ? '' : current.substring(0, lastSpace);
    }
  }

  return lines.where((line) => line.trim().isNotEmpty).join('\n');
}

final RegExp _punctuation = RegExp(r'[^\p{L}\p{N}]', unicode: true);

String _bare(String word) => word.replaceAll(_punctuation, '');
