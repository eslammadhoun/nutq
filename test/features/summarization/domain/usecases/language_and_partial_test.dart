import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/data/cache/summarization_cache.dart';
import 'package:nutq/features/summarization/data/prompts/chunk_analysis_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/final_summary_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/local_summary_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/merge_prompt.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/local_summary.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../../../support/sample_text.dart';
import '../../support/fake_gemma.dart';

const _config = SummarizationConfig(
  targetTokens: 60,
  overlapTokens: 10,
  minTokens: 30,
  maxTokens: 90,
);
final _text = englishTranscript(16);

void main() {
  group('prompts follow the requested language', () {
    test('English prompts name English and never Arabic', () {
      final prompts = [
        ChunkAnalysisPrompt.build('src', language: ContentLanguage.en),
        LocalSummaryPrompt.build('src', language: ContentLanguage.en),
        MergePrompt.build(
          summaries: ['a', 'b'],
          facts: const [],
          evidence: const [],
          language: ContentLanguage.en,
        ),
        FinalSummaryPrompt.build(
          summaries: ['a'],
          keyFacts: const [],
          entities: const [],
          numbers: const [],
          length: SummaryLength.medium,
          language: ContentLanguage.en,
        ),
      ];
      for (final p in prompts) {
        expect(p, contains('English'));
        expect(p, isNot(contains('Arabic')));
        expect(p, isNot(contains('يتحدث النص عن')));
      }
      expect(prompts[1], contains('Do not start with "The text talks about"'));
      expect(prompts[3], contains('250-400 English words'));
    });

    test('Arabic remains the default and keeps the Arabic opening rule', () {
      expect(ChunkAnalysisPrompt.build('src'), contains('Write in Arabic.'));
      expect(LocalSummaryPrompt.build('src'), contains('يتحدث النص عن'));
      expect(ContentLanguage.fromCode('en'), ContentLanguage.en);
      expect(ContentLanguage.fromCode('xx'), ContentLanguage.ar);
    });
  });

  group('pipeline', () {
    late FakeGemma gemma;
    late SummarizeTranscript pipeline;

    setUp(() {
      gemma = FakeGemma();
      pipeline = SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma));
    });

    test('language reaches every model call (analysis, local, merge, final)', () async {
      await pipeline(_text, _config.copyWith(language: ContentLanguage.en));
      expect(gemma.prompts.length, greaterThan(6));
      for (final p in gemma.prompts) {
        expect(p, contains('English'));
        expect(p, isNot(contains('Arabic')));
      }
      // All four stages were exercised.
      for (final marker in [
        'information extraction assistant',
        'Summarize the provided',
        'merging summaries',
        'final summary of a full lecture',
      ]) {
        expect(gemma.prompts.any((p) => p.contains(marker)), isTrue, reason: marker);
      }
    });

    test('default language is Arabic', () async {
      await pipeline('نص عربي قصير عن موضوع مهم.', _config);
      expect(gemma.prompts.every((p) => p.contains('Arabic')), isTrue);
    });

    test('English transcripts validate sensibly (no Arabic-only stop-word inflation)', () async {
      gemma.responder = (prompt, call) async => prompt.contains('final summary of a full lecture')
          ? 'Attendance reached 250 people in 2024 and Dr Smith said the results were good.'
          : null;
      final result = await pipeline(_text, _config.copyWith(language: ContentLanguage.en));
      expect(result.validation.claims.single.score, greaterThan(0.6));
    });
  });

  group('partial summary streaming', () {
    late FakeGemma gemma;
    late SummarizeTranscript pipeline;

    setUp(() {
      gemma = FakeGemma();
      pipeline = SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma));
    });

    const longFinal =
        'الملخص النهائي يشرح الفكرة الرئيسية للمحاضرة ثم ينتقل إلى النقاط المهمة والأرقام والتواريخ ويختم بالخلاصة';

    test(
      'the stream carries growing partial text, only for the final stage, before the result',
      () async {
        gemma.responder = (prompt, call) async =>
            prompt.contains('final summary of a full lecture') ? longFinal : null;
        final updates = await pipeline.stream(_text, _config).toList();

        final partials = updates
            .whereType<SummarizationPartialSummaryUpdate>()
            .map((u) => u.text)
            .toList();
        expect(partials.length, greaterThan(5));
        for (var i = 1; i < partials.length; i++) {
          expect(
            partials[i].startsWith(partials[i - 1]),
            isTrue,
            reason: 'partial $i extends partial ${i - 1}',
          );
          expect(partials[i].length, greaterThan(partials[i - 1].length));
        }
        expect(partials.last, longFinal);

        final completedAt = updates.indexWhere((u) => u is SummarizationCompletedUpdate);
        final lastPartialAt = updates.lastIndexWhere((u) => u is SummarizationPartialSummaryUpdate);
        expect(lastPartialAt, lessThan(completedAt));
        expect((updates[completedAt] as SummarizationCompletedUpdate).result.summary, longFinal);
      },
    );

    test('partials only appear once the final synthesis begins', () async {
      gemma.responder = (prompt, call) async =>
          prompt.contains('final summary of a full lecture') ? longFinal : null;
      var callsWhenFirstPartial = -1;
      var finalPromptIndex = -1;
      await for (final u in pipeline.stream(_text, _config)) {
        if (u is SummarizationPartialSummaryUpdate && callsWhenFirstPartial < 0) {
          callsWhenFirstPartial = gemma.calls;
          finalPromptIndex = gemma.prompts.indexWhere(
            (p) => p.contains('final summary of a full lecture'),
          );
        }
      }
      expect(finalPromptIndex, gemma.calls - 1, reason: 'final prompt is the last model call');
      expect(callsWhenFirstPartial, gemma.calls);
    });

    test('a cached final summary is delivered as one partial then the result', () async {
      final repo = SummarizationRepositoryImpl(
        dataSource: gemma,
        cache: InMemorySummarizationCache(),
      );
      final cached = SummarizeTranscript(repository: repo);
      await cached(_text, _config);
      final callsAfterFirst = gemma.calls;

      final partials = <String>[];
      final result = await cached(_text, _config, onPartialSummary: partials.add);
      expect(gemma.calls, callsAfterFirst);
      expect(partials, [result.summary]);
    });

    test('repository forwards onPartial for the final summary only', () async {
      final repo = SummarizationRepositoryImpl(dataSource: gemma);
      final partials = <String>[];
      final text = await repo.generateFinalSummary(
        FinalSummaryRequest(
          summaries: const [
            LocalSummary(chunkIds: [0], text: 'ملخص'),
          ],
          keyFacts: const [],
          entities: const [],
          numbers: const [],
          length: SummaryLength.short,
        ),
        onPartial: partials.add,
      );
      expect(partials, isNotEmpty);
      expect(partials.last, text);
    });
  });
}
