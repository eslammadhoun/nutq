import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

class MockJobsRepository extends Mock implements JobsRepository {}

void main() {
  late MockJobsRepository repository;

  setUp(() {
    repository = MockJobsRepository();
  });

  JobModel buildJob({String id = '1'}) => JobModel(
    id: id,
    status: 'pending',
    sourceType: 'text',
    language: 'ar',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  group('loadJobs', () {
    blocTest<JobsCubit, JobsState>(
      'emits [loading, loaded] on success',
      build: () => JobsCubit(repository),
      setUp: () {
        when(() => repository.getJobs()).thenAnswer(
          (_) async => ApiResult.success(
            JobListResponseModel(items: [buildJob()], nextCursor: 'c2'),
          ),
        );
      },
      act: (cubit) => cubit.loadJobs(),
      expect: () => [
        const JobsLoading(),
        JobsLoaded(jobs: [buildJob()], nextCursor: 'c2'),
      ],
    );

    blocTest<JobsCubit, JobsState>(
      'emits [loading, error] on failure',
      build: () => JobsCubit(repository),
      setUp: () {
        when(
          () => repository.getJobs(),
        ).thenAnswer((_) async => const ApiResult.failure('Server error'));
      },
      act: (cubit) => cubit.loadJobs(),
      expect: () => [const JobsLoading(), const JobsError('Server error')],
    );
  });

  group('loadMore', () {
    blocTest<JobsCubit, JobsState>(
      'appends the next page and updates the cursor',
      build: () => JobsCubit(repository),
      seed: () => JobsLoaded(jobs: [buildJob(id: '1')], nextCursor: 'c2'),
      setUp: () {
        when(() => repository.getJobs(cursor: 'c2')).thenAnswer(
          (_) async => ApiResult.success(
            JobListResponseModel(items: [buildJob(id: '2')], nextCursor: null),
          ),
        );
      },
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        JobsLoaded(
          jobs: [buildJob(id: '1')],
          nextCursor: 'c2',
          isLoadingMore: true,
        ),
        JobsLoaded(
          jobs: [buildJob(id: '1'), buildJob(id: '2')],
          nextCursor: null,
        ),
      ],
    );

    blocTest<JobsCubit, JobsState>(
      'does nothing when there is no next cursor',
      build: () => JobsCubit(repository),
      seed: () => JobsLoaded(jobs: [buildJob()], nextCursor: null),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
      verify: (_) => verifyNever(() => repository.getJobs(cursor: any(named: 'cursor'))),
    );
  });

  group('submitTextJob', () {
    blocTest<JobsCubit, JobsState>(
      'prepends the created job on success',
      build: () => JobsCubit(repository),
      seed: () => JobsLoaded(jobs: [buildJob(id: '1')], nextCursor: null),
      setUp: () {
        when(() => repository.submitTextJob(text: 'hello')).thenAnswer(
          (_) async => ApiResult.success(buildJob(id: 'new')),
        );
      },
      act: (cubit) => cubit.submitTextJob('hello'),
      expect: () => [
        JobsLoaded(
          jobs: [buildJob(id: '1')],
          nextCursor: null,
          isSubmitting: true,
        ),
        JobsLoaded(
          jobs: [buildJob(id: 'new'), buildJob(id: '1')],
          nextCursor: null,
        ),
      ],
    );

    blocTest<JobsCubit, JobsState>(
      'surfaces the error via actionError on failure',
      build: () => JobsCubit(repository),
      seed: () => JobsLoaded(jobs: const [], nextCursor: null),
      setUp: () {
        when(() => repository.submitTextJob(text: 'hello')).thenAnswer(
          (_) async => const ApiResult.failure('text is required'),
        );
      },
      act: (cubit) => cubit.submitTextJob('hello'),
      expect: () => [
        const JobsLoaded(jobs: [], nextCursor: null, isSubmitting: true),
        const JobsLoaded(
          jobs: [],
          nextCursor: null,
          actionError: 'text is required',
        ),
      ],
    );
  });
}
