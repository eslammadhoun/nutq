import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

JobEntity _job(String id, {String status = 'done'}) => JobEntity(
  id: id,
  status: status,
  sourceType: 'text',
  language: 'ar',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

class _FakeJobsRepository implements JobsRepository {
  _FakeJobsRepository(this._pages);

  /// Consumed in order — one result per listJobs call.
  final List<ApiResult<JobsPage>> _pages;
  final List<String?> requestedCursors = [];

  @override
  Future<ApiResult<JobsPage>> listJobs({String? cursor, int limit = 20}) async {
    requestedCursors.add(cursor);
    return _pages.removeAt(0);
  }

  @override
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobDetailEntity>> getJob(String jobId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> cancelJob(String jobId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> confirmUpload(String jobId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file) =>
      throw UnimplementedError();
}

void main() {
  group('JobsCubit', () {
    test('fetchJobs success emits loading then success with mapped jobs', () async {
      final repo = _FakeJobsRepository([
        ApiResult.success(
          JobsPage(items: [_job('a'), _job('b')], nextCursor: 'cur-1'),
        ),
      ]);
      final cubit = JobsCubit(repo: repo);
      final statuses = <JobsStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.fetchJobs();
      // Broadcast stream delivery is async — flush the microtask queue.
      await Future<void>.delayed(Duration.zero);

      expect(statuses, [JobsStatus.loading, JobsStatus.success]);
      expect(cubit.state.allJobs.map((j) => j.id), ['a', 'b']);
      expect(cubit.state.hasMore, isTrue);
      await sub.cancel();
      await cubit.close();
    });

    test('fetchJobs failure emits failure carrying the raw ApiError', () async {
      final repo = _FakeJobsRepository([
        const ApiResult.failure(ApiError.network()),
      ]);
      final cubit = JobsCubit(repo: repo);

      await cubit.fetchJobs();

      expect(cubit.state.status, JobsStatus.failure);
      expect(cubit.state.lastError, const ApiError.network());
      await cubit.close();
    });

    test('loadMore appends the next page using the stored cursor', () async {
      final repo = _FakeJobsRepository([
        ApiResult.success(
          JobsPage(items: [_job('a')], nextCursor: 'cur-1'),
        ),
        ApiResult.success(
          JobsPage(items: [_job('b')], nextCursor: null),
        ),
      ]);
      final cubit = JobsCubit(repo: repo);

      await cubit.fetchJobs();
      await cubit.loadMore();

      expect(repo.requestedCursors, [null, 'cur-1']);
      expect(cubit.state.allJobs.map((j) => j.id), ['a', 'b']);
      expect(cubit.state.hasMore, isFalse);
      await cubit.close();
    });

    test('loadMore does nothing when there is no next cursor', () async {
      final repo = _FakeJobsRepository([
        ApiResult.success(JobsPage(items: [_job('a')], nextCursor: null)),
      ]);
      final cubit = JobsCubit(repo: repo);

      await cubit.fetchJobs();
      await cubit.loadMore();

      expect(repo.requestedCursors, [null]);
      await cubit.close();
    });

    test('selectFilter and search narrow filteredJobs', () async {
      final repo = _FakeJobsRepository([
        ApiResult.success(
          JobsPage(
            items: [_job('aaaa1111'), _job('bbbb2222', status: 'failed')],
            nextCursor: null,
          ),
        ),
      ]);
      final cubit = JobsCubit(repo: repo);
      await cubit.fetchJobs();

      cubit.selectFilter(JobStatus.failed);
      expect(cubit.state.filteredJobs.map((j) => j.id), ['bbbb2222']);

      cubit.selectFilter(null);
      cubit.search('aaaa');
      expect(cubit.state.filteredJobs.map((j) => j.id), ['aaaa1111']);
      await cubit.close();
    });
  });
}
