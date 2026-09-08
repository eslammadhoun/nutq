import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/mappers/job_mappers.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(this._dataSource);

  final JobsDataSource _dataSource;

  @override
  Future<ApiResult<JobsPage>> listJobs({String? cursor, int limit = 20}) async {
    final result = await _dataSource.listJobs(cursor: cursor, limit: limit);
    return result.mapSuccess(
      (page) => JobsPage(
        items: page.items.map((row) => row.toEntity()).toList(),
        nextCursor: page.hasMore && page.items.isNotEmpty
            ? _cursorFor(page.items.last)
            : null,
      ),
    );
  }

  String _cursorFor(JobRow lastRow) =>
      '${lastRow.createdAt.millisecondsSinceEpoch}_${lastRow.id}';

  @override
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params) async {
    final result = await _dataSource.submitJob(params);
    return result.mapSuccess((job) => job.toEntity());
  }

  @override
  Future<ApiResult<JobDetailEntity>> getJob(String jobId) async {
    final result = await _dataSource.getJob(jobId);
    return result.mapSuccess((detail) => detail.toEntity());
  }

  @override
  Future<ApiResult<JobEntity>> cancelJob(String jobId) async {
    final result = await _dataSource.cancelJob(jobId);
    return result.mapSuccess((job) => job.toEntity());
  }

  @override
  Future<ApiResult<void>> deleteJob(String jobId) async {
    return _dataSource.deleteJob(jobId);
  }

  @override
  Future<ApiResult<String>> fetchTranscriptText(String jobId) {
    return _dataSource.fetchTranscriptText(jobId);
  }
}
