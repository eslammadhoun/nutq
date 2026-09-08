import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';

abstract interface class JobsRepository {
  Future<ApiResult<JobsPage>> listJobs({String? cursor, int limit});

  /// Persists a new job locally. For `sourceType: upload`, [params.file]'s
  /// local (picker-cache) path is copied into permanent app storage before
  /// the row is written — no separate upload-slot/confirm step, since
  /// there's no backend to stage the file with.
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params);
  Future<ApiResult<JobDetailEntity>> getJob(String jobId);
  Future<ApiResult<JobEntity>> cancelJob(String jobId);
  Future<ApiResult<void>> deleteJob(String jobId);
  Future<ApiResult<String>> fetchTranscriptText(String jobId);
}
