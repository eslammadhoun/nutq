import 'package:flutter/foundation.dart';

/// What the jobs take on this phone.
@immutable
class StorageUsage {
  const StorageUsage({required this.jobs, required this.mediaBytes});

  final int jobs;

  /// The audio and video files jobs were made from.
  final int mediaBytes;
}

abstract interface class JobStorage {
  Future<StorageUsage> usage();

  /// Stops a running job, then deletes every job with its transcript, summary
  /// and media file.
  Future<void> deleteAllJobs();
}
