import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';

import '../../features/summarization/support/fake_gemma.dart';
import '../../support/benchmark/benchmark_fixture.dart';
import '../../support/benchmark/benchmark_runner.dart';
import '../../support/benchmark/heuristic_evaluator.dart';
import '../../support/benchmark/summary_evaluation.dart';

BenchmarkFixture _fixture() => BenchmarkFixture.fromJson({
  'id': 'f1',
  'title': 't',
  'language': 'ar',
  'duration_minutes': 1,
  'transcript':
      'بلغت الإيرادات 320000 دولار في الربع الثالث وقال خالد إن الفريق سيوظف مبرمجين اثنين. ' * 6,
  'reference_summary': 'ملخص',
  'important_facts': ['بلغت الإيرادات 320000 دولار', 'سيوظف الفريق مبرمجين اثنين'],
  'important_entities': ['خالد'],
  'important_numbers': ['320000'],
});

SummaryResult _result(String summary) => SummaryResult(
  summary: summary,
  validation: const ValidationReport(),
  debug: const SummaryDebugInfo(
    jobId: 'j',
    chunkCount: 2,
    failedChunkCount: 0,
    processingTimeMs: 100,
    outputTokens: 50,
    generationTimeMs: 1000,
  ),
);

void main() {
  group('SummaryEvaluation', () {
    test('accepts scores in 0–5 and averages measured ones', () {
      final e = SummaryEvaluation(coverage: 4, faithfulness: 5, coherence: null);
      expect(e.overall, 4.5);
      expect(SummaryEvaluation().overall, isNull);
    });

    test('rejects scores outside 0–5', () {
      expect(() => SummaryEvaluation(coverage: 6), throwsA(isA<AssertionError>()));
    });
  });

  group('HeuristicSummaryEvaluator', () {
    const evaluator = HeuristicSummaryEvaluator();

    test('a summary with the facts, entity and number scores high coverage', () {
      final good = evaluator.evaluate(
        _fixture(),
        _result('بلغت الإيرادات 320000 دولار وقال خالد إن الفريق سيوظف مبرمجين اثنين.'),
      );
      final bad = evaluator.evaluate(_fixture(), _result('تحدث الاجتماع عن أمور عامة.'));
      expect(good.coverage, greaterThan(4.5));
      expect(bad.coverage, lessThan(1));
    });

    test('repetition lowers the redundancy score', () {
      final repeated = evaluator.evaluate(_fixture(), _result('الفريق سيوظف مبرمجين ' * 8));
      final varied = evaluator.evaluate(
        _fixture(),
        _result('الفريق سيوظف مبرمجين اثنين بعد أن تجاوزت الإيرادات الهدف المحدد للربع.'),
      );
      expect(repeated.redundancy!, lessThan(varied.redundancy!));
    });

    test('a very long summary scores lower on conciseness', () {
      final long = evaluator.evaluate(_fixture(), _result(_fixture().transcript));
      final short = evaluator.evaluate(
        _fixture(),
        _result('ملخص قصير عن الإيرادات والتوظيف في الربع.'),
      );
      expect(long.conciseness!, lessThan(short.conciseness!));
    });

    test('non-Arabic output and leaked template text lower arabicQuality', () {
      final english = evaluator.evaluate(
        _fixture(),
        _result('The team will hire two engineers next quarter.'),
      );
      final leaked = evaluator.evaluate(
        _fixture(),
        _result('MAIN: فريق سيوظف مبرمجين اثنين في الربع القادم'),
      );
      final clean = evaluator.evaluate(
        _fixture(),
        _result('سيوظف الفريق مبرمجين اثنين في الربع القادم'),
      );
      expect(english.arabicQuality, lessThan(1));
      expect(leaked.arabicQuality!, lessThan(clean.arabicQuality!));
    });

    test('validation issues lower factuality; coherence is left for humans', () {
      const suspicious = ValidationReport(
        issues: [
          ValidationIssue(
            type: ValidationIssueType.numberMismatch,
            severity: ValidationSeverity.high,
            detail: '9',
          ),
        ],
        claims: [ClaimSupport(claim: 'c', score: 0.2)],
      );
      final e = evaluator.evaluate(
        _fixture(),
        SummaryResult(summary: 'ملخص', validation: suspicious, debug: _result('x').debug),
      );
      expect(e.factuality, 3.5);
      expect(e.faithfulness, closeTo(1.0, 1e-9));
      expect(e.coherence, isNull);
    });

    test('runtime figures pass through from the debug info', () {
      final e = evaluator.evaluate(_fixture(), _result('ملخص'));
      expect(e.processingTimeMs, 100);
      expect(e.tokensPerSecond, 50);
      expect(e.chunkCount, 2);
    });
  });

  group('SummarizationBenchmarkRunner', () {
    test('runs every configuration × fixture and emits plan-shaped JSON', () async {
      final gemma = FakeGemma();
      final runner = SummarizationBenchmarkRunner.forDataSource(gemma);
      final results = await runner.runAll(
        [_fixture()],
        const [
          BenchmarkConfiguration(name: 'A'),
          BenchmarkConfiguration(name: 'B_baseline', baseline: true),
        ],
      );

      expect(results.map((r) => r.configuration), ['A', 'B_baseline']);
      expect(results.every((r) => r.lecture == 'f1'), isTrue);

      final decoded = jsonDecode(SummarizationBenchmarkRunner.encode(results)) as List<dynamic>;
      final record = decoded.first as Map<String, dynamic>;
      for (final key in [
        'configuration',
        'lecture',
        'coverage',
        'faithfulness',
        'factuality',
        'coherence',
        'conciseness',
        'arabic_quality',
        'processing_time_ms',
        'tokens_per_second',
      ]) {
        expect(record.containsKey(key), isTrue, reason: key);
      }
    });

    test('a failing run is recorded as an error, not thrown', () async {
      final gemma = FakeGemma()..failEverything = true;
      final runner = SummarizationBenchmarkRunner.forDataSource(gemma);
      final results = await runner.runAll([_fixture()], const [BenchmarkConfiguration(name: 'A')]);
      expect(results.single.errors, isNotEmpty);
      expect(results.single.metrics.coverage, isNull);
    });

    test('writes benchmark_results.json', () async {
      final dir = await Directory.systemTemp.createTemp('nutq_bench');
      addTearDown(() => dir.delete(recursive: true));
      final runner = SummarizationBenchmarkRunner.forDataSource(FakeGemma());
      final results = await runner.runAll([_fixture()], const [BenchmarkConfiguration(name: 'A')]);
      final file = File('${dir.path}/out/benchmark_results.json');
      await SummarizationBenchmarkRunner.writeJson(results, file);
      expect(jsonDecode(await file.readAsString()), hasLength(1));
    });

    test('sweeps generate the plan §31 configurations', () {
      expect(BenchmarkConfiguration.chunkSizeSweep().map((c) => c.pipeline.targetTokens), [
        300,
        400,
        500,
        600,
        800,
      ]);
      expect(BenchmarkConfiguration.overlapSweep().map((c) => c.pipeline.overlapTokens), [
        0,
        25,
        50,
        75,
      ]);
      expect(BenchmarkConfiguration.temperatureSweep().map((c) => c.generation.temperature), [
        0.1,
        0.2,
        0.3,
      ]);
      for (final c in BenchmarkConfiguration.chunkSizeSweep()) {
        expect(c.pipeline.minTokens, lessThan(c.pipeline.targetTokens));
        expect(c.pipeline.maxTokens, greaterThan(c.pipeline.targetTokens));
      }
    });
  });
}
