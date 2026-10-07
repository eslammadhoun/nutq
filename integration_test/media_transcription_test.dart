// Runs the real media path: FFmpeg → Moonshine → the bundled per-language
// models. iOS only (the Moonshine bridge is in ios/Runner). The Simulator runs
// Moonshine natively on Apple Silicon, so it works there as well as on a phone.
//
// Pass audio files the device can read, one per language:
//
//   flutter test integration_test/media_transcription_test.dart -d <device> \
//     --dart-define=AR_MEDIA=/path/arabic.m4a --dart-define=EN_MEDIA=/path/english.m4a
//
// On the Simulator any path on the Mac works. `say -v Majed -o ar.m4a
// --data-format=aac "…"` makes a quick Arabic sample.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/sources/media_transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/transcription/data/ffmpeg_audio_extractor.dart';
import 'package:nutq/features/transcription/data/moonshine_speech_recognizer.dart';
import 'package:nutq/features/transcription/data/platform_background_job.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:nutq/l10n/app_localizations.dart';

const _arPath = String.fromEnvironment('AR_MEDIA');
const _enPath = String.fromEnvironment('EN_MEDIA');

/// Or the clips themselves, base64-encoded, for devices that cannot read the
/// Mac's files (an Android emulator); written to a temporary file first.
const _arB64 = String.fromEnvironment('AR_MEDIA_B64');
const _enB64 = String.fromEnvironment('EN_MEDIA_B64');

const _hasAr = _arPath != '' || _arB64 != '';
const _hasEn = _enPath != '' || _enB64 != '';

/// A clip's path: the one given, or a temporary copy of the encoded one.
Future<String> _media(String path, String b64, String name) async {
  if (path.isNotEmpty) return path;
  final file = File('${Directory.systemTemp.path}/$name');
  await file.writeAsBytes(base64.decode(b64));
  return file.path;
}

/// Optional: a long Arabic recording for checking background running by hand.
/// Leave the app during the run (or `xcrun simctl launch booted
/// com.apple.Preferences` on the Simulator) and watch the logged progress keep
/// moving.
const _longMedia = String.fromEnvironment('LONG_MEDIA');

/// Optional: an Arabic recording to compare Moonshine settings on.
const _benchMedia = String.fromEnvironment('BENCH_MEDIA');

final _arabicLetter = RegExp('[؀-ۿ]');
final _latinLetter = RegExp('[A-Za-z]');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final extractor = FfmpegAudioExtractor();
  final recognizer = MoonshineSpeechRecognizer();

  Future<String> transcribe(String media, ContentLanguage language) async {
    final audio = await extractor.extract(media);
    try {
      expect(audio.duration, greaterThan(Duration.zero));
      final progress = <double>[];
      final partials = <String>[];
      final speech = await recognizer.transcribe(
        audioPath: audio.path,
        language: language,
        onProgress: progress.add,
        onPartialText: partials.add,
      );
      expect(progress.last, 1);
      expect(partials, isNotEmpty, reason: 'text arrives while transcribing');
      expect(partials.last, speech.text, reason: 'the live text ends at the result');
      // Logged so a run shows what the model heard.
      // ignore: avoid_print
      print('[${language.code}] ${speech.modelName}: ${speech.text}');
      return speech.text;
    } finally {
      await audio.delete();
    }
  }

  testWidgets('Arabic speech comes out as Arabic text', (_) async {
    final text = await transcribe(await _media(_arPath, _arB64, 'ar.m4a'), ContentLanguage.ar);
    expect(_arabicLetter.allMatches(text).length, greaterThan(20));
  }, skip: !_hasAr);

  testWidgets('English speech comes out as English text', (_) async {
    final text = await transcribe(await _media(_enPath, _enB64, 'en.m4a'), ContentLanguage.en);
    expect(text.toLowerCase(), contains('budget'));
    expect(_latinLetter.allMatches(text).length, greaterThan(20));
  }, skip: !_hasEn);

  testWidgets('a media job runs through the real lock-screen bridge', (_) async {
    final source = MediaTranscriptSource(
      type: JobSourceType.audio,
      extractor: extractor,
      recognizer: recognizer,
      background: PlatformBackgroundJob(
        localizations: () => lookupAppLocalizations(const Locale('ar')),
      ),
    );
    final stages = <JobStage>{};
    final transcript = await source.resolve(
      SourceRequest(
        job: JobDetailEntity(
          id: 'device-test',
          status: JobRunStatus.running,
          sourceType: JobSourceType.audio,
          sourceLanguage: ContentLanguage.ar,
          summaryLanguage: ContentLanguage.ar,
          requestedLength: SummaryLength.medium,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sourceFilePath: await _media(_arPath, _arB64, 'ar.m4a'),
          sourceTitle: 'speech.m4a',
        ),
        onProgress: (p) => stages.add(p.stage),
        cancellation: CancellationToken(),
        saveSourceInfo: (_) async {},
      ),
    );
    expect(stages, {JobStage.acquiring, JobStage.transcribing});
    expect(_arabicLetter.allMatches(transcript.text).length, greaterThan(20));
  }, skip: !_hasAr);

  testWidgets(
    'a long job keeps running outside the app',
    (_) async {
      final source = MediaTranscriptSource(
        type: JobSourceType.audio,
        extractor: extractor,
        recognizer: recognizer,
        background: PlatformBackgroundJob(
          localizations: () => lookupAppLocalizations(const Locale('ar')),
        ),
      );
      final started = DateTime.now();
      var lastDecile = -1;
      await source.resolve(
        SourceRequest(
          job: JobDetailEntity(
            id: 'device-test-long',
            status: JobRunStatus.running,
            sourceType: JobSourceType.audio,
            sourceLanguage: ContentLanguage.ar,
            summaryLanguage: ContentLanguage.ar,
            requestedLength: SummaryLength.medium,
            createdAt: started,
            updatedAt: started,
            sourceFilePath: _longMedia,
            sourceTitle: 'long.m4a',
          ),
          onProgress: (p) {
            final decile = (p.fraction * 10).floor();
            if (decile == lastDecile) return;
            lastDecile = decile;
            final state = WidgetsBinding.instance.lifecycleState?.name;
            // ignore: avoid_print
            print(
              '[long] ${DateTime.now().difference(started).inSeconds}s '
              '${(p.fraction * 100).round()}% ${p.stage.name} app=$state',
            );
          },
          cancellation: CancellationToken(),
          saveSourceInfo: (_) async {},
        ),
      );
    },
    skip: _longMedia.isEmpty,
    timeout: const Timeout(Duration(minutes: 30)),
  );

  // Compares Moonshine with `decode_incomplete_lines` on (the library default)
  // and off (Nutq's setting) on the same file: time, and that the transcript
  // keeps every word, the final phrase included.
  testWidgets(
    'decoding complete lines only is faster and loses no words',
    (_) async {
      final audio = await extractor.extract(_benchMedia);
      try {
        Future<({Duration time, String text})> run({required bool decodeIncomplete}) async {
          final watch = Stopwatch()..start();
          final speech = await MoonshineSpeechRecognizer(
            decodeIncompleteLines: decodeIncomplete,
          ).transcribe(audioPath: audio.path, language: ContentLanguage.ar);
          return (time: watch.elapsed, text: speech.text);
        }

        final full = await run(decodeIncomplete: true);
        final fast = await run(decodeIncomplete: false);
        int words(String t) => t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
        final audioSeconds = audio.duration.inMilliseconds / 1000;
        // ignore: avoid_print
        print(
          '[bench] audio=${audioSeconds.toStringAsFixed(0)}s '
          'default: ${full.time.inMilliseconds}ms ${words(full.text)} words, '
          'rtf=${(full.time.inMilliseconds / 1000 / audioSeconds).toStringAsFixed(3)} | '
          'complete-only: ${fast.time.inMilliseconds}ms ${words(fast.text)} words, '
          'rtf=${(fast.time.inMilliseconds / 1000 / audioSeconds).toStringAsFixed(3)}',
        );
        // ignore: avoid_print
        print('[bench] default tail: ${full.text.split('\n').last}');
        // ignore: avoid_print
        print('[bench] complete-only tail: ${fast.text.split('\n').last}');
        expect(words(fast.text), greaterThanOrEqualTo((words(full.text) * 0.98).floor()));
        expect(fast.text.split('\n').last.trim(), isNotEmpty, reason: 'the last phrase is kept');
      } finally {
        await audio.delete();
      }
    },
    skip: _benchMedia.isEmpty,
    timeout: const Timeout(Duration(minutes: 30)),
  );

  testWidgets('a file with no audio fails as an extraction error', (_) async {
    final broken = File('${Directory.systemTemp.path}/broken.mp4')
      ..writeAsStringSync('not a video');
    await expectLater(extractor.extract(broken.path), throwsA(isA<AudioExtractionException>()));
  });
}
