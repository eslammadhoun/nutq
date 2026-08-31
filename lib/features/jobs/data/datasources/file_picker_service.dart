import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:nutq/features/jobs/data/models/upload_file.dart';

enum PickableMedia { audio, video }

abstract interface class FilePickerService {
  /// Returns null when the user cancels the system picker.
  Future<UploadFile?> pick({required PickableMedia media});
}

class FilePickerServiceImpl implements FilePickerService {
  static const Map<String, String> _audioMime = {
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'flac': 'audio/flac',
    'm4a': 'audio/x-m4a',
    'aac': 'audio/mp4',
    'ogg': 'audio/ogg',
    'oga': 'audio/ogg',
    'weba': 'audio/webm',
  };

  static const Map<String, String> _videoMime = {
    'mp4': 'video/mp4',
    'm4v': 'video/mp4',
    'webm': 'video/webm',
    'mov': 'video/quicktime',
  };

  @override
  Future<UploadFile?> pick({required PickableMedia media}) async {
    final file = await FilePicker.pickFile(
      type: media == PickableMedia.audio ? FileType.audio : FileType.video,
    );
    final path = file?.path;
    if (file == null || path == null) return null;

    final extension = file.extension?.toLowerCase();
    final mimeTable = media == PickableMedia.audio ? _audioMime : _videoMime;
    final contentType = mimeTable[extension] ??
        (media == PickableMedia.audio ? 'audio/mpeg' : 'video/mp4');

    return UploadFile(
      name: file.name,
      path: path,
      sizeBytes: File(path).lengthSync(),
      contentType: contentType,
    );
  }
}
