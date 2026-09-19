import 'package:flutter/foundation.dart';

enum ValidationIssueType {
  numberMismatch,
  dateMismatch,
  entityMismatch,
  termMismatch,
  unsupportedClaim,
}

enum ValidationSeverity { medium, high }

@immutable
class ValidationIssue {
  const ValidationIssue({
    required this.type,
    required this.severity,
    required this.detail,
  });

  final ValidationIssueType type;
  final ValidationSeverity severity;

  /// The offending number/term/claim text.
  final String detail;
}

/// Heuristic support of one summary sentence by the source. Keyword/number
/// overlap only — not semantic entailment.
@immutable
class ClaimSupport {
  const ClaimSupport({required this.claim, required this.score});

  final String claim;

  /// 0.0–1.0.
  final double score;
}

@immutable
class ValidationReport {
  const ValidationReport({this.issues = const [], this.claims = const []});

  final List<ValidationIssue> issues;
  final List<ClaimSupport> claims;

  /// Any issue at all marks the summary as suspicious; the summary is never
  /// rejected automatically.
  bool get isSuspicious => issues.isNotEmpty;

  int get highSeverityCount =>
      issues.where((i) => i.severity == ValidationSeverity.high).length;
}
