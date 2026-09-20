import 'package:nutq/features/summarization/domain/entities/sentence.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';
import 'package:nutq/features/summarization/domain/text/fact_extractor.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';

class ValidationThresholds {
  const ValidationThresholds({
    this.claimSupportMin = 0.35,
    this.claimSupportHighBelow = 0.15,
    this.minEntityFrequency = 2,
    this.minClaimTokens = 3,
  });

  /// Claims scoring below this are flagged (medium).
  final double claimSupportMin;

  /// Claims scoring below this are flagged high.
  final double claimSupportHighBelow;

  /// A source entity counts as "important" when it occurs at least this often.
  final int minEntityFrequency;
  final int minClaimTokens;
}

/// Lightweight deterministic factuality checks. Flags, never rejects.
///
/// - numbers / percentages / dates in the summary that do not occur in the
///   source → high severity
/// - Latin terms in the summary absent from the source → medium
/// - frequent source entities missing from the summary → medium
/// - summary sentences with low keyword overlap against the source →
///   medium/high ("heuristic support": token overlap, not entailment)
class ValidateSummary {
  const ValidateSummary({
    this.thresholds = const ValidationThresholds(),
    this._extractor = const FactExtractor(),
  });

  final ValidationThresholds thresholds;
  final FactExtractor _extractor;

  static final _numericToken = RegExp(r'\d+(?:\.\d+)?');
  static final _bullet = RegExp(r'^\s*(?:[-•*–]|\d+[.)])\s*');

  ValidationReport call({
    required List<Sentence> sourceSentences,
    required String summary,
  }) {
    final source = sourceSentences.map((s) => s.text).join(' ');
    final sourceFacts = _extractor.extract(source);
    final summaryFacts = _extractor.extract(summary);
    final sourceNormalized = ArabicNormalizer.normalize(source);
    final sourceNumbers = {
      for (final m in _numericToken.allMatches(sourceNormalized)) m.group(0)!,
    };

    final issues = <ValidationIssue>[];

    for (final n in {
      ...summaryFacts.numbers,
      ...summaryFacts.percentages.expand(_digitsOf),
    }) {
      if (!sourceNumbers.contains(n)) {
        issues.add(_issue(ValidationIssueType.numberMismatch, ValidationSeverity.high, n));
      }
    }

    for (final d in summaryFacts.dates) {
      if (!sourceFacts.dates.contains(d) && !sourceNormalized.contains(d)) {
        issues.add(_issue(ValidationIssueType.dateMismatch, ValidationSeverity.high, d));
      }
    }

    for (final t in summaryFacts.terms) {
      if (!sourceFacts.terms.contains(t)) {
        issues.add(_issue(ValidationIssueType.termMismatch, ValidationSeverity.medium, t));
      }
    }

    final summaryNormalized = ArabicNormalizer.normalize(summary);
    for (final e in sourceFacts.entities) {
      final frequency = e.allMatches(sourceNormalized).length;
      if (frequency >= thresholds.minEntityFrequency && !summaryNormalized.contains(e)) {
        issues.add(_issue(ValidationIssueType.entityMismatch, ValidationSeverity.medium, e));
      }
    }

    final claims = _claimSupport(sourceSentences, summary);
    for (final c in claims) {
      if (c.score < thresholds.claimSupportHighBelow) {
        issues.add(_issue(ValidationIssueType.unsupportedClaim, ValidationSeverity.high, c.claim));
      } else if (c.score < thresholds.claimSupportMin) {
        issues.add(
          _issue(ValidationIssueType.unsupportedClaim, ValidationSeverity.medium, c.claim),
        );
      }
    }

    return ValidationReport(issues: issues, claims: claims);
  }

  Iterable<String> _digitsOf(String percentage) =>
      _numericToken.allMatches(percentage).map((m) => m.group(0)!);

  ValidationIssue _issue(
    ValidationIssueType type,
    ValidationSeverity severity,
    String detail,
  ) => ValidationIssue(type: type, severity: severity, detail: detail);

  List<ClaimSupport> _claimSupport(List<Sentence> source, String summary) {
    final sourceTokens = [
      for (final s in source) ArabicNormalizer.contentTokens(s.text).toSet(),
    ];
    final claims = const SentenceSegmenter(maxWords: 60).segment(summary);
    final out = <ClaimSupport>[];
    for (final claim in claims) {
      final text = claim.text.replaceFirst(_bullet, '').trim();
      final tokens = ArabicNormalizer.contentTokens(text).toSet();
      if (tokens.length < thresholds.minClaimTokens) continue;
      out.add(ClaimSupport(claim: text, score: _bestOverlap(tokens, sourceTokens)));
    }
    return out;
  }

  /// Best overlap ratio over windows of 1–3 consecutive source sentences (a
  /// claim can draw on neighbouring sentences).
  double _bestOverlap(Set<String> claim, List<Set<String>> source) {
    var best = 0.0;
    for (var i = 0; i < source.length; i++) {
      final window = <String>{};
      for (var w = 0; w < 3 && i + w < source.length; w++) {
        window.addAll(source[i + w]);
        final hits = claim.where(window.contains).length;
        final ratio = hits / claim.length;
        if (ratio > best) best = ratio;
      }
    }
    return best;
  }
}
