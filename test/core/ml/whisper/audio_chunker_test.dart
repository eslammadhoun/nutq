import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/ml/whisper/audio_chunker.dart';

void main() {
  // `AudioChunker.chunk` probes duration via `ffmpeg_kit_flutter_new_min`'s
  // FFprobeKit, which touches a platform `EventChannel` even on the path
  // that ends up failing gracefully — that channel setup needs the test
  // binding initialized, or the failure surfaces as an unhandled zone
  // error instead of the caught, awaited exception `_probeDuration`
  // expects.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioChunker.dedupeChunkBoundary', () {
    test('strips a repeated trailing/leading word run', () {
      final result = AudioChunker.dedupeChunkBoundary(
        'this is the end of the previous chunk',
        'end of the previous chunk continues here',
      );
      expect(result, 'continues here');
    });

    test('returns nextText unchanged when there is no overlap', () {
      final result = AudioChunker.dedupeChunkBoundary('hello world', 'completely different text');
      expect(result, 'completely different text');
    });

    test('handles empty previous text', () {
      final result = AudioChunker.dedupeChunkBoundary('', 'some new text');
      expect(result, 'some new text');
    });

    test('handles empty next text', () {
      final result = AudioChunker.dedupeChunkBoundary('previous text', '');
      expect(result, '');
    });

    test('respects maxWords when matching a long overlap run', () {
      final result = AudioChunker.dedupeChunkBoundary(
        'one two three four five six seven eight nine ten eleven twelve thirteen',
        'twelve thirteen fourteen',
        maxWords: 3,
      );
      // Only up to 3 trailing/leading words are compared, so "twelve
      // thirteen" (2 words) is still found within that window.
      expect(result, 'fourteen');
    });
  });

  group('AudioChunker.chunk', () {
    test('returns the original path unchanged when duration cannot be probed (test env has no ffmpeg channel)', () async {
      const chunker = AudioChunker();
      final result = await chunker.chunk('/tmp/does-not-matter.wav', outputDir: Directory.systemTemp);
      expect(result, ['/tmp/does-not-matter.wav']);
    });
  });
}
