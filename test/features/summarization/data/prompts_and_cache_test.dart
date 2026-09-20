import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/data/cache/summarization_cache.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/prompts/chunk_analysis_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/final_summary_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/local_summary_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/merge_prompt.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

void main() {
  group('prompts', () {
    test('analysis and local prompts embed the source and their rules', () {
      final a = ChunkAnalysisPrompt.build('النص المصدر');
      expect(a, contains('SOURCE:\nالنص المصدر'));
      expect(a, contains('MAIN:'));
      expect(a, contains('IMPORTANT_TERMS:'));
      expect(a, contains('Do not invent facts'));

      final l = LocalSummaryPrompt.build('النص المصدر');
      expect(l, contains('SOURCE:\nالنص المصدر'));
      expect(l, contains('يتحدث النص عن'));
    });

    test('merge prompt numbers summaries and marks empty sections', () {
      final p = MergePrompt.build(summaries: ['أ', 'ب'], facts: const [], evidence: ['دليل']);
      expect(p, contains('1. أ'));
      expect(p, contains('2. ب'));
      expect(p, contains('IMPORTANT FACTS:\n- (none)'));
      expect(p, contains('SOURCE EVIDENCE:\n- دليل'));
    });

    test('final prompt carries the requested length target', () {
      String build(SummaryLength l) => FinalSummaryPrompt.build(
        summaries: ['ملخص'],
        keyFacts: ['حقيقة'],
        entities: const [],
        numbers: ['5'],
        length: l,
      );
      expect(build(SummaryLength.short), contains('5 to 8 short bullet points'));
      expect(build(SummaryLength.medium), contains('250-400'));
      expect(build(SummaryLength.detailed), contains('500-700'));
    });
  });

  group('cache', () {
    String key({String prompt = 'v1', String input = 'x', String cfg = 'c'}) =>
        SummarizationCache.keyFor(
          modelVersion: 'm',
          promptVersion: prompt,
          stage: 'local',
          input: input,
          configSignature: cfg,
        );

    test('key is stable and changes with prompt version, input or config', () {
      expect(key(), key());
      expect(key(), hasLength(64));
      expect(key(prompt: 'v2'), isNot(key()));
      expect(key(input: 'y'), isNot(key()));
      expect(key(cfg: 'd'), isNot(key()));
    });

    test('in-memory cache round-trips', () async {
      final cache = InMemorySummarizationCache();
      expect(await cache.read('k'), isNull);
      await cache.write('k', 'قيمة');
      expect(await cache.read('k'), 'قيمة');
    });

    test('file cache round-trips Arabic text', () async {
      final dir = await Directory.systemTemp.createTemp('nutq_cache_test');
      addTearDown(() => dir.delete(recursive: true));
      final cache = FileSummarizationCache(Directory('${dir.path}/nested'));
      expect(await cache.read('k'), isNull);
      await cache.write('k', 'ملخص محفوظ');
      expect(await cache.read('k'), 'ملخص محفوظ');
    });
  });

  group('GemmaLocalDataSource.cleanResponse', () {
    test('strips chat-template tokens and whitespace', () {
      expect(GemmaLocalDataSourceImpl.cleanResponse('  ملخص<end_of_turn>\n'), 'ملخص');
      expect(GemmaLocalDataSourceImpl.cleanResponse('<start_of_turn>model\nملخص'), 'ملخص');
    });

    test('unwraps a fenced code block', () {
      expect(GemmaLocalDataSourceImpl.cleanResponse('```\nMAIN:\nفكرة\n```'), 'MAIN:\nفكرة');
    });

    test('leaves normal text untouched', () {
      expect(GemmaLocalDataSourceImpl.cleanResponse('نص عادي'), 'نص عادي');
    });
  });
}
