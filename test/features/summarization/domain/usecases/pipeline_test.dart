import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/summarization/data/cache/summarization_cache.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../support/fake_gemma.dart';

/// Small budgets so a few paragraphs produce several chunks.
const _config = SummarizationConfig(
  targetTokens: 60,
  overlapTokens: 10,
  minTokens: 30,
  maxTokens: 90,
  maxSummariesBeforeFinal: 2,
);

String _transcript(int paragraphs) => [
  for (var p = 0; p < paragraphs; p++)
    'في الفقرة رقم $p نناقش موضوعا مهما عن التعلم الآلي. بلغ عدد المشاركين 250 شخصا في عام 2024. '
        'استخدم الفريق مكتبة Flutter مع نسبة نجاح 37.5% في التجارب. وقال الدكتور أحمد محمد إن النتائج مشجعة جدا. '
        'ثم انتقلنا إلى شرح الخوارزميات وطرق التدريب والتقييم بالتفصيل الكامل.',
].join('\n\n');

void main() {
  late FakeGemma gemma;
  late SummarizationRepositoryImpl repository;
  late SummarizeTranscript pipeline;

  setUp(() {
    gemma = FakeGemma();
    repository = SummarizationRepositoryImpl(dataSource: gemma);
    pipeline = SummarizeTranscript(repository: repository);
  });

  test('integration: clean → chunk → Gemma mock → merge → validate → final', () async {
    final stages = <SummarizationStage>[];
    final result = await pipeline(
      _transcript(8),
      _config,
      onProgress: (p) => stages.add(p.stage),
    );

    expect(gemma.activated, isTrue);
    expect(result.summary, 'الملخص النهائي للمحاضرة');
    expect(result.debug.chunkCount, greaterThan(2));
    expect(result.debug.failedChunkCount, 0);
    expect(result.debug.mergeRounds, greaterThanOrEqualTo(1));
    expect(result.debug.jobId, isNotEmpty);
    expect(result.debug.processingTimeMs, greaterThanOrEqualTo(0));
    expect(result.keyPoints, ['فكرة رئيسية عن الموضوع']); // deduplicated across chunks
    expect(result.importantFacts, ['حقيقة مهمة']);

    // Two model calls per chunk, then merges, then exactly one final call.
    final chunkCalls = result.debug.chunkCount * 2;
    expect(gemma.prompts.where((p) => p.contains('final summary of a full lecture')), hasLength(1));
    expect(gemma.prompts.where((p) => p.contains('merging summaries')), isNotEmpty);
    expect(gemma.calls, greaterThan(chunkCalls + 1));

    // Progress order matches the plan's stages.
    expect(stages.first, SummarizationStage.preparing);
    expect(stages.last, SummarizationStage.completed);
    for (final s in [
      SummarizationStage.analyzing,
      SummarizationStage.summarizing,
      SummarizationStage.combining,
      SummarizationStage.finalizing,
      SummarizationStage.checking,
    ]) {
      expect(stages, contains(s));
    }
    expect(
      stages.indexOf(SummarizationStage.combining),
      lessThan(stages.indexOf(SummarizationStage.finalizing)),
    );
    expect(
      stages.indexOf(SummarizationStage.finalizing),
      lessThan(stages.indexOf(SummarizationStage.checking)),
    );
  });

  test('progress reports processed/total chunk counts', () async {
    final counts = <(int?, int?)>[];
    await pipeline(
      _transcript(6),
      _config,
      onProgress: (p) {
        if (p.stage == SummarizationStage.summarizing) {
          counts.add((p.processedChunks, p.totalChunks));
        }
      },
    );
    expect(counts, isNotEmpty);
    expect(counts.last.$1, counts.last.$2);
    expect(counts.map((c) => c.$1), orderedEquals(List.generate(counts.length, (i) => i + 1)));
  });

  test('a short transcript needs no merge round', () async {
    final result = await pipeline('جملة قصيرة عن موضوع واحد فقط.', _config);
    expect(result.debug.chunkCount, 1);
    expect(result.debug.mergeRounds, 0);
    expect(gemma.prompts.where((p) => p.contains('merging summaries')), isEmpty);
  });

  test('merging is hierarchical: no merge prompt ever holds more than two summaries', () async {
    await pipeline(_transcript(12), _config);
    final merges = gemma.prompts.where((p) => p.contains('merging summaries'));
    expect(merges, isNotEmpty);
    for (final m in merges) {
      final block = m.split('LOCAL SUMMARIES:')[1].split('IMPORTANT FACTS:')[0];
      expect(RegExp(r'^\d+\. ', multiLine: true).allMatches(block).length, lessThanOrEqualTo(2));
    }
  });

  test('merge prompts are grounded with facts and bounded source evidence', () async {
    await pipeline(_transcript(8), _config);
    final merge = gemma.prompts.firstWhere((p) => p.contains('merging summaries'));
    expect(merge, contains('- حقيقة مهمة'));
    final evidence = merge.split('SOURCE EVIDENCE:')[1];
    expect(evidence, contains('250')); // number-bearing source sentence selected
  });

  test(
    'a failing chunk is recorded (not dropped) and its text is kept as fallback evidence',
    () async {
      // Fail every model call for the first chunk's two prompts, succeed afterwards.
      gemma.responder = (prompt, call) async {
        if (call <= 2) throw const GemmaGenerationException('chunk failure');
        return null;
      };
      final result = await pipeline(_transcript(6), _config);
      expect(result.debug.failedChunkCount, 1);
      expect(result.summary, isNotEmpty);
      // The failed chunk's cleaned text still reaches a later stage.
      final downstream = gemma.prompts.skip(2).join('\n');
      expect(downstream, contains('في الفقرة رقم 0'));
    },
  );

  test('empty transcript → emptyTranscript failure, and the model is never called', () async {
    await expectLater(
      pipeline('  \n  ', _config),
      throwsA(
        isA<SummarizationFailure>().having(
          (f) => f.kind,
          'kind',
          SummarizationFailureKind.emptyTranscript,
        ),
      ),
    );
    expect(gemma.calls, 0);
  });

  test('final-summary failure surfaces as generationFailed', () async {
    gemma.responder = (prompt, call) async {
      if (prompt.contains('final summary of a full lecture')) {
        throw const GemmaGenerationException('x');
      }
      return null;
    };
    await expectLater(
      pipeline(_transcript(3), _config),
      throwsA(
        isA<SummarizationFailure>().having(
          (f) => f.kind,
          'kind',
          SummarizationFailureKind.generationFailed,
        ),
      ),
    );
  });

  test('cancellation stops scheduling new chunks and returns a cancelled outcome', () async {
    final token = CancellationToken();
    gemma.responder = (prompt, call) async {
      if (call == 3) token.cancel();
      return null;
    };
    await expectLater(
      pipeline(_transcript(8), _config, cancellation: token),
      throwsA(isA<CancelledException>()),
    );
    final callsAtCancel = gemma.calls;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(gemma.calls, callsAtCancel, reason: 'no new model calls after cancel');
    expect(callsAtCancel, lessThan(8));
  });

  test(
    'a completed result carries a validation report (numbers from source are not flagged)',
    () async {
      gemma.responder = (prompt, call) async {
        if (prompt.contains('final summary of a full lecture')) {
          return 'ناقش الدكتور أحمد محمد نتائج التجارب: شارك 250 شخصا في عام 2024 وبلغت نسبة النجاح 37.5% باستخدام Flutter.';
        }
        return null;
      };
      final result = await pipeline(_transcript(4), _config);
      final numeric = result.validation.issues.where(
        (i) =>
            i.type == ValidationIssueType.numberMismatch ||
            i.type == ValidationIssueType.dateMismatch,
      );
      expect(numeric, isEmpty);
    },
  );

  test('a hallucinated number in the final summary is flagged, not rejected', () async {
    gemma.responder = (prompt, call) async {
      if (prompt.contains('final summary of a full lecture')) {
        return 'شارك 9999 شخصا في التجارب التي ناقشها الدكتور أحمد محمد باستخدام Flutter.';
      }
      return null;
    };
    final result = await pipeline(_transcript(4), _config);
    expect(result.summary, contains('9999'));
    expect(result.validation.isSuspicious, isTrue);
    expect(
      result.validation.issues.map((i) => i.type),
      contains(ValidationIssueType.numberMismatch),
    );
  });

  test('summary length mode changes the final prompt', () async {
    await pipeline(_transcript(3), _config.copyWith(length: SummaryLength.short));
    expect(gemma.prompts.last, contains('5 to 8 short bullet points'));
  });

  test('usage stats accumulate and reset per job', () async {
    final first = await pipeline(_transcript(3), _config);
    expect(first.debug.outputTokens, greaterThan(0));
    expect(first.debug.generationTimeMs, greaterThan(0));
    final callsFirst = gemma.calls;
    final second = await pipeline(_transcript(3), _config);
    // Stats were reset: second job's token total is comparable, not doubled.
    expect(
      second.debug.outputTokens,
      closeTo(first.debug.outputTokens, first.debug.outputTokens * 0.2),
    );
    expect(gemma.calls, callsFirst * 2);
  });

  test('development cache serves repeated identical work without calling the model', () async {
    final cached = SummarizationRepositoryImpl(
      dataSource: gemma,
      cache: InMemorySummarizationCache(),
    );
    final cachedPipeline = SummarizeTranscript(repository: cached);
    await cachedPipeline(_transcript(3), _config);
    final callsAfterFirst = gemma.calls;
    final second = await cachedPipeline(_transcript(3), _config);
    expect(gemma.calls, callsAfterFirst);
    expect(second.summary, 'الملخص النهائي للمحاضرة');
  });
}
