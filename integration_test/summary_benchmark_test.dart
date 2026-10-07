// Summarizes one long transcript on a real phone with the app's pipeline and
// model, logging every section (`[summarizer] section …`: tokens, prefill and
// decode time, memory footprint, heat). Compares Gemma on the GPU and the CPU.
//
// Copy a transcript (plain text) into the app's Documents folder, then:
//
//   xcrun devicectl device copy to --device <id> --domain-type appDataContainer \
//     --domain-identifier com.nutq.nutq --source t.txt --destination Documents/t.txt
//   flutter test integration_test/summary_benchmark_test.dart -d <id> \
//     --dart-define=SUMMARY_FILE=t.txt --dart-define=SUMMARY_BACKENDS=gpu,cpu
import 'dart:convert';
import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/utils/background_work.dart';
import 'package:nutq/core/utils/platform_device_status.dart';
import 'package:nutq/features/summarization/data/datasources/flutter_gemma_runtime.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _file = String.fromEnvironment('SUMMARY_FILE');

/// Or the transcript itself, base64-encoded UTF-8, for devices where a file
/// cannot be placed in the app's storage before the test installs the app
/// (an Android emulator). Fine for a few thousand words.
const _textB64 = String.fromEnvironment('SUMMARY_TEXT_B64');
const _backends = String.fromEnvironment('SUMMARY_BACKENDS', defaultValue: 'gpu');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'summarize a long transcript, logging every section',
    (_) async {
      final String transcript;
      if (_textB64.isNotEmpty) {
        transcript = utf8.decode(base64.decode(_textB64));
      } else {
        final path = p.join((await getApplicationDocumentsDirectory()).path, _file);
        expect(File(path).existsSync(), isTrue, reason: 'copy the transcript to $path first');
        transcript = await File(path).readAsString();
      }
      const device = PlatformDeviceStatus();

      for (final name in _backends.split(',')) {
        final backend = name.trim() == 'cpu' ? PreferredBackend.cpu : PreferredBackend.gpu;
        // ignore: avoid_print
        print('[bench] backend=${backend.name} start ${await device.snapshot()}');
        final repository = SummarizationRepositoryImpl(
          dataSource: GemmaLocalDataSourceImpl(FlutterGemmaRuntime(backend: backend)),
        );
        final summarize = SummarizeTranscript(
          repository: repository,
          background: const IsolateBackgroundWork(),
          device: device,
        );
        final watch = Stopwatch()..start();
        final result = await summarize(
          transcript,
          const SummarizationConfig(language: ContentLanguage.ar),
        );
        // ignore: avoid_print
        print(
          '[bench] backend=${backend.name} total=${watch.elapsed.inSeconds}s '
          'sections=${result.debug.sectionCount} out=${result.debug.outputTokens}tok '
          'summary=${result.summary.length}chars ${await device.snapshot()}',
        );
        await repository.release();
        // Let the phone cool a little between backends.
        if (name != _backends.split(',').last) {
          await Future<void>.delayed(const Duration(minutes: 3));
        }
      }
    },
    skip: _file.isEmpty && _textB64.isEmpty,
    timeout: const Timeout(Duration(hours: 2)),
  );
}
