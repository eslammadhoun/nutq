import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';

/// Deletes a job with its transcript, summary and media file. A queued or
/// running job is stopped first: otherwise the queue would keep working on it
/// to the end, and jobs submitted after it would wait for nothing.
class DeleteJob {
  const DeleteJob(this._jobs, this._scheduler);

  final JobsRepository _jobs;
  final JobScheduler _scheduler;

  Future<void> call(String id) async {
    // A no-op for a job that is neither queued nor running.
    await _scheduler.cancel(id);
    await _jobs.deleteJob(id);
  }
}
