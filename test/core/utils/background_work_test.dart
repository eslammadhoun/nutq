import 'dart:async';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/utils/background_work.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/usecases/clean_transcript.dart';
import 'package:nutq/features/summarization/domain/usecases/prepare_transcript.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../features/summarization/support/fake_gemma.dart';

int _square(int x) => x * x;

String? _isolateName(void _) => Isolate.current.debugName;

int _boom(void _) => throw StateError('boom');

List<int> _echo(List<int> values) => [for (final v in values) v + 1];

String _bigTranscript(int words) => List.generate(words, (i) => 'كلمة$i${i % 17 == 16 ? '.' : ''}').join(' ');

const _config = SummarizationConfig(targetTokens: 60, overlapTokens: 10, minTokens: 30, maxTokens: 90);

void main() {
  const isolate = IsolateBackgroundWork();
  const inline = InlineBackgroundWork();

  group('both implementations', () {
    for (final entry in {'isolate': isolate as BackgroundWork, 'inline': inline as BackgroundWork}.entries) {
      test('${entry.key}: returns the task result', () async {
        expect(await entry.value.run(_square, 12), 144);
      });

      test('${entry.key}: rethrows the task\'s error', () async {
        await expectLater(entry.value.run(_boom, null), throwsA(isA<StateError>()));
      });

      test('${entry.key}: carries large lists both ways', () async {
        final input = List.generate(200000, (i) => i);
        final out = await entry.value.run(_echo, input);
        expect(out.length, input.length);
        expect(out.last, input.last + 1);
      });
    }
  });

  test('the isolate really runs the task on a different isolate', () async {
    final worker = await isolate.run(_isolateName, null);
    expect(worker, isNot(Isolate.current.debugName));
    expect(await inline.run(_isolateName, null), Isolate.current.debugName);
  });

  group('the UI thread stays free', () {
    /// The longest gap between 5 ms timer ticks while [work] runs.
    Future<int> longestStall(Future<void> Function() work) async {
      var last = Stopwatch()..start();
      var worst = 0;
      final timer = Timer.periodic(const Duration(milliseconds: 5), (_) {
        final gap = last.elapsedMilliseconds;
        if (gap > worst) worst = gap;
        last = Stopwatch()..start();
      });
      await work();
      await Future<void>.delayed(const Duration(milliseconds: 30)); // let a tick observe any stall
      timer.cancel();
      return worst;
    }

    final request = (clean: const CleanTranscript(), maxSentenceWords: 80, text: _bigTranscript(150000));

    test('cleaning and segmenting a very long transcript does not stall the event loop in an isolate', () async {
      final stall = await longestStall(() => isolate.run(prepareTranscript, request));
      expect(stall, lessThan(150), reason: 'the main isolate kept ticking while the worker worked');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('control: the same work inline does stall it, so this check can detect blocking', () async {
      final stall = await longestStall(() => inline.run(prepareTranscript, request));
      expect(stall, greaterThan(150), reason: 'inline work blocks for the whole duration');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  test('prepareTranscript cleans, segments and gives identical results either way', () async {
    final text = '  مرحبا   بكم.  كيف حالكم؟\n\nفقرة   جديدة !!!  ';
    final args = (clean: const CleanTranscript(), maxSentenceWords: 80, text: text);
    final viaIsolate = await isolate.run(prepareTranscript, args);
    final viaInline = await inline.run(prepareTranscript, args);
    expect(viaIsolate.cleaned, viaInline.cleaned);
    expect(viaIsolate.sentences.map((s) => (s.index, s.text, s.endsParagraph)), viaInline.sentences.map((s) => (s.index, s.text, s.endsParagraph)));
    expect(viaInline.sentences.length, 3);
  });

  test('the pipeline produces the same summary and validation with an isolate as inline', () async {
    final text = List.generate(
      6,
      (i) => 'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024 وقال الدكتور أحمد محمد إن النتائج جيدة.',
    ).join('\n\n');

    Future<dynamic> run(BackgroundWork background) async {
      final gemma = FakeGemma(
        responder: (prompt, call) async =>
            prompt.contains('final summary of a full lecture') ? 'شارك 9999 شخصا في الفعالية.' : null,
      );
      final pipeline = SummarizeTranscript(
        repository: SummarizationRepositoryImpl(dataSource: gemma),
        background: background,
      );
      return pipeline(text, _config);
    }

    final a = await run(isolate);
    final b = await run(inline);
    expect(a.summary, b.summary);
    expect(a.keyPoints, b.keyPoints);
    expect(a.debug.chunkCount, b.debug.chunkCount);
    expect(a.validation.issues.map((i) => (i.type, i.severity, i.detail)), b.validation.issues.map((i) => (i.type, i.severity, i.detail)));
    expect(a.validation.isSuspicious, isTrue, reason: 'the hallucinated number is still flagged when validation ran in an isolate');
  });

  test('cancelling still works when preparation and validation run in an isolate', () async {
    final gemma = FakeGemma();
    final pipeline = SummarizeTranscript(
      repository: SummarizationRepositoryImpl(dataSource: gemma),
      background: isolate,
    );
    final token = CancellationToken();
    // A pre-cancelled token stops the job before any model call.
    await expectLater(
      pipeline(_bigTranscript(400), _config, cancellation: token..cancel()),
      throwsA(isA<Exception>()),
    );
    expect(gemma.calls, 0);
  });
}
