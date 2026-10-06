import 'dart:io';

import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/media_files.dart';

/// A picker that returns whatever the test sets in [next], and an import that
/// records the file and hands back an app-storage path.
class FakeMediaFiles implements MediaFiles {
  UploadFile? next;

  /// Thrown from [pick] or [import] when set.
  Object? pickError;
  Object? importError;

  final picks = <JobSourceType>[];
  final imported = <UploadFile>[];

  static String importedPath(UploadFile file) => '/app/job_media/${file.name}';

  @override
  Future<UploadFile?> pick(JobSourceType type) async {
    picks.add(type);
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (pickError != null) throw pickError!;
    return next;
  }

  /// What [storageBytes] reports.
  int bytes = 0;

  @override
  Future<int> storageBytes() async => bytes;

  @override
  Future<String> import(UploadFile file) async {
    if (importError != null) throw const FileSystemException('disk full');
    imported.add(file);
    return importedPath(file);
  }
}
