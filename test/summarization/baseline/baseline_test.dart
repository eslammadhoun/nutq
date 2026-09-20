import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';

import '../../features/summarization/support/fake_gemma.dart';
import '../../support/benchmark/baseline_summarizer.dart';

void main() {
  late FakeGemma gemma;
  late BaselineSummarizer baseline;

  setUp(() {
    gemma = FakeGemma();
    baseline = BaselineSummarizer(
      SummarizationRepositoryImpl(dataSource: gemma),
      wordsPerChunk: 50,
    );
  });

  test('splits by fixed word windows, summarizes each and concatenates in order', () async {
    final transcript = List.generate(120, (i) => 'كلمة$i').join(' ');
    var call = 0;
    gemma.responder = (prompt, _) async => 'ملخص ${call++}';
    final result = await baseline(transcript, const SummarizationConfig());

    expect(result.debug.chunkCount, 3); // 50 + 50 + 20 words
    expect(result.summary, 'ملخص 0\n\nملخص 1\n\nملخص 2');
    expect(gemma.prompts.first, contains('كلمة0'));
    expect(gemma.prompts.first, isNot(contains('كلمة50')));
    expect(gemma.prompts, hasLength(3)); // no analysis, merge or final calls
  });

  test('records failed windows instead of aborting', () async {
    final transcript = List.generate(120, (i) => 'كلمة$i').join(' ');
    gemma.responder = (prompt, call) async {
      if (call == 2) throw const GemmaGenerationException('x');
      return null;
    };
    final result = await baseline(transcript, const SummarizationConfig());
    expect(result.debug.failedChunkCount, 1);
    expect(result.debug.chunkCount, 3);
  });
}
