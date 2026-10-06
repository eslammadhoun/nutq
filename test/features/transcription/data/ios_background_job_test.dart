import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/domain/services/background_job.dart';
import 'package:nutq/features/transcription/data/ios_background_job.dart';
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

  test('begin sends the title and the strings in the app language', () async {
    await job('ar').begin(title: 'talk.m4a');
    final args = calls.single.arguments as Map<Object?, Object?>;
    expect(calls.single.method, 'begin');
    expect(args['title'], 'talk.m4a');
    final labels = args['labels']! as Map<Object?, Object?>;
    expect(labels['locale'], 'ar');
    expect(labels['readyTitle'], 'النص جاهز');
  });

  test('labels keep the placeholders the bridge fills in', () {
    final labels = IosBackgroundJob.labelsOf(lookupAppLocalizations(const Locale('en')));
    expect(labels['transcribing'], 'Transcribing · {percent}');
    expect(labels.keys, containsAll(BackgroundJobPhase.values.map((p) => p.name)));
    expect(labels['interruptedBody'], contains('{title}'));
    expect(labels['readyBody'], contains('{title}'));
    expect(labels.values, everyElement(isNotEmpty));
  });

  test('update, phase, pause and end reach the bridge', () async {
    final background = job();
    await background.update(progress: 0.25, estimatedTotal: const Duration(minutes: 2));
    await background.setPhase(BackgroundJobPhase.summarizing);
    await background.setPaused(true);
    await background.end(completed: true);
    expect(calls.map((c) => c.method), ['update', 'setPhase', 'setPaused', 'end']);
    expect(calls[0].arguments, {'progress': 0.25, 'duration': 120.0});
    expect(calls[1].arguments, {'phase': 'summarizing'});
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
