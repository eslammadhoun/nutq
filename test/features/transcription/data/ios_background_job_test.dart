import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/transcription/data/ios_background_job.dart';
import 'package:nutq/features/transcription/domain/background_job.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel(IosBackgroundJob.channelName);

  late List<MethodCall> calls;
  setUp(() {
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  IosBackgroundJob job([String language = 'en']) =>
      IosBackgroundJob(localizations: () => lookupAppLocalizations(Locale(language)));

  test('begin sends the title, the duration and the strings in the app language', () async {
    await job('ar').begin(title: 'talk.m4a', duration: const Duration(seconds: 90));
    final args = calls.single.arguments as Map<Object?, Object?>;
    expect(calls.single.method, 'begin');
    expect(args['title'], 'talk.m4a');
    expect(args['duration'], 90.0);
    final labels = args['labels']! as Map<Object?, Object?>;
    expect(labels['locale'], 'ar');
    expect(labels['readyTitle'], 'النص جاهز');
  });

  test('labels keep the placeholders the bridge fills in', () {
    final labels = IosBackgroundJob.labelsOf(lookupAppLocalizations(const Locale('en')));
    expect(labels['running'], 'Transcribing · {percent}');
    expect(labels['interruptedBody'], contains('{title}'));
    expect(labels['readyBody'], contains('{title}'));
    expect(labels.values, everyElement(isNotEmpty));
  });

  test('update, pause and end reach the bridge', () async {
    final background = job();
    await background.update(progress: 0.25);
    await background.setPaused(true);
    await background.end(completed: true);
    expect(calls.map((c) => c.method), ['update', 'setPaused', 'end']);
    expect((calls.first.arguments as Map<Object?, Object?>)['progress'], 0.25);
  });

  test('lock-screen presses arrive as commands', () async {
    final background = job();
    final commands = <BackgroundJobCommand>[];
    background.commands.listen(commands.add);
    for (final press in ['pause', 'resume']) {
      await messenger.handlePlatformMessage(
        IosBackgroundJob.channelName,
        const StandardMethodCodec().encodeMethodCall(MethodCall('command', press)),
        (_) {},
      );
    }
    await pumpEventQueue();
    expect(commands, [BackgroundJobCommand.pause, BackgroundJobCommand.resume]);
  });

  test('never throws when the bridge is missing', () async {
    messenger.setMockMethodCallHandler(channel, null);
    await job().begin(title: 'x');
    await job().end(completed: false);
  });
}
