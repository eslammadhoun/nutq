import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_api_service.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';

class MockJobsApiService extends Mock implements JobsApiService {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late MockJobsApiService api;
  late MockUuid uuid;
  late JobsRepositoryImpl repository;

  setUp(() {
    api = MockJobsApiService();
    uuid = MockUuid();
    repository = JobsRepositoryImpl(api, uuid: uuid);

    registerFallbackValue(const SubmitJobRequestModel(sourceType: 'text'));
    when(() => uuid.v4()).thenReturn('fixed-idempotency-key');
  });

  JobModel buildJob({String id = '1', String status = 'pending'}) => JobModel(
    id: id,
    status: status,
    sourceType: 'text',
    language: 'ar',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  group('getJobs', () {
    test('returns success with the listed page', () async {
      final page = JobListResponseModel(
        items: [buildJob()],
        nextCursor: 'next-page',
      );
      when(
        () => api.listJobs(cursor: null, limit: 20),
      ).thenAnswer((_) async => page);

      final result = await repository.getJobs();

      expect(result, ApiResult<JobListResponseModel>.success(page));
    });

    test('forwards the cursor for subsequent pages', () async {
      final page = JobListResponseModel(items: [], nextCursor: null);
      when(
        () => api.listJobs(cursor: 'next-page', limit: 20),
      ).thenAnswer((_) async => page);

      await repository.getJobs(cursor: 'next-page');

      verify(() => api.listJobs(cursor: 'next-page', limit: 20)).called(1);
    });

    test('returns failure with the mapped message on a DioException', () async {
      when(() => api.listJobs(cursor: null, limit: 20)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/jobs'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getJobs();

      expect(
        result,
        const ApiResult<JobListResponseModel>.failure(
          'No internet connection.',
        ),
      );
    });
  });

  group('submitTextJob', () {
    test('submits a text job with a generated idempotency key', () async {
      final job = buildJob();
      when(() => api.submitJob(any())).thenAnswer((_) async => job);

      final result = await repository.submitTextJob(text: 'hello world');

      expect(result, ApiResult<JobModel>.success(job));
      final captured = verify(() => api.submitJob(captureAny())).captured;
      final body = captured.single as SubmitJobRequestModel;
      expect(body.sourceType, 'text');
      expect(body.text, 'hello world');
      expect(body.idempotencyKey, 'fixed-idempotency-key');
    });

    test('returns failure with the mapped message on a DioException', () async {
      when(() => api.submitJob(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/jobs'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/jobs'),
            statusCode: 422,
            data: {'detail': 'text is required'},
          ),
        ),
      );

      final result = await repository.submitTextJob(text: '');

      expect(
        result,
        const ApiResult<JobModel>.failure(
          'text is required',
          statusCode: 422,
        ),
      );
    });
  });

  group('cancelJob', () {
    test('returns success with the cancelled job', () async {
      final job = buildJob(status: 'cancelled');
      when(() => api.cancelJob('1')).thenAnswer((_) async => job);

      final result = await repository.cancelJob('1');

      expect(result, ApiResult<JobModel>.success(job));
    });
  });
}
