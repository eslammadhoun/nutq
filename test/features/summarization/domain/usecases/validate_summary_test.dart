import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';
import 'package:nutq/features/summarization/domain/usecases/validate_summary.dart';

const _source = '''
افتتح الدكتور أحمد محمد المؤتمر في جامعة القاهرة في 15/03/2024. حضر المؤتمر 250 شخصا من مختلف الدول.
وقال الدكتور أحمد محمد إن نسبة النمو بلغت 37.5% هذا العام. واستخدم الفريق مكتبة Flutter لبناء التطبيق.
كما ناقش المؤتمر مستقبل التعليم الرقمي وأثره على الطلاب في المدارس والجامعات.
''';

ValidationReport _validate(String summary, {ValidateSummary validator = const ValidateSummary()}) =>
    validator(sourceSentences: const SentenceSegmenter().segment(_source), summary: summary);

Iterable<ValidationIssueType> _types(ValidationReport r) => r.issues.map((i) => i.type);

void main() {
  test('a faithful summary is not suspicious', () {
    final report = _validate(
      'افتتح الدكتور أحمد محمد المؤتمر في جامعة القاهرة وحضره 250 شخصا. '
      'وبلغت نسبة النمو 37.5% واستخدم الفريق Flutter.',
    );
    expect(report.isSuspicious, isFalse, reason: report.issues.map((i) => '${i.type}:${i.detail}').join(', '));
  });

  test('flags a number absent from the source as high-severity NUMBER_MISMATCH', () {
    final report = _validate('حضر المؤتمر 900 شخص من مختلف الدول وناقش مستقبل التعليم الرقمي.');
    final issue = report.issues.firstWhere((i) => i.type == ValidationIssueType.numberMismatch);
    expect(issue.detail, '900');
    expect(issue.severity, ValidationSeverity.high);
    expect(report.isSuspicious, isTrue);
  });

  test('flags a percentage whose value is not in the source', () {
    final report = _validate('بلغت نسبة النمو 80% هذا العام بحسب الدكتور أحمد محمد في المؤتمر.');
    expect(_types(report), contains(ValidationIssueType.numberMismatch));
  });

  test('treats Arabic-Indic digits in the summary as the same number', () {
    final report = _validate('حضر المؤتمر ٢٥٠ شخصا من مختلف الدول وناقش مستقبل التعليم الرقمي.');
    expect(_types(report), isNot(contains(ValidationIssueType.numberMismatch)));
  });

  test('flags a date absent from the source as high-severity DATE_MISMATCH', () {
    final report = _validate('افتتح الدكتور أحمد محمد المؤتمر في جامعة القاهرة عام 2019 وحضره 250 شخصا.');
    final issue = report.issues.firstWhere((i) => i.type == ValidationIssueType.dateMismatch);
    expect(issue.severity, ValidationSeverity.high);
  });

  test('flags a Latin term absent from the source as TERM_MISMATCH', () {
    final report = _validate('استخدم الفريق مكتبة React لبناء التطبيق في مؤتمر جامعة القاهرة.');
    expect(_types(report), contains(ValidationIssueType.termMismatch));
    expect(report.issues.firstWhere((i) => i.type == ValidationIssueType.termMismatch).detail, 'react');
  });

  test('flags a frequently mentioned source entity missing from the summary', () {
    final report = _validate('ناقش المؤتمر مستقبل التعليم الرقمي وأثره على الطلاب في المدارس والجامعات.');
    final issue = report.issues.firstWhere((i) => i.type == ValidationIssueType.entityMismatch);
    expect(issue.detail, 'الدكتور احمد محمد');
    expect(issue.severity, ValidationSeverity.medium);
  });

  test('flags an unsupported claim with a low support score', () {
    final report = _validate('أعلنت الحكومة عن خطة جديدة لبناء مستشفيات حديثة في الصحراء الكبرى.');
    final claim = report.issues.firstWhere((i) => i.type == ValidationIssueType.unsupportedClaim);
    expect(claim.severity, ValidationSeverity.high);
    expect(report.claims.single.score, lessThan(0.15));
  });

  test('a supported claim scores high and is not flagged', () {
    final report = _validate('ناقش المؤتمر مستقبل التعليم الرقمي وأثره على الطلاب في المدارس والجامعات.');
    expect(report.claims.single.score, greaterThan(0.8));
    expect(_types(report), isNot(contains(ValidationIssueType.unsupportedClaim)));
  });

  test('thresholds are configurable', () {
    const strict = ValidateSummary(
      thresholds: ValidationThresholds(claimSupportMin: 0.99, claimSupportHighBelow: 0.0),
    );
    const summary = 'ناقش المؤتمر مستقبل التعليم الرقمي وأثره على الطلاب والمعلمين والمناهج الحديثة.';
    expect(_types(_validate(summary)), isNot(contains(ValidationIssueType.unsupportedClaim)));
    expect(_types(_validate(summary, validator: strict)), contains(ValidationIssueType.unsupportedClaim));
  });

  test('bullet markers are stripped before claim scoring and short claims are skipped', () {
    final report = _validate('- ناقش المؤتمر مستقبل التعليم الرقمي وأثره على الطلاب.\n- نعم');
    expect(report.claims, hasLength(1));
    expect(report.claims.single.claim.startsWith('-'), isFalse);
  });

  test('never throws on an empty summary', () {
    expect(() => _validate(''), returnsNormally);
    expect(_validate('').claims, isEmpty);
  });
}
