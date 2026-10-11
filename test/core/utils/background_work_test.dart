import 'dart:async';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/utils/background_work.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../features/summarization/support/fake_gemma.dart';
import '../../support/sample_text.dart';

int _square(int x) => x * x;

String? _isolateName(void _) => Isolate.current.debugName;

int _boom(void _) => throw StateError('boom');

List<int> _echo(List<int> values) => [for (final v in values) v + 1];

const _config = SummarizationConfig(wordsPerCall: 20, debugLogging: false);

void main() {
  const isolate = IsolateBackgroundWork();
  const inline = InlineBackgroundWork();

  group('both implementations', () {
    for (final entry in {
      'isolate': isolate as BackgroundWork,
      'inline': inline as BackgroundWork,
    }.entries) {
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

    final request = (text: arabicTranscript(2000), keyPointFactor: 1.0);

    test(
      'analyzing a very long transcript does not stall the event loop in an isolate',
      () async {
        final stall = await longestStall(() => isolate.run(analyzeSource, request));
        expect(
          stall,
          lessThan(150),
          reason: 'the main isolate kept ticking while the worker worked',
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'control: the same work inline does stall it, so this check can detect blocking',
      () async {
        final stall = await longestStall(() => inline.run(analyzeSource, request));
        expect(stall, greaterThan(150), reason: 'inline work blocks for the whole duration');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });

  test('source analysis gives identical results either way', () async {
    final args = (text: arabicTranscript(12), keyPointFactor: 1.0);
    final viaIsolate = await isolate.run(analyzeSource, args);
    final viaInline = await inline.run(analyzeSource, args);
    expect(viaIsolate.units.map((u) => (u.index, u.text, u.score)), [
      for (final u in viaInline.units) (u.index, u.text, u.score),
    ]);
    expect(viaIsolate.important.map((u) => u.index), viaInline.important.map((u) => u.index));
    expect(viaIsolate.topicTerms, viaInline.topicTerms);
  });

  test('the pipeline produces the same summary with an isolate as inline', () async {
    final text = arabicTranscript(6);

    Future<SummaryResult> run(BackgroundWork background) async {
      final pipeline = SummarizeTranscript(
        repository: SummarizationRepositoryImpl(dataSource: FakeGemma()),
        background: background,
      );
      return pipeline(text, _config);
    }

    final a = await run(isolate);
    final b = await run(inline);
    expect(a.summary, isNotEmpty);
    expect(a.summary, b.summary);
    expect(a.debug.sectionCount, b.debug.sectionCount);
  });

  test('cancelling still works when the analysis runs in an isolate', () async {
    final gemma = FakeGemma();
    final pipeline = SummarizeTranscript(
      repository: SummarizationRepositoryImpl(dataSource: gemma),
      background: isolate,
    );
    final token = CancellationToken();
    // A pre-cancelled token stops the job before any model call.
    await expectLater(
      pipeline(longArabicText(400), _config, cancellation: token..cancel()),
      throwsA(isA<Exception>()),
    );
    expect(gemma.calls, 0);
  });
}
