import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/transcription/data/moonshine_speech_recognizer.dart';
import 'package:nutq/features/transcription/domain/speech_recognizer.dart';

Map<String, Object> _line(String text, double start, double duration) => {
  'text': text,
  'start': start,
  'duration': duration,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const method = MethodChannel(MoonshineSpeechRecognizer.channelName);
  const progress = EventChannel(MoonshineSpeechRecognizer.progressChannelName);

  late List<MethodCall> calls;

  /// Makes the bridge emit [events] while `transcribe` is in flight, then
  /// return [result], or fail with [error].
  void fakeBridge({
    List<Map<String, Object>> events = const [],
    List<Map<String, Object>> result = const [],
    PlatformException? error,
  }) {
    MockStreamHandlerEventSink? sink;
    messenger.setMockStreamHandler(
      progress,
      MockStreamHandler.inline(onListen: (_, events) => sink = events),
    );
    messenger.setMockMethodCallHandler(method, (call) async {
      calls.add(call);
      if (call.method != 'transcribe') return null;
      for (final event in events) {
        sink!.success(event);
      }
      await pumpEventQueue();
      if (error != null) throw error;
      return result;
    });
  }

  setUp(() => calls = []);
  tearDown(() {
    messenger.setMockMethodCallHandler(method, null);
    messenger.setMockStreamHandler(progress, null);
  });

  final recognizer = MoonshineSpeechRecognizer(isAvailable: true);

  test('asks for the model of the spoken language and joins the lines', () async {
    fakeBridge(result: [_line(' Hello ', 0, 1), _line('', 1, 1), _line('world', 2, 1)]);
    final speech = await recognizer.transcribe(
      audioPath: '/tmp/a.wav',
      language: ContentLanguage.en,
    );
    expect(speech.text, 'Hello\nworld');
    expect(speech.modelName, 'moonshine-tiny-streaming-en');
    final args = calls.first.arguments as Map<Object?, Object?>;
    expect(args['modelPath'], 'tiny-streaming-en');
    expect(args['keepLoaded'], isFalse);
  });

  test('reports progress from 0 to 1 and releases the model afterwards', () async {
    fakeBridge(
      events: [
        {'progress': 0.25},
        {'progress': 0.75},
      ],
      result: [_line('مرحبا', 0, 1)],
    );
    final seen = <double>[];
    await recognizer.transcribe(
      audioPath: '/tmp/a.wav',
      language: ContentLanguage.ar,
      onProgress: seen.add,
    );
    expect(seen, [0, 0.25, 0.75, 1]);
    expect(calls.map((c) => c.method), ['transcribe', 'release']);
  });

  test('streams the transcript as it grows: finished lines kept, live lines replaced', () async {
    fakeBridge(
      events: [
        {
          'progress': 0.3,
          'finished': <Object>[],
          'live': [_line('مرحبا', 0, 1), _line('بكم في', 1, 1)],
        },
        {
          'progress': 0.6,
          'finished': [_line('مرحبا', 0, 1)],
          'live': [_line('بكم في النشرة', 1, 2)],
        },
        {'progress': 0.9}, // progress only
        {
          'progress': 1,
          'finished': [_line('بكم في النشرة', 1, 2)],
          'live': <Object>[],
        },
      ],
      result: [_line('مرحبا', 0, 1), _line('بكم في النشرة', 1, 2)],
    );
    final partials = <String>[];
    final speech = await recognizer.transcribe(
      audioPath: '/tmp/a.wav',
      language: ContentLanguage.ar,
      onPartialText: partials.add,
    );
    expect(partials, ['مرحبا\nبكم في', 'مرحبا\nبكم في النشرة', 'مرحبا\nبكم في النشرة']);
    expect(speech.text, partials.last, reason: 'live text ends where the result does');
  });

  test('a cancelled run throws CancelledException and still releases the model', () async {
    fakeBridge(error: PlatformException(code: 'moonshine_cancelled'));
    await expectLater(
      recognizer.transcribe(audioPath: '/tmp/a.wav', language: ContentLanguage.ar),
      throwsA(isA<CancelledException>()),
    );
    expect(calls.last.method, 'release');
  });

  test('a bridge error becomes a SpeechRecognitionException', () async {
    fakeBridge(
      error: PlatformException(code: 'moonshine_failed', message: 'no model'),
    );
    await expectLater(
      recognizer.transcribe(audioPath: '/tmp/a.wav', language: ContentLanguage.ar),
      throwsA(isA<SpeechRecognitionException>()),
    );
  });

  test('is unavailable off iOS and fails without calling the bridge', () async {
    fakeBridge();
    final android = MoonshineSpeechRecognizer(isAvailable: false);
    await expectLater(
      android.transcribe(audioPath: '/tmp/a.wav', language: ContentLanguage.ar),
      throwsA(isA<SpeechRecognitionException>()),
    );
    expect(calls, isEmpty);
  });

  test('cancel never throws, even with no bridge', () async {
    await recognizer.cancel();
  });

  test('pause and resume reach the bridge', () async {
    fakeBridge();
    await recognizer.pause();
    await recognizer.resume();
    expect(calls.map((c) => c.method), ['pause', 'resume']);
  });
}
