import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';

abstract interface class JobsRepository {
  Future<ApiResult<JobListResponseModel>> getJobs({
    String? cursor,
    int limit = 20,
  });

  Future<ApiResult<JobModel>> submitTextJob({
    required String text,
    String language = 'ar',
  });

  Future<ApiResult<JobModel>> cancelJob(String jobId);
}
