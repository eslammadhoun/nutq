import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/models/job_detail_response.dart';
import 'package:nutq/features/jobs/data/models/job_list_response.dart';
import 'package:nutq/features/jobs/data/models/job_response.dart';
import 'package:nutq/features/jobs/data/models/submit_job_request.dart';
import 'package:nutq/features/jobs/data/models/upload_file.dart';

abstract interface class JobsRepository {
  Future<ApiResult<JobListResponse>> listJobs({String? cursor, int limit});
  Future<ApiResult<JobResponse>> submitJob(SubmitJobRequest request);
  Future<ApiResult<JobDetailResponse>> getJob(String jobId);
  Future<ApiResult<JobResponse>> cancelJob(String jobId);
  Future<ApiResult<JobResponse>> confirmUpload(String jobId);
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file);
}
