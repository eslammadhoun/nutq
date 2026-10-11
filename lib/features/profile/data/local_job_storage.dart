import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/repositories/media_files.dart';
import 'package:nutq/features/jobs/domain/usecases/delete_job.dart';
import 'package:nutq/features/profile/domain/job_storage.dart';

class LocalJobStorage implements JobStorage {
  const LocalJobStorage({
    required this._jobs,
    required this._media,
    required this._deleteJob,
  });

  final JobsRepository _jobs;
  final MediaFiles _media;
  final DeleteJob _deleteJob;

  /// Every job, whatever the list's paging.
  static const _all = JobsQuery(limit: 1 << 30);

  @override
  Future<StorageUsage> usage() async => StorageUsage(
    jobs: (await _jobs.watchJobs(_all).first).length,
    mediaBytes: await _media.storageBytes(),
  );

  @override
  Future<void> deleteAllJobs() async {
    for (final job in await _jobs.watchJobs(_all).first) {
      await _deleteJob(job.id);
    }
  }
}
