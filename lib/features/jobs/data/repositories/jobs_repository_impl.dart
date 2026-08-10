import 'package:uuid/uuid.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/core/network/error_handler.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_api_service.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(this._api, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final JobsApiService _api;
  final Uuid _uuid;

  @override
  Future<ApiResult<JobListResponseModel>> getJobs({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final result = await _api.listJobs(cursor: cursor, limit: limit);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(
        ErrorHandler.handle(e),
        statusCode: ErrorHandler.statusCode(e),
      );
    }
  }

  @override
  Future<ApiResult<JobModel>> submitTextJob({
    required String text,
    String language = 'ar',
  }) async {
    try {
      final result = await _api.submitJob(
        SubmitJobRequestModel(
          sourceType: 'text',
          language: language,
          text: text,
          idempotencyKey: _uuid.v4(),
        ),
      );
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(
        ErrorHandler.handle(e),
        statusCode: ErrorHandler.statusCode(e),
      );
    }
  }

  @override
  Future<ApiResult<JobModel>> cancelJob(String jobId) async {
    try {
      final result = await _api.cancelJob(jobId);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(
        ErrorHandler.handle(e),
        statusCode: ErrorHandler.statusCode(e),
      );
    }
  }
}
