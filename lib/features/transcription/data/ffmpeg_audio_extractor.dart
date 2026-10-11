import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/transcription/data/wav_duration.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Decodes any audio or video file to 16 kHz mono PCM with FFmpeg, the only
/// input format the Moonshine bridge accepts.
class FfmpegAudioExtractor implements AudioExtractor {
  FfmpegAudioExtractor({Future<Directory> Function()? outputDirectory})
    : _outputDirectory = outputDirectory ?? defaultOutputDirectory;

  final Future<Directory> Function() _outputDirectory;

  /// The extraction in flight, so [cancel] stops that session rather than
  /// every FFmpeg session in the process. Null when nothing is running.
  FFmpegSession? _running;

  static const _filePrefix = 'transcribe_input_';

  @override
  Future<ExtractedAudio> extract(String inputPath) async {
    final output = await _newOutputPath();

    // An argument list, not a command string, so paths containing spaces or
    // quotes need no escaping.
    final arguments = [
      '-y',
      '-nostdin',
      '-i', inputPath,
      '-vn', '-sn', '-dn', // audio only: skip video, subtitle and data streams
      '-ac', '1',
      '-ar', '16000',
      '-c:a', 'pcm_s16le',
      output,
    ];

    // The two steps FFmpegKit.executeWithArguments performs, except that
    // holding the session lets cancel() address this run by id.
    final session = await FFmpegSession.create(arguments);
    _running = session;
    try {
      await FFmpegKitConfig.ffmpegExecute(session);
      final code = await session.getReturnCode();

      if (ReturnCode.isCancel(code)) {
        await _deleteQuietly(output);
        throw const CancelledException();
      }
      if (!ReturnCode.isSuccess(code)) {
        final reason = _lastLogLine(await session.getAllLogsAsString());
        await _deleteQuietly(output);
        throw AudioExtractionException('ffmpeg failed: $reason');
      }

      try {
        final duration = await readWavDuration(File(output));
        return ExtractedAudio(path: output, duration: duration);
      } on FormatException catch (e) {
        await _deleteQuietly(output);
        throw AudioExtractionException('unreadable ffmpeg output: $e');
      }
    } finally {
      _running = null;
    }
  }

  @override
  Future<void> cancel() async {
    final id = _running?.getSessionId();
    if (id != null) await FFmpegKit.cancel(id);
  }

  @override
  Future<void> deleteLeftovers() async {
    try {
      final dir = await _outputDirectory();
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        if (entity is File && p.basename(entity.path).startsWith(_filePrefix)) {
          await _deleteQuietly(entity.path);
        }
      }
    } on FileSystemException catch (e) {
      debugPrint('Could not clean up extracted audio: $e');
    }
  }

  /// Under Caches rather than tmp: Caches is left out of backups, which
  /// matters for a file of a few hundred MB.
  static Future<Directory> defaultOutputDirectory() async =>
      Directory(p.join((await getApplicationCacheDirectory()).path, 'extracted_audio'));

  /// A unique name, so leftover runs never collide.
  Future<String> _newOutputPath() async {
    // FFmpeg will not create the folder itself.
    final dir = await (await _outputDirectory()).create(recursive: true);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return p.join(dir.path, '$_filePrefix$stamp.wav');
  }

  static String _lastLogLine(String? logs) {
    final lines = (logs ?? '')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);
    return lines.isEmpty ? '' : lines.last;
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (e) {
      debugPrint('Could not delete $path: $e');
    }
  }
}
