import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';

/// Numbers, dates, percentages, versions and terms found in a text, all in
/// comparison-normalized form (ASCII digits, lowercase Latin).
class ExtractedFacts {
  const ExtractedFacts({
    this.numbers = const {},
    this.dates = const {},
    this.percentages = const {},
    this.versions = const {},
    this.terms = const {},
    this.entities = const {},
  });

  final Set<String> numbers;
  final Set<String> dates;
  final Set<String> percentages;
  final Set<String> versions;

  /// Latin-script technical terms / names.
  final Set<String> terms;

  /// Arabic named entities found by title/institution markers (heuristic).
  final Set<String> entities;
}

/// Deterministic, regex-based fact extraction. No NER model: Arabic entities
/// are only detected after known title/institution markers, so treat entity
/// results as heuristic.
class FactExtractor {
  const FactExtractor();

  static const _months =
      'يناير|فبراير|مارس|أبريل|ابريل|مايو|يونيو|يوليو|أغسطس|اغسطس|سبتمبر|أكتوبر|اكتوبر|نوفمبر|ديسمبر|'
      'كانون الثاني|شباط|آذار|نيسان|أيار|حزيران|تموز|آب|أيلول|تشرين الأول|تشرين الثاني|كانون الأول|'
      'january|february|march|april|may|june|july|august|september|october|november|december';

  static final _fullDate = RegExp(
    r'\b\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}\b|\b\d{4}[/\-]\d{1,2}[/\-]\d{1,2}\b',
  );
  static final _dayMonth = RegExp(
    r'\b\d{1,2}\s+(?:' '$_months' r')(?:\s+\d{4})?',
    caseSensitive: false,
  );
  static final _year = RegExp(r'\b(?:19|20)\d{2}\b');
  static final _percent = RegExp(
    r'\d+(?:[.,]\d+)?\s*(?:%|بالمئة|بالمائة|في المئة|في المائة|percent)',
    caseSensitive: false,
  );
  static final _version = RegExp(r'\bv?\d+(?:\.\d+){2,}\b|\bv\d+(?:\.\d+)?\b', caseSensitive: false);
  static final _number = RegExp(r'\d+(?:[.,]\d+)*');
  static final _latinTerm = RegExp(r'[A-Za-z][A-Za-z0-9_+#\-]*(?:\.[A-Za-z0-9]+)*');
  static const _personTitles = 'الدكتور|الدكتورة|الأستاذ|الاستاذ|الأستاذة|المهندس|المهندسة|الشيخ|السيد|السيدة|البروفيسور';
  static const _institutionMarkers = 'شركة|جامعة|مدينة|دولة|منظمة|وزارة|مؤسسة|مستشفى|معهد|كلية|حزب|بنك';
  static final _personEntity = RegExp(
    r'(?:' '$_personTitles' r')\s+(\p{Script=Arabic}+(?:\s+\p{Script=Arabic}+)?)',
    unicode: true,
  );
  static final _institutionEntity = RegExp(
    r'(?:' '$_institutionMarkers' r')\s+(\p{Script=Arabic}+)',
    unicode: true,
  );

  ExtractedFacts extract(String text) {
    var work = ArabicNormalizer.normalize(text);

    final dates = <String>{};
    final percentages = <String>{};
    final versions = <String>{};

    work = _take(work, _fullDate, dates);
    work = _take(work, _dayMonth, dates);
    work = _take(work, _percent, percentages, transform: (m) => m.replaceAll(RegExp(r'\s+'), ''));
    work = _take(work, _version, versions);
    work = _take(work, _year, dates);

    final numbers = <String>{
      for (final m in _number.allMatches(work)) m.group(0)!.replaceAll(',', '.'),
    };

    final terms = <String>{
      for (final m in _latinTerm.allMatches(work))
        if (m.group(0)!.length >= 2) m.group(0)!,
    };

    final entities = <String>{};
    final source = ArabicNormalizer.removeDiacritics(text);
    for (final m in _personEntity.allMatches(source)) {
      entities.add(ArabicNormalizer.normalize(m.group(0)!));
    }
    for (final m in _institutionEntity.allMatches(source)) {
      entities.add(ArabicNormalizer.normalize(m.group(0)!));
    }

    return ExtractedFacts(
      numbers: numbers,
      dates: dates,
      percentages: percentages,
      versions: versions,
      terms: terms,
      entities: entities,
    );
  }

  /// Collects matches of [pattern] into [into] and blanks them out of the
  /// working text so later (less specific) patterns don't re-count them.
  String _take(
    String work,
    RegExp pattern,
    Set<String> into, {
    String Function(String)? transform,
  }) {
    for (final m in pattern.allMatches(work)) {
      final value = m.group(0)!.trim();
      into.add(transform == null ? value : transform(value));
    }
    return work.replaceAll(pattern, ' ');
  }
}
