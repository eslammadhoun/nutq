import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';

import '../support/fake_llm_runtime.dart';

void main() {
  const config = GemmaGenerationConfig(temperature: 0.3, topK: 10, seed: 5, maxOutputTokens: 123);
  late FakeLlmRuntime runtime;
  late GemmaLocalDataSourceImpl source;

  setUp(() {
    runtime = FakeLlmRuntime();
    source = GemmaLocalDataSourceImpl(runtime);
  });

  group('token counting', () {
    test('keeps one tokenizer session until closed, then opens a new one', () async {
      await source.countTokens('أ ب');
      await source.countTokens('ج');
      expect(runtime.tokenizerOpens, 1);
      final first = runtime.tokenizer!;

      await source.closeTokenizer();
      expect(first.closed, isTrue, reason: 'its KV cache is freed');

      await source.countTokens('د');
      expect(runtime.tokenizerOpens, 2);
    });

    test('closing with no tokenizer open is harmless', () async {
      await source.closeTokenizer();
      expect(runtime.tokenizerOpens, 0);
    });
  });

  group('activation', () {
    test('loads the model once, on first use', () async {
      expect(runtime.loadCalls, 0);
      await source.activate();
      await source.activate();
      expect(runtime.loadCalls, 1);
    });

    test('concurrent activations share one load', () async {
      final gate = Completer<void>();
      runtime.loadDelay = gate;
      final all = Future.wait([source.activate(), source.activate(), source.activate()]);
      await pumpEventQueue();
      gate.complete();
      await all;
      expect(runtime.loadCalls, 1);
    });

    test('a load failure is modelUnavailable, and a later attempt can succeed', () async {
      runtime.loadError = StateError('asset missing');
      await expectLater(
        source.activate(),
        throwsA(
          isA<SummarizationFailure>().having(
            (f) => f.kind,
            'kind',
            SummarizationFailureKind.modelUnavailable,
          ),
        ),
      );
      runtime.loadError = null;
      await source.activate();
      expect(runtime.loaded, isTrue);
    });

    test('availability is answered by the runtime without loading', () async {
      runtime.available = false;
      expect(await source.isModelAvailable(), isFalse);
      expect(runtime.loadCalls, 0);
    });
  });

  group('generate', () {
    test('returns the cleaned reply with usage and timing, and closes the session', () async {
      runtime.sessionFor = (_) => FakeLlmSession(reply: '```\nملخص جيد\n```<end_of_turn>');
      final response = await source.generate('الموجه', config);

      expect(response.text, 'ملخص جيد');
      expect(response.inputTokens, 100);
      expect(response.outputTokens, 40);
      expect(response.durationMs, greaterThanOrEqualTo(0));
      expect(runtime.sessions.single.prompt, 'الموجه');
      expect(runtime.sessions.single.closed, isTrue);
      expect(
        runtime.configs.single.maxOutputTokens,
        123,
        reason: 'the generation config reaches the runtime',
      );
      expect(runtime.configs.single.seed, 5);
    });

    test('every call uses a fresh, independent session', () async {
      await source.generate('أ', config);
      await source.generate('ب', config);
      expect(runtime.sessions, hasLength(2));
      expect(runtime.sessions.map((s) => s.prompt), ['أ', 'ب']);
    });

    test('retries once after a failure', () async {
      runtime.sessionFor = (n) =>
          n == 0 ? FakeLlmSession(error: StateError('flaky')) : FakeLlmSession(reply: 'نجح');
      final response = await source.generate('p', config);
      expect(response.text, 'نجح');
      expect(runtime.sessions, hasLength(2));
      expect(
        runtime.sessions.every((s) => s.closed),
        isTrue,
        reason: 'the failed attempt was closed too',
      );
    });

    test('gives up after maxAttempts with the last error', () async {
      runtime.sessionFor = (n) => FakeLlmSession(error: StateError('failure $n'));
      await expectLater(
        source.generate('p', config),
        throwsA(
          isA<GemmaGenerationException>().having(
            (e) => e.message,
            'message',
            contains('failure 1'),
          ),
        ),
      );
      expect(runtime.sessions, hasLength(2));
    });

    test('maxAttempts is respected', () async {
      final single = GemmaLocalDataSourceImpl(runtime, maxAttempts: 1);
      runtime.sessionFor = (n) => FakeLlmSession(error: StateError('x'));
      await expectLater(single.generate('p', config), throwsA(isA<GemmaGenerationException>()));
      expect(runtime.sessions, hasLength(1));
    });

    test('an empty reply counts as a failure and is retried', () async {
      runtime.sessionFor = (n) =>
          n == 0 ? FakeLlmSession(reply: '  <end_of_turn> ') : FakeLlmSession(reply: 'محتوى');
      expect((await source.generate('p', config)).text, 'محتوى');
      expect(runtime.sessions, hasLength(2));
    });

    test('a session that fails to close does not fail the generation', () async {
      runtime.sessionFor = (_) =>
          FakeLlmSession(reply: 'ok', closeError: StateError('close failed'));
      expect((await source.generate('p', config)).text, 'ok');
    });

    test('loads the model on demand', () async {
      await source.generate('p', config);
      expect(runtime.loaded, isTrue);
    });
  });

  group('streaming', () {
    test('reports the cleaned text accumulated so far, growing token by token', () async {
      runtime.sessionFor = (_) => FakeLlmSession(tokens: ['مرحبا', ' بكم', ' في', ' الدرس']);
      final partials = <String>[];
      final response = await source.generate('p', config, onPartial: partials.add);
      expect(partials, ['مرحبا', 'مرحبا بكم', 'مرحبا بكم في', 'مرحبا بكم في الدرس']);
      expect(response.text, 'مرحبا بكم في الدرس');
    });

    test('chat-template tokens never appear in partial text', () async {
      runtime.sessionFor = (_) =>
          FakeLlmSession(tokens: ['<start_of_turn>model\n', 'نص', ' نهائي', '<end_of_turn>']);
      final partials = <String>[];
      final response = await source.generate('p', config, onPartial: partials.add);
      expect(partials.any((p) => p.contains('<')), isFalse);
      expect(partials.first, 'نص', reason: 'nothing is reported until there is real text');
      expect(response.text, 'نص نهائي');
    });

    test(
      'a failure mid-stream is retried and the partial text restarts from the beginning',
      () async {
        runtime.sessionFor = (n) => n == 0
            ? _FailingStreamSession(['نص', ' قديم'])
            : FakeLlmSession(tokens: ['نص', ' جديد']);
        final partials = <String>[];
        final response = await source.generate('p', config, onPartial: partials.add);
        expect(response.text, 'نص جديد');
        expect(partials, [
          'نص',
          'نص قديم',
          'نص',
          'نص جديد',
        ], reason: 'the second attempt replaces, not appends');
      },
    );

    test('the reply is streamed even without onPartial, so the guards always apply', () async {
      runtime.sessionFor = (_) => FakeLlmSession(reply: 'لا يستخدم', tokens: ['مت', 'دفق']);
      expect((await source.generate('p', config)).text, 'متدفق');
    });
  });

  group('guards', () {
    test('a loop is cut off and generation stopped', () async {
      final looping = FakeLlmSession(
        tokens: ['ملخص مفيد. ', for (var i = 0; i < 30; i++) 'من '],
      );
      runtime.sessionFor = (_) => looping;
      final response = await source.generate('p', config);
      expect(response.text, startsWith('ملخص مفيد.'));
      expect(response.text.split('من').length, lessThan(6), reason: 'the loop was cut');
      expect(response.stoppedOnLoop, isTrue);
      expect(looping.stopCalls, 1);
    });

    test('garbage output stops early and fails without a retry', () async {
      const garbage = ['ৈতন্য ', 'بال', 'camera', 'AutoFocus ', 'SRPGoGet ', '<unused607> '];
      final broken = FakeLlmSession(tokens: [for (var i = 0; i < 20; i++) ...garbage]);
      runtime.sessionFor = (_) => broken;
      await expectLater(
        source.generate('p', config),
        throwsA(
          isA<SummarizationFailure>().having(
            (f) => f.kind,
            'kind',
            SummarizationFailureKind.generationFailed,
          ),
        ),
      );
      expect(runtime.sessions, hasLength(1), reason: 'the same backend would fail again');
      expect(broken.stopCalls, 1, reason: 'stopped after a few dozen tokens');
    });

    test('a reply cut off by the output cap keeps only whole sentences', () async {
      runtime.sessionFor = (_) => FakeLlmSession(
        tokens: ['الجملة الأولى كاملة. ', 'والجملة الثانية ', 'أيضا كاملة. ', 'وجملة مقطوعة'],
      );
      final response = await source.generate('p', config.copyWith(maxOutputTokens: 4));
      expect(response.hitCap, isTrue);
      expect(response.text, 'الجملة الأولى كاملة. والجملة الثانية أيضا كاملة.');
    });

    test('measures the prefill as the time to the first token', () async {
      final response = await source.generate('p', config);
      expect(response.prefillMs, lessThanOrEqualTo(response.durationMs));
    });
  });

  group('cancellation', () {
    test('cancelling right before the attempt throws without opening a session', () async {
      await source.activate();
      final started = source.generate('p', config);
      final expectation = expectLater(started, throwsA(isA<CancelledException>()));
      await source.cancel(); // lands after generate() began but before its first attempt
      await expectation;
      expect(runtime.sessions, isEmpty);
    });

    test('cancelling mid-stream stops the session and is never retried', () async {
      final gate = Completer<void>();
      final session = FakeLlmSession(tokens: ['أ', 'ب', 'ج', 'د'], gate: gate);
      runtime.sessionFor = (_) => session;
      final partials = <String>[];
      final generation = source.generate('p', config, onPartial: partials.add);
      await pumpEventQueue();

      await source.cancel();
      expect(session.stopCalls, 1);
      gate.complete();
      await expectLater(generation, throwsA(isA<CancelledException>()));
      expect(runtime.sessions, hasLength(1), reason: 'a cancelled generation is not retried');
      expect(session.closed, isTrue);
    });

    test('cancelling a whole-reply generation stops the session too', () async {
      final gate = Completer<void>();
      final session = FakeLlmSession(gate: gate, reply: 'متأخر');
      runtime.sessionFor = (_) => session;
      final generation = source.generate('p', config);
      await pumpEventQueue();
      await source.cancel();
      gate.complete();
      await expectLater(generation, throwsA(isA<CancelledException>()));
      expect(session.stopCalls, 1);
    });

    test(
      'a failure that happens while cancelling is reported as cancellation, even on the last attempt',
      () async {
        final gate = Completer<void>();
        runtime.sessionFor = (_) =>
            FakeLlmSession(gate: gate, error: StateError('stopped abruptly'));
        final lastAttempt = GemmaLocalDataSourceImpl(runtime, maxAttempts: 1);
        final generation = lastAttempt.generate('p', config);
        await pumpEventQueue();
        await lastAttempt.cancel();
        gate.complete();
        await expectLater(
          generation,
          throwsA(isA<CancelledException>()),
          reason: 'not a GemmaGenerationException',
        );
        expect(runtime.sessions, hasLength(1));
      },
    );

    test('cancelling when idle is harmless, and the next job is not affected', () async {
      await source.cancel();
      final response = await source.generate('p', config);
      expect(response.text, isNotEmpty);
    });
  });

  group('token counting', () {
    test('uses one long-lived tokenizer session and loads the model first', () async {
      expect(await source.countTokens('نص'), 7);
      expect(await source.countTokens('نص آخر'), 7);
      expect(runtime.loadCalls, 1);
      expect(runtime.tokenizerOpens, 1, reason: 'the session is reused');
    });

    test('is separate from generation sessions', () async {
      await source.countTokens('نص');
      await source.generate('p', config);
      expect(runtime.tokenizer, isNot(same(runtime.sessions.single)));
      expect(runtime.tokenizer!.closed, isFalse, reason: 'generating does not close the tokenizer');
    });
  });

  group('release (dispose)', () {
    test('unloads the model and closes the tokenizer', () async {
      await source.countTokens('نص');
      final tokenizer = runtime.tokenizer!;
      await source.dispose();
      expect(runtime.unloadCalls, 1);
      expect(runtime.loaded, isFalse);
      expect(tokenizer.closed, isTrue);
    });

    test('the next use reloads the model and opens a new tokenizer', () async {
      await source.countTokens('نص');
      await source.dispose();
      await source.countTokens('نص');
      expect(runtime.loadCalls, 2);
      expect(runtime.tokenizerOpens, 2);
    });

    test('generation works again after a release', () async {
      await source.generate('p', config);
      await source.dispose();
      expect((await source.generate('p', config)).text, isNotEmpty);
      expect(runtime.loadCalls, 2);
    });

    test('errors while releasing are swallowed', () async {
      await source.countTokens('نص');
      runtime.tokenizer = null;
      runtime.unloadError = StateError('cannot unload');
      await source.dispose(); // must not throw
      expect(runtime.unloadCalls, 1);
    });

    test('releasing when nothing was loaded is harmless', () async {
      await source.dispose();
      expect(runtime.unloadCalls, 1);
    });
  });
}

/// Yields some tokens, then fails.
class _FailingStreamSession extends FakeLlmSession {
  _FailingStreamSession(this._tokens);

  final List<String> _tokens;

  @override
  Stream<String> respondStream() async* {
    for (final t in _tokens) {
      yield t;
      await Future<void>.delayed(Duration.zero);
    }
    throw StateError('stream broke');
  }
}
