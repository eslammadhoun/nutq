import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/media_files.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Picks files with the system document picker and keeps job media under
/// Application Support, which the OS never purges.
class PlatformMediaFiles implements MediaFiles {
  PlatformMediaFiles({required this._newId, Future<Directory> Function()? storage})
    : _storage = storage ?? defaultStorage;

  final String Function() _newId;
  final Future<Directory> Function() _storage;

  /// Formats FFmpeg decodes that people are likely to have on a phone, by
  /// extension, with the MIME type stored with the job.
  static const audioTypes = {
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'wav': 'audio/wav',
    'flac': 'audio/flac',
    'ogg': 'audio/ogg',
    'opus': 'audio/opus',
    'amr': 'audio/amr',
    'aiff': 'audio/aiff',
    'caf': 'audio/x-caf',
  };
  static const videoTypes = {
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'm4v': 'video/x-m4v',
    'mkv': 'video/x-matroska',
    'webm': 'video/webm',
    'avi': 'video/x-msvideo',
    '3gp': 'video/3gpp',
  };

  static Future<Directory> defaultStorage() async =>
      Directory(p.join((await getApplicationSupportDirectory()).path, 'job_media'));

  @override
  Future<UploadFile?> pick(JobSourceType type) async {
    final types = type == JobSourceType.audio ? audioTypes : videoTypes;
    // Copies from earlier picks that were never submitted.
    await FilePicker.clearTemporaryFiles();
    // Android filters by MIME type, which it guesses wrongly from some
    // extensions (m4a as audio/mpeg, hiding every .m4a file), so there the
    // picker offers all audio or video. Media FFmpeg cannot read fails the job
    // as unsupported.
    final file = Platform.isAndroid
        ? await FilePicker.pickFile(
            type: type == JobSourceType.audio ? FileType.audio : FileType.video,
          )
        : await FilePicker.pickFile(
            type: FileType.custom,
            allowedExtensions: types.keys.toList(),
          );
    final path = file?.path;
    if (file == null || path == null) return null;
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    return UploadFile(
      name: file.name,
      path: path,
      sizeBytes: await File(path).length(),
      contentType: types[extension] ?? 'application/octet-stream',
    );
  }

  @override
  Future<int> storageBytes() async {
    final dir = await _storage();
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  @override
  Future<String> import(UploadFile file) async {
    final dir = await (await _storage()).create(recursive: true);
    final target = p.join(dir.path, '${_newId()}${p.extension(file.path).toLowerCase()}');
    final source = File(file.path);
    try {
      // The picker's copy is ours to take, so a rename avoids copying a large
      // video a second time.
      await source.rename(target);
    } on FileSystemException {
      await source.copy(target);
      await source.delete();
    }
    return target;
  }
}
