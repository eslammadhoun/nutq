import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_api_service.dart';
import 'package:nutq/features/jobs/data/models/job_detail_response.dart';
import 'package:nutq/features/jobs/data/models/job_list_response.dart';
import 'package:nutq/features/jobs/data/models/job_response.dart';
import 'package:nutq/features/jobs/data/models/submit_job_request.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(this._dataSource);

  final JobsDataSource _dataSource;

  @override
  Future<ApiResult<JobListResponse>> listJobs({String? cursor, int limit = 20}) {
    return _dataSource.listJobs(cursor: cursor, limit: limit);
  }

  @override
  Future<ApiResult<JobResponse>> submitJob(SubmitJobRequest request) {
    return _dataSource.submitJob(request);
  }

  @override
  Future<ApiResult<JobDetailResponse>> getJob(String jobId) {
    return _dataSource.getJob(jobId);
  }

  @override
  Future<ApiResult<JobResponse>> cancelJob(String jobId) {
    return _dataSource.cancelJob(jobId);
  }
}
