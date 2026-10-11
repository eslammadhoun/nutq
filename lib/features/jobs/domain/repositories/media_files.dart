import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

/// The audio and video files a job can be made from.
abstract interface class MediaFiles {
  /// Lets the user choose a file of [type] (audio or video). Null when they
  /// back out. The returned path is a temporary copy owned by the picker.
  Future<UploadFile?> pick(JobSourceType type);

  /// Moves a picked file into app storage, where it stays until its job
  /// finishes or is deleted. Returns the new path. Throws `FileSystemException` on failure.
  Future<String> import(UploadFile file);

  /// Bytes the imported media files take, for the Settings storage line.
  Future<int> storageBytes();

  /// Deletes every imported file except those named in [keep], sparing files
  /// last changed at or after [modifiedBefore] (one being submitted right
  /// now). Files are matched by name, not full path: iOS moves the app's
  /// container when the app is updated, so a stored path can point at the old
  /// place while the file lives on in the new one.
  Future<void> deleteAllExcept(Set<String> keep, {required DateTime modifiedBefore});
}
