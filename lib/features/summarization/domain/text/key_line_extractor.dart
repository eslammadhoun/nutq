import 'dart:math' as math;

/// Picks the most informative lines of a long transcript, without a model.
///
/// This is the fast half of the summarizer: it cuts a lecture of tens of
/// thousands of words down to what fits in ONE Gemma call, so the expensive
/// MAP phase (one prefill per chunk, each slower than the last) disappears.
/// It runs in milliseconds and can only return text that is in the source,
/// so it cannot hallucinate; Gemma then turns the picked lines into prose.
///
/// How lines are chosen:
///
/// 1. The text is split into units. Moonshine emits one line per `\n`, often
///    a fragment of a sentence, so short neighbouring lines are merged until
///    a unit carries enough words to be meaningful on its own.
/// 2. Each term gets a weight: frequent across the whole text (a topic of the
///    lecture) but not in every unit (filler). Units score by the weight of
///    their distinct terms, normalised so long units don't win by length.
/// 3. The text is cut into [sectionCount] consecutive sections and each gets
///    a share of the word budget proportional to its length. This keeps every
///    part of the lecture represented — picking top units globally tends to
///    pull everything from the one topic with the most repeated vocabulary,
///    which is exactly the "summary covers only half the lecture" failure.
/// 4. Within a section, units are taken best-first, skipping any that mostly
///    repeat one already taken.
/// 5. The picked units are returned in their original order.
class KeyLineExtractor {
  const KeyLineExtractor({
    this.minUnitWords = 12,
    this.maxUnitWords = 40,
    this.sectionCount = 8,
    this.redundancyThreshold = 0.6,
  });

  /// Consecutive lines are merged until a unit reaches this many words.
  final int minUnitWords;

  /// A single line longer than this (unpunctuated ASR output can run on) is
  /// split into pieces of about this many words.
  final int maxUnitWords;

  /// How many consecutive sections the budget is spread across.
  final int sectionCount;

  /// Jaccard overlap of content terms above which a unit counts as a repeat
  /// of one already picked.
  final double redundancyThreshold;

  /// Returns the key lines of [text] in source order, totalling at most
  /// [maxWords] words, joined by newlines. Text already within budget is
  /// returned unchanged (whitespace-normalised).
  ExtractionResult extract(String text, {required int maxWords}) {
    final units = _units(text);
    final sourceWords = units.fold<int>(0, (sum, u) => sum + u.wordCount);

    if (sourceWords <= maxWords) {
      return ExtractionResult(
        text: units.map((u) => u.text).join('\n'),
        sourceWords: sourceWords,
        keptWords: sourceWords,
        sourceUnits: units.length,
        keptUnits: units.length,
      );
    }

    _score(units);

    final picked = <_Unit>[];
    final sections = _sections(units);

    // Budget left over by a section that ran out of acceptable units rolls
    // into the next, so the total stays close to [maxWords].
    var carry = 0;

    for (final section in sections) {
      final sectionWords = section.fold<int>(0, (sum, u) => sum + u.wordCount);
      var budget = (maxWords * sectionWords / sourceWords).floor() + carry;

      final ranked = [...section]..sort((a, b) => b.score.compareTo(a.score));

      for (final unit in ranked) {
        if (unit.wordCount > budget) continue;
        if (unit.terms.isEmpty) continue;
        if (picked.any((p) => _overlap(p.terms, unit.terms) > redundancyThreshold)) {
          continue;
        }

        picked.add(unit);
        budget -= unit.wordCount;
      }

      carry = budget;
    }

    picked.sort((a, b) => a.index.compareTo(b.index));

    return ExtractionResult(
      text: picked.map((u) => u.text).join('\n'),
      sourceWords: sourceWords,
      keptWords: picked.fold<int>(0, (sum, u) => sum + u.wordCount),
      sourceUnits: units.length,
      keptUnits: picked.length,
    );
  }

  /// Splits [text] into scored units, in source order, each with the few
  /// terms that best identify what it says. Used to check which parts of the
  /// source a summary has covered.
  List<SourceUnit> analyze(String text) {
    final units = _units(text);
    final weight = _score(units);

    return [
      for (final unit in units)
        SourceUnit(
          index: unit.index,
          text: unit.text,
          wordCount: unit.wordCount,
          score: unit.score,
          keyTerms: (unit.terms.where((t) => weight(t) > 0).toList()
            ..sort((a, b) => weight(b).compareTo(weight(a)))),
        ),
    ];
  }

  // ==========================================================
  // UNITS
  // ==========================================================

  static final RegExp _lineSplit = RegExp(r'\n+');
  static final RegExp _sentenceEnd = RegExp(r'(?<=[.!?؟؛…])\s+');
  static final RegExp _whitespace = RegExp(r'\s+');

  List<_Unit> _units(String text) {
    // Pieces are lines, further split at sentence ends so punctuated text
    // (pasted articles, not only ASR) is handled too.
    final pieces = <List<String>>[];

    for (final line in text.split(_lineSplit)) {
      for (final sentence in line.split(_sentenceEnd)) {
        final words = sentence.trim().split(_whitespace).where((w) => w.isNotEmpty).toList();
        if (words.isEmpty) continue;

        for (var i = 0; i < words.length; i += maxUnitWords) {
          pieces.add(words.sublist(i, math.min(i + maxUnitWords, words.length)));
        }
      }
    }

    final units = <_Unit>[];
    var buffer = <String>[];

    void flush() {
      if (buffer.isEmpty) return;
      units.add(_Unit(units.length, buffer.join(' '), buffer.length, _terms(buffer)));
      buffer = <String>[];
    }

    for (final piece in pieces) {
      if (buffer.isNotEmpty && buffer.length + piece.length > maxUnitWords) {
        flush();
      }
      buffer.addAll(piece);
      if (buffer.length >= minUnitWords) flush();
    }

    // A short tail joins the previous unit rather than standing alone.
    if (buffer.isNotEmpty && units.isNotEmpty && buffer.length < minUnitWords) {
      final last = units.removeLast();
      final words = [...last.text.split(' '), ...buffer];
      units.add(_Unit(last.index, words.join(' '), words.length, _terms(words)));
    } else {
      flush();
    }

    return units;
  }

  List<List<_Unit>> _sections(List<_Unit> units) {
    final count = math.max(1, math.min(sectionCount, units.length));
    final size = (units.length / count).ceil();

    return [
      for (var i = 0; i < units.length; i += size)
        units.sublist(i, math.min(i + size, units.length)),
    ];
  }

  // ==========================================================
  // SCORING
  // ==========================================================

  /// Scores [units] in place and returns the weight used to pick each unit's
  /// key terms: what makes a unit *distinct*, not what the whole text is
  /// about. A word found across the text (`افغانيه` in a story about
  /// Afghanistan) is in every summary, so it would mark every unit covered;
  /// words in few units (`هنديه`, `مخابق`, `مغلقه`) say whether this unit's
  /// point made it in. A term said once still counts: a place name
  /// mentioned once is often exactly the fact a summary must keep.
  double Function(String term) _score(List<_Unit> units) {
    final termFrequency = <String, int>{};
    final unitFrequency = <String, int>{};

    for (final unit in units) {
      for (final term in unit.termCounts.keys) {
        termFrequency[term] = (termFrequency[term] ?? 0) + unit.termCounts[term]!;
        unitFrequency[term] = (unitFrequency[term] ?? 0) + 1;
      }
    }

    final n = units.length;

    double weight(String term) {
      final tf = termFrequency[term]!;
      // A term said once is as likely to be a mis-recognised word as a topic.
      if (tf < 2) return 0;
      final idf = math.log((n + 1) / (unitFrequency[term]! + 1)) + 1;
      return math.log(1 + tf) * idf;
    }

    for (final unit in units) {
      if (unit.terms.isEmpty) continue;

      var score = 0.0;
      for (final term in unit.terms) {
        score += weight(term);
      }
      score /= math.sqrt(unit.terms.length);

      // Numbers, dates and percentages are what the prompts insist on
      // keeping; a unit that states one is worth a little more.
      if (_digits.hasMatch(unit.text)) score *= 1.15;

      unit.score = score;
    }

    return (term) {
      final df = unitFrequency[term] ?? 0;
      if (df == 0) return 0;
      if (n >= 8 && df / n > _topicWideShare) return 0;
      final idf = math.log((n + 1) / (df + 1)) + 1;
      // Rarity first; frequency only breaks ties between equally rare terms.
      return idf + 0.1 * math.log(termFrequency[term]!);
    };
  }

  static final RegExp _digits = RegExp(r'[0-9٠-٩]');

  /// A term in more than this share of units is about the whole text, not
  /// any one part of it, and is not used as a key term.
  static const double _topicWideShare = 0.25;

  static double _overlap(Set<String> a, Set<String> b) {
    final smaller = a.length <= b.length ? a : b;
    final larger = identical(smaller, a) ? b : a;
    if (smaller.isEmpty) return 0;
    final shared = smaller.where(larger.contains).length;
    return shared / (a.length + b.length - shared);
  }

  // ==========================================================
  // NORMALISATION
  // ==========================================================

  static final RegExp _diacritics = RegExp(r'[ؐ-ًؚ-ٰٟۖ-ۭـ]');
  static final RegExp _nonWord = RegExp(r'[^\p{L}\p{N}]', unicode: true);

  /// Normalised content terms of [text], as used for scoring.
  static Set<String> termsOf(String text) => _terms(text.split(_whitespace)).keys.toSet();

  /// Content terms of [words]: normalised, stop words and very short tokens
  /// removed, with per-unit counts.
  static Map<String, int> _terms(List<String> words) {
    final counts = <String, int>{};

    for (final word in words) {
      final folded = fold(word);
      // Checked before and after stripping: `الذين` would otherwise become
      // `ذين` and slip past the list.
      if (_stopWords.contains(folded)) continue;
      final term = stem(folded);
      if (term.length < 3 || _stopWords.contains(term)) continue;
      counts[term] = (counts[term] ?? 0) + 1;
    }

    return counts;
  }

  /// Folds spelling variants that ASR output and Arabic orthography produce
  /// for the same word, so they count as one term.
  static String normalize(String word) => stem(fold(word));

  static String fold(String word) => word
      .toLowerCase()
      .replaceAll(_diacritics, '')
      .replaceAll(_nonWord, '')
      .replaceAll(_alef, 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي');

  static final RegExp _alef = RegExp('[أإآٱ]');

  static String stem(String folded) {
    var w = folded;

    // Light prefix stripping: the definite article and the conjunctions and
    // prepositions that attach to it. Only when a real stem remains.
    for (final prefix in const ['وال', 'بال', 'كال', 'فال', 'لل', 'ال']) {
      if (w.startsWith(prefix) && w.length - prefix.length >= 3) {
        w = w.substring(prefix.length);
        break;
      }
    }

    return w;
  }

  /// Function words and spoken fillers, in [fold]ed form.
  static final Set<String> _stopWords = {
    // Arabic
    'في', 'من', 'علي', 'الي', 'عن', 'مع', 'هذا', 'هذه', 'ذلك', 'تلك', 'هناك',
    'هنا', 'التي', 'الذي', 'الذين', 'اللي', 'كان', 'كانت', 'يكون', 'تكون',
    'لكن', 'ولكن', 'او', 'ثم', 'حتي', 'اذا', 'ان', 'انه', 'انها', 'لان', 'كما',
    'كل', 'بعض', 'غير', 'بين', 'عند', 'عندما', 'قد', 'لقد', 'لم', 'لن', 'لا',
    'ما', 'ماذا', 'هل', 'هو', 'هي', 'هم', 'نحن', 'انا', 'انت', 'انتم', 'احنا',
    'يعني', 'طيب', 'كده', 'كدا', 'يا', 'ايه', 'اه', 'ايوه', 'برضو', 'بس',
    'خلاص', 'تمام', 'شي', 'شيء', 'مثلا', 'عشان', 'علشان', 'لما', 'فيه',
    'فيها', 'منه', 'منها', 'عليه', 'عليها', 'اليه', 'بعد', 'قبل', 'ايضا',
    'جدا', 'كثير', 'حاجه', 'دي', 'ده', 'دا', 'هاي', 'هذي', 'وين',
    'كيف', 'ليش', 'ليه', 'زي', 'مش', 'مو', 'راح', 'رح', 'يلا', 'والله',
    'وهذا', 'وهو', 'وهي', 'ولا', 'فيما', 'بها', 'به', 'لها', 'له', 'لهم',
    'الان', 'اول', 'نفس', 'سوف', 'وقد', 'فقط', 'مثل', 'حيث',
    'بان', 'بانه', 'بانها', 'طبعا', 'بالطبع', 'وبالطبع', 'دوما', 'ودوما',
    'وهناك', 'تقريبا', 'حقيقه', 'بالفعل', 'امر', 'الامر', 'وايضا', 'قال',
    'وقال', 'قالت', 'معك', 'اذن', 'حسب', 'بحسب',
    // English
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'any', 'can',
    'had', 'her', 'was', 'one', 'our', 'out', 'has', 'have', 'this', 'that',
    'with', 'they', 'from', 'what', 'which', 'their', 'there', 'then', 'them',
    'these', 'those', 'will', 'would', 'could', 'should', 'about', 'into',
    'just', 'like', 'your', 'some', 'more', 'also', 'very', 'been', 'were',
    'when', 'where', 'who', 'how', 'why', 'its', 'it', 'is', 'so', 'okay',
    'yeah', 'actually', 'really', 'going', 'gonna', 'know', 'mean', 'right',
    'thing', 'things', 'kind', 'sort', 'well', 'here', 'now', 'than', 'too',
    'did', 'does', 'doing', 'get', 'got', 'because', 'other', 'being',
  };
}

class SourceUnit {
  const SourceUnit({
    required this.index,
    required this.text,
    required this.wordCount,
    required this.score,
    required this.keyTerms,
  });

  final int index;
  final String text;
  final int wordCount;
  final double score;

  /// This unit's content terms ([KeyLineExtractor.normalize]d) minus the
  /// ones found all over the text, most distinctive first.
  final List<String> keyTerms;
}

class ExtractionResult {
  const ExtractionResult({
    required this.text,
    required this.sourceWords,
    required this.keptWords,
    required this.sourceUnits,
    required this.keptUnits,
  });

  final String text;
  final int sourceWords;
  final int keptWords;
  final int sourceUnits;
  final int keptUnits;

  bool get wasReduced => keptWords < sourceWords;
}

class _Unit {
  _Unit(this.index, this.text, this.wordCount, this.termCounts) : terms = termCounts.keys.toSet();

  final int index;
  final String text;
  final int wordCount;
  final Map<String, int> termCounts;
  final Set<String> terms;
  double score = 0;
}
