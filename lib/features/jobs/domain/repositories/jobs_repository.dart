import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';

abstract interface class JobsRepository {
  Future<ApiResult<JobsPage>> listJobs({String? cursor, int limit});
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params);
  Future<ApiResult<JobDetailEntity>> getJob(String jobId);
  Future<ApiResult<JobEntity>> cancelJob(String jobId);
  Future<ApiResult<JobEntity>> confirmUpload(String jobId);
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file);
  Future<ApiResult<void>> deleteJob(String jobId);
}
