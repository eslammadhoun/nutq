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

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/transcription/data/ffmpeg_audio_extractor.dart';
import 'package:nutq/features/transcription/data/moonshine_speech_recognizer.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';

const _arMedia = String.fromEnvironment('AR_MEDIA');
const _enMedia = String.fromEnvironment('EN_MEDIA');

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
      final speech = await recognizer.transcribe(
        audioPath: audio.path,
        language: language,
        onProgress: progress.add,
      );
      expect(progress.last, 1);
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

  testWidgets('a file with no audio fails as an extraction error', (_) async {
    final broken = File('${Directory.systemTemp.path}/broken.mp4')
      ..writeAsStringSync('not a video');
    await expectLater(extractor.extract(broken.path), throwsA(isA<AudioExtractionException>()));
  });
}
