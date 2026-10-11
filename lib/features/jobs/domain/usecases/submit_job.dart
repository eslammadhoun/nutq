import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';

/// Saves a new job and queues it for processing. The job exists in storage
/// before anything runs, so an interruption never loses it.
class SubmitJob {
  const SubmitJob(this._jobs, this._scheduler);

  final JobsRepository _jobs;
  final JobScheduler _scheduler;

  Future<JobDetailEntity> call(NewJobDraft draft) async {
    final job = await _jobs.createJob(draft);
    _scheduler.enqueue(job.id);
    return job;
  }
}
