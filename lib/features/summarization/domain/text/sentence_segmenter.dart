import 'package:nutq/features/summarization/domain/entities/sentence.dart';

/// Splits a transcript into [Sentence]s.
///
/// Boundaries: `. ؟ ? ! ؛` followed by whitespace, plus line breaks (a blank
/// line marks a paragraph end). A period is *not* a boundary inside numbers
/// ("3.5"), after common abbreviations ("د. أحمد", "Dr."), or after a list
/// marker at the start of a line ("1. …"). `، : ,` are not sentence
/// boundaries; they are only used to break up over-long run-on "sentences"
/// (typical of punctuation-free ASR output).
class SentenceSegmenter {
  const SentenceSegmenter({this.maxWords = 80});

  /// Sentences longer than this many words are split at clause punctuation,
  /// and as a last resort at a hard word count.
  final int maxWords;

  static final _terminator = RegExp(r'[.؟?!؛]+');
  static final _paragraphBreak = RegExp(r'\n[ \t]*\n');
  static final _abbreviations = <String>{
    'د',
    'أ',
    'م',
    'dr',
    'mr',
    'mrs',
    'ms',
    'prof',
    'st',
    'vs',
    'etc',
    'e.g',
    'i.e',
    'no',
  };
  static final _clauseBreak = RegExp(r'[،,؛;:]');

  List<Sentence> segment(String transcript) {
    final sentences = <Sentence>[];
    final paragraphs = transcript.trim().split(_paragraphBreak);
    for (var p = 0; p < paragraphs.length; p++) {
      final before = sentences.length;
      for (final line in paragraphs[p].split('\n')) {
        _splitLine(line.trim(), sentences);
      }
      if (sentences.length > before) {
        final last = sentences.removeLast();
        sentences.add(
          Sentence(index: last.index, text: last.text, endsParagraph: true),
        );
      }
    }
    return sentences;
  }

  void _splitLine(String line, List<Sentence> out) {
    if (line.isEmpty) return;
    var start = 0;
    for (final match in _terminator.allMatches(line)) {
      final end = match.end;
      final atEnd = end == line.length;
      if (!atEnd && !_isSpace(line.codeUnitAt(end))) continue;
      if (_isNonBoundaryPeriod(line, start, match)) continue;
      _emit(line.substring(start, end).trim(), out);
      start = end;
    }
    if (start < line.length) _emit(line.substring(start).trim(), out);
  }

  bool _isSpace(int codeUnit) => codeUnit == 0x20 || codeUnit == 0x09 || codeUnit == 0xA0;

  bool _isNonBoundaryPeriod(String line, int sentenceStart, RegExpMatch match) {
    if (match.group(0) != '.') return false;
    final before = line.substring(sentenceStart, match.start).trimRight();
    final lastSpace = before.lastIndexOf(' ');
    final token = before.substring(lastSpace + 1);
    if (token.isEmpty) return false;
    if (_abbreviations.contains(token.toLowerCase())) return true;
    // Numbered list marker ("1. item") at the very start of the sentence.
    final isFirstToken = lastSpace < 0;
    return isFirstToken && RegExp(r'^\d{1,3}$').hasMatch(token);
  }

  void _emit(String text, List<Sentence> out) {
    if (text.isEmpty) return;
    for (final piece in _splitLong(text)) {
      out.add(Sentence(index: out.length, text: piece));
    }
  }

  List<String> _splitLong(String text) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return [text];

    final pieces = <String>[];
    var current = <String>[];
    final minPiece = maxWords ~/ 3;
    for (final word in words) {
      current.add(word);
      final endsClause = _clauseBreak.hasMatch(word[word.length - 1]);
      if ((endsClause && current.length >= minPiece) || current.length >= maxWords) {
        pieces.add(current.join(' '));
        current = <String>[];
      }
    }
    if (current.isNotEmpty) {
      if (pieces.isNotEmpty && current.length < minPiece) {
        pieces[pieces.length - 1] = '${pieces.last} ${current.join(' ')}';
      } else {
        pieces.add(current.join(' '));
      }
    }
    return pieces;
  }
}
