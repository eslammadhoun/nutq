import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/benchmark/benchmark_fixture.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/text/arabic_normalizer.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../features/summarization/support/fake_gemma.dart';

/// Structural golden tests: they assert properties of the *pipeline*
/// (nothing important is lost before or between model calls), never exact
/// generated wording. A faithful mock model stands in for Gemma.
///
/// They do not measure real summary quality — that needs the on-device
/// benchmark.
void main() {
  late List<BenchmarkFixture> fixtures;

  setUpAll(() async {
    fixtures = await BenchmarkFixture.loadDirectory(Directory('test/summarization/fixtures'));
  });

  /// Mock model that behaves faithfully: facts are the source lines that
  /// contain digits; summaries echo the first source sentence.
  Future<String?> faithfulModel(String prompt, int call) async {
    if (prompt.contains('information extraction assistant')) {
      final source = prompt.split('SOURCE:\n').last;
      final numericLines = source.split(RegExp(r'(?<=[.؟!])\s+|\n')).where((l) => RegExp(r'\d').hasMatch(l)).take(5);
      return 'MAIN:\nفكرة رئيسية\n\nPOINTS:\n- نقطة\n\nFACTS:\n${numericLines.map((l) => '- ${l.trim()}').join('\n')}\n\nIMPORTANT_TERMS:\n- مصطلح';
    }
    return null;
  }

  test('important numbers and entities always reach the model (nothing lost by cleaning/chunking)', () async {
    for (final f in fixtures) {
      final gemma = FakeGemma(responder: faithfulModel);
      final pipeline = SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma));
      await pipeline(f.transcript, const SummarizationConfig(targetTokens: 80, overlapTokens: 10, minTokens: 40, maxTokens: 120));

      final sent = ArabicNormalizer.normalize(gemma.prompts.join('\n'));
      for (final v in [...f.importantNumbers, ...f.importantEntities]) {
        expect(sent, contains(ArabicNormalizer.normalize(v)), reason: '${f.id}: "$v" never reached the model');
      }
    }
  });

  test('numbers found by analysis are carried into the final synthesis prompt', () async {
    for (final f in fixtures) {
      final gemma = FakeGemma(responder: faithfulModel);
      final pipeline = SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma));
      await pipeline(f.transcript, const SummarizationConfig(targetTokens: 80, overlapTokens: 10, minTokens: 40, maxTokens: 120));

      final finalPrompt = ArabicNormalizer.normalize(
        gemma.prompts.lastWhere((p) => p.contains('final summary of a full lecture')),
      );
      final carried = f.importantNumbers.where((n) => finalPrompt.contains(ArabicNormalizer.normalize(n)));
      expect(carried, isNotEmpty, reason: '${f.id}: no important number reached the final prompt');
    }
  });

  test('every fixture completes end-to-end with a non-empty summary and no failed chunks', () async {
    for (final f in fixtures) {
      final gemma = FakeGemma(responder: faithfulModel);
      final result = await SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma))(
        f.transcript,
        const SummarizationConfig(targetTokens: 80, overlapTokens: 10, minTokens: 40, maxTokens: 120),
      );
      expect(result.summary, isNotEmpty, reason: f.id);
      expect(result.debug.failedChunkCount, 0, reason: f.id);
      expect(result.debug.chunkCount, greaterThan(0), reason: f.id);
    }
  });

  test('longer fixtures produce more chunks than shorter ones', () async {
    Future<int> chunks(BenchmarkFixture f) async {
      final r = await SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: FakeGemma()))(
        f.transcript,
        const SummarizationConfig(targetTokens: 80, overlapTokens: 10, minTokens: 40, maxTokens: 120),
      );
      return r.debug.chunkCount;
    }

    final short = await chunks(fixtures.firstWhere((f) => f.size == 'short'));
    final long = await chunks(fixtures.firstWhere((f) => f.size == 'long'));
    expect(long, greaterThan(short));
  });

  test('no forbidden cloud call: summarization code has no network dependency', () {
    final forbidden = RegExp(
      r'package:(dio|http|retrofit|web_socket_channel|googleapis|firebase_\w+)/|HttpClient|WebSocket\.connect|https?://|fromNetwork|fromHuggingFace|api\.openai|generativelanguage',
    );
    final offenders = <String>[];
    for (final file in Directory('lib/features/summarization').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final hit = forbidden.firstMatch(file.readAsStringSync());
      if (hit != null) offenders.add('${file.path}: ${hit.group(0)}');
    }
    expect(offenders, isEmpty);

    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final dep in ['dio', 'http', 'retrofit', 'web_socket_channel', 'google_generative_ai', 'openai']) {
      expect(RegExp('^  $dep:', multiLine: true).hasMatch(pubspec), isFalse, reason: 'pubspec depends on $dep');
    }
  });

  test('the pinned model is the only LLM: exact asset, no alternatives', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/models/gemma3-1b-it-q4.litertlm'));
    expect(pubspec, isNot(contains('llama_cpp_dart')));
    final source = File('lib/features/summarization/data/datasources/gemma_local_datasource.dart').readAsStringSync();
    expect(source, contains("'assets/models/gemma3-1b-it-q4.litertlm'"));
  });
}
