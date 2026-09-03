import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_api_service.dart';
import 'package:nutq/features/jobs/data/mappers/job_mappers.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(this._dataSource);

  final JobsDataSource _dataSource;

  @override
  Future<ApiResult<JobsPage>> listJobs({String? cursor, int limit = 20}) async {
    final result = await _dataSource.listJobs(cursor: cursor, limit: limit);
    return result.mapSuccess((page) => page.toEntity());
  }

  @override
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params) async {
    final result = await _dataSource.submitJob(params.toRequest());
    return result.mapSuccess((job) => job.toEntity());
  }

  @override
  Future<ApiResult<JobDetailEntity>> getJob(String jobId) async {
    final result = await _dataSource.getJob(jobId);
    return result.mapSuccess((job) => job.toEntity());
  }

  @override
  Future<ApiResult<JobEntity>> cancelJob(String jobId) async {
    final result = await _dataSource.cancelJob(jobId);
    return result.mapSuccess((job) => job.toEntity());
  }

  @override
  Future<ApiResult<JobEntity>> confirmUpload(String jobId) async {
    final result = await _dataSource.confirmUpload(jobId);
    return result.mapSuccess((job) => job.toEntity());
  }

  @override
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file) {
    return _dataSource.uploadToSlot(uploadUrl, file);
  }

  @override
  Future<ApiResult<void>> deleteJob(String jobId) async {
    return _dataSource.deleteJob(jobId);
  }
}
