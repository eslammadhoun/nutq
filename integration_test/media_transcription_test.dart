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
import 'package:nutq/features/transcription/data/ios_background_job.dart';
import 'package:nutq/features/transcription/data/moonshine_speech_recognizer.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:nutq/l10n/app_localizations.dart';

const _arMedia = String.fromEnvironment('AR_MEDIA');
const _enMedia = String.fromEnvironment('EN_MEDIA');

/// Optional: a long Arabic recording for checking background running by hand.
/// Leave the app during the run (or `xcrun simctl launch booted
/// com.apple.Preferences` on the Simulator) and watch the logged progress keep
/// moving.
const _longMedia = String.fromEnvironment('LONG_MEDIA');

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
    final text = await transcribe(_arMedia, ContentLanguage.ar);
    expect(_arabicLetter.allMatches(text).length, greaterThan(20));
  }, skip: _arMedia.isEmpty);

  testWidgets('English speech comes out as English text', (_) async {
    final text = await transcribe(_enMedia, ContentLanguage.en);
    expect(text.toLowerCase(), contains('budget'));
    expect(_latinLetter.allMatches(text).length, greaterThan(20));
  }, skip: _enMedia.isEmpty);

  testWidgets('a media job runs through the real lock-screen bridge', (_) async {
    final source = MediaTranscriptSource(
      type: JobSourceType.audio,
      extractor: extractor,
      recognizer: recognizer,
      background: IosBackgroundJob(
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
          sourceFilePath: _arMedia,
          sourceTitle: 'speech.m4a',
        ),
        onProgress: (p) => stages.add(p.stage),
        cancellation: CancellationToken(),
        saveSourceInfo: (_) async {},
      ),
    );
    expect(stages, {JobStage.acquiring, JobStage.transcribing});
    expect(_arabicLetter.allMatches(transcript.text).length, greaterThan(20));
  }, skip: _arMedia.isEmpty);

  testWidgets(
    'a long job keeps running outside the app',
    (_) async {
      final source = MediaTranscriptSource(
        type: JobSourceType.audio,
        extractor: extractor,
        recognizer: recognizer,
        background: IosBackgroundJob(
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

  testWidgets('a file with no audio fails as an extraction error', (_) async {
    final broken = File('${Directory.systemTemp.path}/broken.mp4')
      ..writeAsStringSync('not a video');
    await expectLater(extractor.extract(broken.path), throwsA(isA<AudioExtractionException>()));
  });
}
