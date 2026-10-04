import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../../../support/sample_text.dart';
import '../../support/fake_gemma.dart';

const _config = SummarizationConfig(wordsPerCall: 8, debugLogging: false);

void main() {
  late FakeGemma gemma;
  late SummarizeTranscript summarize;

  setUp(() {
    gemma = FakeGemma();
    summarize = SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma));
  });

  /// The source text of a section prompt, between "النص:" and the closing
  /// instruction.
  String sourceOf(String prompt) => prompt.split('النص:\n').last.split('\n\nاكتب').first.trim();

  test('summarizes section by section, in source order, one paragraph each', () async {
    gemma.responder = (prompt, call) async => 'النقطة رقم $call من المحاضرة.';
    final result = await summarize(arabicTranscript(6), _config);

    expect(gemma.calls, greaterThan(1));
    expect(result.debug.sectionCount, gemma.calls);
    expect(
      result.summary,
      [for (var i = 1; i <= gemma.calls; i++) 'النقطة رقم $i من المحاضرة.'].join('\n\n'),
    );
    expect(result.needsReview, isFalse);
    expect(result.keyPoints, isEmpty);

    // Every part of the source reached the model exactly once, in order.
    final sent = gemma.prompts.map(sourceOf).join(' ');
    for (var i = 0; i < 6; i++) {
      expect(sent, contains('في الفقرة رقم $i '));
    }
    expect(sent.indexOf('رقم 0 '), lessThan(sent.indexOf('رقم 5 ')));
  });

  test('a longer summary length means smaller sections and more calls', () async {
    Future<int> callsFor(SummaryLength length) async {
      final g = FakeGemma();
      await SummarizeTranscript(
        repository: SummarizationRepositoryImpl(dataSource: g),
      )(arabicTranscript(12), _config.copyWith(length: length));
      return g.calls;
    }

    final short = await callsFor(SummaryLength.short);
    final detailed = await callsFor(SummaryLength.detailed);
    expect(detailed, greaterThan(short));
  });

  test('the fine-tuned model gets its training prompt for an Arabic summary', () async {
    await summarize(arabicTranscript(3), _config);
    expect(
      gemma.prompts.every((p) => p.startsWith('لخّص النص التالي بأسلوب احترافي ومختصر.')),
      isTrue,
    );
  });

  test('an English summary is asked for in English', () async {
    await summarize(englishTranscript(3), _config.copyWith(language: ContentLanguage.en));
    expect(gemma.prompts, isNotEmpty);
    expect(gemma.prompts.every((p) => p.startsWith('Summarize the following text')), isTrue);
  });

  test('"يتحدث الكاتب عن" is stripped from each paragraph', () async {
    gemma.responder = (prompt, call) async => 'يتحدث الكاتب عن النقطة رقم $call.';
    final result = await summarize(arabicTranscript(6), _config);
    expect(result.summary, isNot(contains('يتحدث الكاتب')));
    expect(result.summary, startsWith('النقطة رقم 1.'));
  });

  test('a sentence restating an earlier paragraph is dropped', () async {
    const repeated = 'ناقش المشاركون نتائج الدراسة الميدانية الجديدة وأثرها على التعليم الجامعي.';
    gemma.responder = (prompt, call) async => repeated;
    final result = await summarize(arabicTranscript(6), _config);
    expect(result.summary, repeated, reason: 'later sections said nothing new');
  });

  test('model output is cleaned: echoed prompt, preamble, markdown, wrong language', () async {
    gemma.responder = (prompt, call) async => call == 1
        ? 'إليك ملخص النص:\n**النقطة الأولى** مهمة.\n\nThis paragraph is English only, not Arabic.'
        : 'النقطة رقم $call. لا تخترع معلومات غير موجودة في النص.';
    final result = await summarize(arabicTranscript(6), _config);
    final paragraphs = result.summary.split('\n\n');
    expect(paragraphs.first, 'النقطة الأولى مهمة.');
    expect(result.summary, isNot(contains('English')));
    expect(result.summary, isNot(contains('لا تخترع')));
    expect(result.summary, isNot(contains('إليك')));
  });

  test('a section that writes nothing is retried with its key points only', () async {
    // Varied units, so a section has both key points and lesser units.
    final text = File('test/features/summarization/fixtures/ai_lecture_ar.txt').readAsStringSync();
    var retried = false;
    gemma.responder = (prompt, call) async {
      if (call == 1) return '';
      if (call == 2) retried = true;
      return 'النقطة رقم $call.';
    };
    final result = await summarize(text, const SummarizationConfig(debugLogging: false));
    expect(retried, isTrue);
    expect(result.debug.retries, greaterThanOrEqualTo(1));
    expect(
      sourceOf(gemma.prompts[1]).length,
      lessThan(sourceOf(gemma.prompts[0]).length),
      reason: 'the retry reads only the key points of the section',
    );
  });

  test('a section left empty even after a retry flags the summary for review', () async {
    gemma.responder = (prompt, call) async => call <= 2 ? '' : 'النقطة رقم $call.';
    final result = await summarize(arabicTranscript(6), _config);
    expect(result.summary, isNotEmpty);
    expect(result.debug.droppedSections, greaterThan(0));
    expect(result.needsReview, isTrue);
  });

  test('a failed call leaves its section out instead of failing the job', () async {
    gemma.responder = (prompt, call) async =>
        call == 1 ? throw const GemmaGenerationException('x') : 'النقطة رقم $call.';
    final result = await summarize(arabicTranscript(6), _config);
    expect(result.summary, isNotEmpty);
  });

  test('fails when no section produced anything', () async {
    gemma.responder = (prompt, call) async => '';
    await expectLater(
      summarize(arabicTranscript(6), _config),
      throwsA(
        isA<SummarizationFailure>().having(
          (f) => f.kind,
          'kind',
          SummarizationFailureKind.generationFailed,
        ),
      ),
    );
  });

  test('a text that repeats itself throughout is still summarized, not all dropped as filler', () {
    // Twelve near-identical paragraphs: no term is distinctive anywhere.
    expect(analyzeSource((text: arabicTranscript(12), keyPointFactor: 1)).substantive, isEmpty);
    return expectLater(summarize(arabicTranscript(12), _config), completes);
  });

  test('an empty transcript is rejected', () async {
    await expectLater(
      summarize('  \n ', _config),
      throwsA(
        isA<SummarizationFailure>().having(
          (f) => f.kind,
          'kind',
          SummarizationFailureKind.emptyTranscript,
        ),
      ),
    );
  });

  test('text too short to condense is kept as its own summary, without the model', () async {
    final result = await summarize('نص قصير جدا من خمس كلمات.', _config);
    expect(result.summary, 'نص قصير جدا من خمس كلمات.');
    expect(gemma.calls, 0);
    expect(gemma.activated, isFalse, reason: 'the model is not even loaded');
  });

  test('Moonshine line seams are removed before summarizing', () async {
    final text = '${arabicTranscript(3)} البلاد\nالبلاد. ${arabicTranscript(3)}';
    await summarize(text, _config);
    expect(gemma.prompts.join(), isNot(contains('البلاد البلاد')));
  });

  test('progress moves from preparing through every section to completed', () async {
    final progress = <SummarizationProgress>[];
    await summarize(arabicTranscript(6), _config, onProgress: progress.add);
    expect(progress.first.stage, SummarizationStage.preparing);
    expect(progress.last.stage, SummarizationStage.completed);
    final sections = progress.where((p) => p.stage == SummarizationStage.summarizing).toList();
    expect(sections.map((p) => p.processedChunks), [for (var i = 0; i < gemma.calls; i++) i]);
    for (var i = 1; i < progress.length; i++) {
      expect(progress[i].fraction, greaterThanOrEqualTo(progress[i - 1].fraction));
    }
  });

  test('partial text grows as prefixes and ends at the final summary', () async {
    gemma.responder = (prompt, call) async => 'النقطة رقم $call من المحاضرة.';
    final partials = <String>[];
    final result = await summarize(
      arabicTranscript(6),
      _config,
      onPartialSummary: partials.add,
    );
    expect(partials, isNotEmpty);
    for (var i = 1; i < partials.length; i++) {
      expect(partials[i].startsWith(partials[i - 1]), isTrue, reason: 'step $i');
    }
    expect(partials.last, result.summary);
  });

  test('a cancelled token stops before the next section', () async {
    final token = CancellationToken();
    gemma.responder = (prompt, call) async {
      token.cancel();
      return 'النقطة رقم $call.';
    };
    await expectLater(
      summarize(arabicTranscript(6), _config, cancellation: token),
      throwsA(isA<CancelledException>()),
    );
    expect(gemma.calls, 1);
  });

  test('reports usage for the stored summary', () async {
    final result = await summarize(arabicTranscript(6), _config);
    expect(result.debug.inputTokens, greaterThan(0));
    expect(result.debug.outputTokens, greaterThan(0));
    expect(result.debug.summaryRatio, inInclusiveRange(0.04, 0.25));
    expect(result.debug.coverage, inInclusiveRange(0, 1));
  });

  test('the stream ends with the completed result', () async {
    final updates = await summarize.stream(arabicTranscript(6), _config).toList();
    expect(updates.last, isA<SummarizationCompletedUpdate>());
    expect(updates.whereType<SummarizationProgressUpdate>(), isNotEmpty);
    expect(updates.whereType<SummarizationPartialSummaryUpdate>(), isNotEmpty);
  });

  group('summary ratio', () {
    test('shrinks with the length of the source', () {
      const config = SummarizationConfig();
      expect(config.summaryRatio(300), 0.15);
      expect(config.summaryRatio(2279), closeTo(0.10, 0.01));
      expect(config.summaryRatio(15000), closeTo(0.06, 0.001));
    });

    test('scales with the requested length', () {
      const medium = SummarizationConfig();
      final short = medium.copyWith(length: SummaryLength.short);
      final detailed = medium.copyWith(length: SummaryLength.detailed);
      expect(short.summaryRatio(2279), lessThan(medium.summaryRatio(2279)));
      expect(detailed.summaryRatio(2279), greaterThan(medium.summaryRatio(2279)));
    });
  });
}
