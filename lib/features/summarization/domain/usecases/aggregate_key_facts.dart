import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';
import 'package:nutq/features/summarization/domain/text/fact_extractor.dart';

class KeyFacts {
  const KeyFacts({
    this.mainIdeas = const [],
    this.facts = const [],
    this.importantTerms = const [],
    this.numbers = const [],
    this.entities = const [],
  });

  final List<String> mainIdeas;
  final List<String> facts;
  final List<String> importantTerms;
  final List<String> numbers;
  final List<String> entities;
}

/// Merges per-chunk analyses into global key facts.
///
/// Deduplicates only exact duplicates after light normalization (no fuzzy
/// matching) and keeps the original wording of the first occurrence.
class AggregateKeyFacts {
  const AggregateKeyFacts([this._extractor = const FactExtractor()]);

  final FactExtractor _extractor;

  KeyFacts call(List<ChunkAnalysis> analyses) {
    final mains = _Dedup();
    final facts = _Dedup();
    final terms = _Dedup();
    final numbers = <String>{};
    final entities = <String>{};

    for (final a in analyses) {
      if (a.main.isNotEmpty) mains.add(a.main);
      for (final f in a.facts) {
        facts.add(f);
        final extracted = _extractor.extract(f);
        numbers
          ..addAll(extracted.numbers)
          ..addAll(extracted.percentages)
          ..addAll(extracted.dates);
        entities.addAll(extracted.entities);
      }
      for (final t in a.importantTerms) {
        terms.add(t);
      }
    }
    return KeyFacts(
      mainIdeas: mains.values,
      facts: facts.values,
      importantTerms: terms.values,
      numbers: numbers.toList(),
      entities: entities.toList(),
    );
  }
}

class _Dedup {
  final Set<String> _seen = {};
  final List<String> values = [];

  void add(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (_seen.add(ArabicNormalizer.normalize(trimmed))) values.add(trimmed);
  }
}
