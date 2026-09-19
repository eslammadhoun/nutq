import 'dart:convert';
import 'dart:io';

import 'package:nutq/features/summarization/benchmark/baseline_summarizer.dart';
import 'package:nutq/features/summarization/benchmark/benchmark_fixture.dart';
import 'package:nutq/features/summarization/benchmark/heuristic_evaluator.dart';
import 'package:nutq/features/summarization/benchmark/summary_evaluation.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

/// One named experiment: a pipeline configuration plus generation settings.
class BenchmarkConfiguration {
  const BenchmarkConfiguration({
    required this.name,
    this.pipeline = const SummarizationConfig(),
    this.generation = const GemmaGenerationConfig(),
    this.baseline = false,
  });

  final String name;
  final SummarizationConfig pipeline;
  final GemmaGenerationConfig generation;

  /// Run the plain fixed-window baseline instead of the full pipeline.
  final bool baseline;

  /// Plan §31 sweeps. Sweep each axis on its own around the default rather
  /// than running the full cross product.
  static List<BenchmarkConfiguration> chunkSizeSweep({
    List<int> sizes = const [300, 400, 500, 600, 800],
  }) => [
    for (final size in sizes)
      BenchmarkConfiguration(
        name: 'chunk_$size',
        pipeline: SummarizationConfig(
          targetTokens: size,
          minTokens: (size * 0.6).round(),
          maxTokens: (size * 1.5).round(),
        ),
      ),
  ];

  static List<BenchmarkConfiguration> overlapSweep({List<int> overlaps = const [0, 25, 50, 75]}) => [
    for (final o in overlaps) BenchmarkConfiguration(name: 'overlap_$o', pipeline: SummarizationConfig(overlapTokens: o)),
  ];

  static List<BenchmarkConfiguration> temperatureSweep({List<double> temps = const [0.1, 0.2, 0.3]}) => [
    for (final t in temps) BenchmarkConfiguration(name: 'temp_$t', generation: GemmaGenerationConfig(temperature: t)),
  ];
}

class BenchmarkRuntime {
  const BenchmarkRuntime({required this.processingTimeMs, required this.tokensPerSecond});

  final int processingTimeMs;
  final double tokensPerSecond;
}

class SummarizationBenchmarkResult {
  const SummarizationBenchmarkResult({
    required this.configuration,
    required this.lecture,
    required this.metrics,
    required this.runtime,
    this.errors = const [],
    this.failedChunkCount = 0,
    this.suspicious = false,
  });

  final String configuration;
  final String lecture;
  final SummaryEvaluation metrics;
  final BenchmarkRuntime runtime;
  final List<String> errors;
  final int failedChunkCount;
  final bool suspicious;

  /// The record shape from plan §30, plus token/chunk/error extras.
  Map<String, dynamic> toJson() => {
    'configuration': configuration,
    'lecture': lecture,
    'coverage': metrics.coverage,
    'faithfulness': metrics.faithfulness,
    'factuality': metrics.factuality,
    'coherence': metrics.coherence,
    'conciseness': metrics.conciseness,
    'redundancy': metrics.redundancy,
    'arabic_quality': metrics.arabicQuality,
    'processing_time_ms': runtime.processingTimeMs,
    'tokens_per_second': runtime.tokensPerSecond,
    'input_tokens': metrics.inputTokens,
    'output_tokens': metrics.outputTokens,
    'chunk_count': metrics.chunkCount,
    'failed_chunk_count': failedChunkCount,
    'validation_suspicious': suspicious,
    'errors': errors,
  };
}

typedef BenchmarkRun = Future<SummaryResult> Function(BenchmarkFixture fixture, BenchmarkConfiguration configuration);

/// Runs every configuration against every fixture and scores the output.
class SummarizationBenchmarkRunner {
  const SummarizationBenchmarkRunner({
    required this.run,
    this.evaluator = const HeuristicSummaryEvaluator(),
  });

  final BenchmarkRun run;
  final HeuristicSummaryEvaluator evaluator;

  /// A run on top of a single shared model (loading it once), with a fresh
  /// repository per configuration so generation settings apply.
  factory SummarizationBenchmarkRunner.forDataSource(
    GemmaLocalDataSource dataSource, {
    HeuristicSummaryEvaluator evaluator = const HeuristicSummaryEvaluator(),
  }) => SummarizationBenchmarkRunner(
    evaluator: evaluator,
    run: (fixture, configuration) {
      final repository = SummarizationRepositoryImpl(dataSource: dataSource, baseConfig: configuration.generation);
      if (configuration.baseline) {
        return BaselineSummarizer(repository)(fixture.transcript, configuration.pipeline);
      }
      return SummarizeTranscript(repository: repository)(fixture.transcript, configuration.pipeline);
    },
  );

  Future<List<SummarizationBenchmarkResult>> runAll(
    List<BenchmarkFixture> fixtures,
    List<BenchmarkConfiguration> configurations,
  ) async {
    final results = <SummarizationBenchmarkResult>[];
    for (final configuration in configurations) {
      for (final fixture in fixtures) {
        results.add(await _runOne(fixture, configuration));
      }
    }
    return results;
  }

  Future<SummarizationBenchmarkResult> _runOne(BenchmarkFixture fixture, BenchmarkConfiguration configuration) async {
    final watch = Stopwatch()..start();
    try {
      final result = await run(fixture, configuration);
      final metrics = evaluator.evaluate(fixture, result);
      return SummarizationBenchmarkResult(
        configuration: configuration.name,
        lecture: fixture.id,
        metrics: metrics,
        runtime: BenchmarkRuntime(
          processingTimeMs: metrics.processingTimeMs,
          tokensPerSecond: metrics.tokensPerSecond,
        ),
        failedChunkCount: result.debug.failedChunkCount,
        suspicious: result.validation.isSuspicious,
      );
    } catch (e) {
      return SummarizationBenchmarkResult(
        configuration: configuration.name,
        lecture: fixture.id,
        metrics: SummaryEvaluation(processingTimeMs: watch.elapsedMilliseconds),
        runtime: BenchmarkRuntime(processingTimeMs: watch.elapsedMilliseconds, tokensPerSecond: 0),
        errors: ['$e'],
      );
    }
  }

  static String encode(List<SummarizationBenchmarkResult> results) =>
      const JsonEncoder.withIndent('  ').convert([for (final r in results) r.toJson()]);

  static Future<void> writeJson(List<SummarizationBenchmarkResult> results, File file) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(encode(results));
  }
}
