import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/media_information_session.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:path/path.dart' as p;

/// Fixed-window audio chunking for long recordings.
///
/// `whisper_ggml`'s one-shot `transcribe()` call (see
/// `lib/core/ml/whisper/whisper_engine_impl.dart`) has no native mid-call
/// abort and delivers all segments in a single burst at the end rather
/// than incrementally — so for a long field recording, feeding it the
/// whole file in one call would mean minutes with no progress feedback and
/// no cancellation checkpoint. Splitting into fixed ~5-minute windows with
/// a small overlap gives `AsrPipeline` a natural progress/cancellation
/// checkpoint between chunks, at the cost of needing simple text-level
/// de-duplication at the seams (see [AsrPipeline] /
/// `dedupeChunkBoundary`).
///
/// Kept as fixed windows rather than voice-activity-detection (VAD)
/// per the plan — no extra model dependency, simplest thing that works;
/// flagged there as a v2 enhancement if boundary artifacts show up in
/// real-world testing.
class AudioChunker {
  const AudioChunker({
    this.chunkDuration = const Duration(minutes: 5),
    this.overlap = const Duration(seconds: 2),
  });

  final Duration chunkDuration;
  final Duration overlap;

  /// Splits [audioPath] into consecutive chunks of [chunkDuration] with
  /// [overlap] seconds of lead-in (except the first chunk), written as WAV
  /// files under [outputDir]. Returns the ordered chunk file paths.
  ///
  /// If the source is shorter than [chunkDuration], returns `[audioPath]`
  /// unchanged (no point re-encoding a file that's already one chunk).
  Future<List<String>> chunk(String audioPath, {required Directory outputDir}) async {
    final totalDuration = await _probeDuration(audioPath);
    if (totalDuration == null || totalDuration <= chunkDuration) {
      return [audioPath];
    }

    await outputDir.create(recursive: true);

    final chunkPaths = <String>[];
    final baseName = p.basenameWithoutExtension(audioPath);
    var index = 0;
    var start = Duration.zero;

    while (start < totalDuration) {
      final windowStart = index == 0 ? start : start - overlap;
      final clampedStart = windowStart.isNegative ? Duration.zero : windowStart;
      final outputPath = p.join(outputDir.path, '${baseName}_chunk$index.wav');

      final session = await FFmpegKit.execute(
        [
          '-y',
          '-i',
          audioPath,
          '-ss',
          clampedStart.inMilliseconds / 1000,
          '-t',
          (chunkDuration + (index == 0 ? Duration.zero : overlap)).inMilliseconds / 1000,
          '-ar',
          '16000',
          '-ac',
          '1',
          '-c:a',
          'pcm_s16le',
          outputPath,
        ].join(' '),
      );
      final returnCode = await session.getReturnCode();
      if (!ReturnCode.isSuccess(returnCode)) {
        throw StateError('ffmpeg chunk $index failed with return code $returnCode');
      }

      chunkPaths.add(outputPath);
      index++;
      start += chunkDuration;
    }

    return chunkPaths;
  }

  /// Returns `null` (treat as a single chunk) both when ffprobe can't
  /// determine a duration and when the platform channel itself is
  /// unavailable — e.g. in a plain `flutter test` VM run with no plugin
  /// registered, which would otherwise throw `MissingPluginException`.
  Future<Duration?> _probeDuration(String audioPath) async {
    try {
      final MediaInformationSession session = await FFprobeKit.getMediaInformation(audioPath);
      final durationSeconds = session.getMediaInformation()?.getDuration();
      if (durationSeconds == null) return null;
      final seconds = double.tryParse(durationSeconds);
      if (seconds == null) return null;
      return Duration(milliseconds: (seconds * 1000).round());
    } catch (_) {
      return null;
    }
  }

  /// Drops a repeated trailing/leading word run at a chunk boundary — a
  /// simple text-level de-dup for the ~2s overlap window, since whisper
  /// output has no stable timestamps we can rely on to line up
  /// word-for-word across a re-decoded overlap.
  ///
  /// Looks for the longest run (up to [maxWords] words) at the end of
  /// [previousText] that also appears at the start of [nextText], and
  /// strips it from [nextText] before the caller appends it.
  static String dedupeChunkBoundary(String previousText, String nextText, {int maxWords = 12}) {
    final prevWords = previousText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final nextWords = nextText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (prevWords.isEmpty || nextWords.isEmpty) return nextText;

    final limit = [maxWords, prevWords.length, nextWords.length].reduce((a, b) => a < b ? a : b);
    for (var runLength = limit; runLength > 0; runLength--) {
      final prevTail = prevWords.sublist(prevWords.length - runLength);
      final nextHead = nextWords.sublist(0, runLength);
      if (_listEquals(prevTail, nextHead)) {
        return nextWords.sublist(runLength).join(' ');
      }
    }
    return nextText;
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
