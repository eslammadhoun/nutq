import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_bloc.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_event.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_state.dart';

import '../support/fake_gemma.dart';

void main() {
  late FakeGemma gemma;
  late SummarizationRepositoryImpl repository;

  SummarizationBloc build() {
    gemma = FakeGemma();
    repository = SummarizationRepositoryImpl(dataSource: gemma);
    return SummarizationBloc(
      summarize: SummarizeTranscript(repository: repository),
      repository: repository,
      baseConfig: const SummarizationConfig(targetTokens: 60, overlapTokens: 10, minTokens: 30, maxTokens: 90),
    );
  }

  const transcript = 'نناقش اليوم موضوع الذكاء الاصطناعي وتطبيقاته في التعليم. شارك 250 طالبا في التجربة.';

  test('starts idle', () {
    expect(build().state, isA<SummarizationIdle>());
  });

  blocTest<SummarizationBloc, SummarizationState>(
    'happy path: running (with progress) → success',
    build: build,
    act: (b) => b.add(const SummarizationStarted(transcript: transcript, length: SummaryLength.short)),
    wait: const Duration(milliseconds: 50),
    expect: () => allOf(
      contains(isA<SummarizationRunning>()),
      predicate<List<dynamic>>((states) => states.last is SummarizationSuccess, 'ends in success'),
    ),
    verify: (b) {
      final s = b.state as SummarizationSuccess;
      expect(s.result.summary, 'الملخص النهائي للمحاضرة');
      expect(gemma.prompts.last, contains('5 to 8 short bullet points'));
    },
  );

  blocTest<SummarizationBloc, SummarizationState>(
    'empty transcript → failed(emptyTranscript)',
    build: build,
    act: (b) => b.add(const SummarizationStarted(transcript: '   ', length: SummaryLength.medium)),
    expect: () => [
      isA<SummarizationRunning>(),
      isA<SummarizationFailed>().having((s) => s.kind, 'kind', SummarizationFailureKind.emptyTranscript),
    ],
  );

  blocTest<SummarizationBloc, SummarizationState>(
    'unexpected model failure → failed(generationFailed)',
    build: () {
      final b = build();
      gemma.failEverything = true;
      return b;
    },
    act: (b) => b.add(const SummarizationStarted(transcript: transcript, length: SummaryLength.medium)),
    wait: const Duration(milliseconds: 50),
    verify: (b) {
      expect(b.state, isA<SummarizationFailed>().having((s) => s.kind, 'kind', SummarizationFailureKind.generationFailed));
    },
  );

  test('cancel mid-run → cancelled state, model told to stop, no more calls', () async {
    final bloc = build();
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };

    bloc.add(const SummarizationStarted(transcript: transcript, length: SummaryLength.medium));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state, isA<SummarizationRunning>());

    bloc.add(const SummarizationCancelRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(gemma.cancelled, isTrue);

    gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(bloc.state, isA<SummarizationCancelled>());
    expect(gemma.calls, 1);
    await bloc.close();
  });

  test('a second start while running is ignored', () async {
    final bloc = build();
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    bloc.add(const SummarizationStarted(transcript: transcript, length: SummaryLength.medium));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const SummarizationStarted(transcript: 'نص آخر مختلف تماما.', length: SummaryLength.short));
    gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(bloc.state, isA<SummarizationSuccess>());
    expect(gemma.prompts.any((p) => p.contains('نص آخر مختلف')), isFalse);
    await bloc.close();
  });

  blocTest<SummarizationBloc, SummarizationState>(
    'reset returns to idle after a result',
    build: build,
    act: (b) async {
      b.add(const SummarizationStarted(transcript: transcript, length: SummaryLength.medium));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      b.add(const SummarizationReset());
    },
    wait: const Duration(milliseconds: 100),
    verify: (b) => expect(b.state, isA<SummarizationIdle>()),
  );

  test('progress stages are surfaced through Running states', () async {
    final bloc = build();
    final stages = <SummarizationStage>[];
    final sub = bloc.stream.listen((s) {
      if (s is SummarizationRunning) stages.add(s.progress.stage);
    });
    bloc.add(const SummarizationStarted(transcript: transcript, length: SummaryLength.medium));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(stages, contains(SummarizationStage.analyzing));
    expect(stages, contains(SummarizationStage.finalizing));
    await sub.cancel();
    await bloc.close();
  });
}
