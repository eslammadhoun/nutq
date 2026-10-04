// Compares Moonshine settings on one recording, on a real phone: speed, heat
// and words. Each run waits for the phone to cool first, so earlier runs do
// not slow later ones down.
//
// Copy a recording into the app's Documents folder, then run on the phone:
//
//   xcrun devicectl device copy to --device <id> --domain-type appDataContainer \
//     --domain-identifier com.nutq.nutq --source bench.m4a --destination Documents/bench.m4a
//   flutter test integration_test/moonshine_benchmark_test.dart -d <id> \
//     --dart-define=BENCH_FILE=bench.m4a
//
// A path starting with `/` is used as is (the Simulator can read the Mac's).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/transcription/data/ffmpeg_audio_extractor.dart';
import 'package:nutq/features/transcription/data/moonshine_speech_recognizer.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _file = String.fromEnvironment('BENCH_FILE');

/// Optional: indices of [_configs] to run, comma-separated (all by default).
const _only = String.fromEnvironment('BENCH_CONFIGS');

/// Longest wait for the phone to cool before a run.
const _coolDownLimit = Duration(minutes: 10);

class _Config {
  const _Config(
    this.name, {
    required this.decodeIncomplete,
    this.singleThread = false,
  });

  final String name;
  final bool decodeIncomplete;
  final bool singleThread;
}

const _configs = [
  _Config('library default', decodeIncomplete: true),
  _Config('complete lines only', decodeIncomplete: false),
  _Config('complete only, 1 thread', decodeIncomplete: false, singleThread: true),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Moonshine settings, cool start each',
    (_) async {
      final path = _file.startsWith('/')
          ? _file
          : p.join((await getApplicationDocumentsDirectory()).path, _file);
      expect(File(path).existsSync(), isTrue, reason: 'copy the recording to $path first');
      final audio = await FfmpegAudioExtractor().extract(path);
      final seconds = audio.duration.inMilliseconds / 1000;
      final probe = MoonshineSpeechRecognizer();

      Future<String?> coolDown() async {
        final watch = Stopwatch()..start();
        var state = await probe.thermalState();
        while ((state == 'serious' || state == 'critical') && watch.elapsed < _coolDownLimit) {
          await Future<void>.delayed(const Duration(seconds: 15));
          state = await probe.thermalState();
        }
        // Settle a little even when already cool.
        await Future<void>.delayed(const Duration(seconds: 20));
        return probe.thermalState();
      }

      try {
        final picked = _only.isEmpty
            ? _configs
            : [for (final i in _only.split(',')) _configs[int.parse(i.trim())]];
        final texts = <String, String>{};
        for (final config in picked) {
          final before = await coolDown();
          final cpuBefore = await probe.cpuSeconds() ?? 0;
          final watch = Stopwatch()..start();
          final speech = await MoonshineSpeechRecognizer(
            decodeIncompleteLines: config.decodeIncomplete,
            singleThread: config.singleThread,
          ).transcribe(audioPath: audio.path, language: ContentLanguage.ar);
          final elapsed = watch.elapsed.inMilliseconds / 1000;
          final cpu = (await probe.cpuSeconds() ?? 0) - cpuBefore;
          final after = await probe.thermalState();
          final words = speech.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
          texts['${texts.length}:${config.name}'] = speech.text;
          // ignore: avoid_print
          print(
            '[bench] ${config.name}: audio=${seconds.toStringAsFixed(0)}s '
            'time=${elapsed.toStringAsFixed(1)}s rtf=${(elapsed / seconds).toStringAsFixed(3)} '
            'cpu=${cpu.toStringAsFixed(0)}s (${(cpu / elapsed).toStringAsFixed(1)} cores busy) '
            'words=$words thermal=$before->$after',
          );
        }
        // How each run's words differ from the first run's: where they part
        // and how many differ. Moonshine is not bit-for-bit deterministic, so
        // repeating one setting shows the noise floor to read the rest against.
        final runs = texts.entries.toList();
        final reference = runs.first.value.split(RegExp(r'\s+'));
        for (final run in runs.skip(1)) {
          final words = run.value.split(RegExp(r'\s+'));
          var i = 0;
          while (i < words.length && i < reference.length && words[i] == reference[i]) {
            i++;
          }
          var j = 0;
          while (j < words.length - i &&
              j < reference.length - i &&
              words[words.length - 1 - j] == reference[reference.length - 1 - j]) {
            j++;
          }
          // ignore: avoid_print
          print(
            '[diff] ${run.key} vs ${runs.first.key}: ${words.length} vs ${reference.length} words, '
            'identical for the first $i and last $j',
          );
        }
      } finally {
        await audio.delete();
      }
    },
    skip: _file.isEmpty,
    timeout: const Timeout(Duration(hours: 1)),
  );
}
