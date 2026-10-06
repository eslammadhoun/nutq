import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

/// The audio and video files a job can be made from.
abstract interface class MediaFiles {
  /// Lets the user choose a file of [type] (audio or video). Null when they
  /// back out. The returned path is a temporary copy owned by the picker.
  Future<UploadFile?> pick(JobSourceType type);

  /// Moves a picked file into app storage, where it stays until its job is
  /// deleted. Returns the new path. Throws `FileSystemException` on failure.
  Future<String> import(UploadFile file);

  /// Bytes the imported media files take, for the Settings storage line.
  Future<int> storageBytes();
}
