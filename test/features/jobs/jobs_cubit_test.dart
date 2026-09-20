import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/entities/validation_report.dart';

import 'support/job_harness.dart';

void main() {
  late JobHarness h;
  late JobsCubit cubit;

  setUp(() {
    h = JobHarness();
    cubit = h.jobsCubit();
  });
  tearDown(() async {
    await cubit.close();
    await h.dispose();
  });

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 60));

  test('starts empty, loads the stored jobs newest first, and stops showing a spinner', () async {
    await h.createJob('first');
    await h.createJob('second');
    expect(cubit.state.status, JobsStatus.initial);

    await cubit.fetchJobs();
    expect(cubit.state.status, JobsStatus.success);
    expect(cubit.state.jobs.map((j) => j.preview), ['second', 'first']);
    expect(cubit.state.hasMore, isFalse);
  });

  test('an empty database is a successful, empty list', () async {
    await cubit.fetchJobs();
    expect(cubit.state.status, JobsStatus.success);
    expect(cubit.state.jobs, isEmpty);
  });

  test('the list is live: new, finished and deleted jobs appear without refreshing', () async {
    await cubit.fetchJobs();
    final id = await h.createJob('نص');
    await settle();
    expect(cubit.state.jobs.single.status, JobRunStatus.pending);

    await h.repo.markRunning(id);
    await settle();
    expect(cubit.state.jobs.single.status, JobRunStatus.running);

    await h.repo.cancelJob(id);
    await settle();
    expect(cubit.state.jobs.single.status, JobRunStatus.cancelled);

    await h.repo.deleteJob(id);
    await settle();
    expect(cubit.state.jobs, isEmpty);
  });

  test('view models carry the preview, language and failure reason', () async {
    final id = await h.createJob('مرحبا بكم');
    await h.repo.failJob(id, JobFailureKind.modelUnavailable);
    await cubit.fetchJobs();
    final job = cubit.state.jobs.single;
    expect(job.preview, 'مرحبا بكم');
    expect(job.language.code, 'ar');
    expect(job.status, JobRunStatus.failed);
    expect(job.failureKind, JobFailureKind.modelUnavailable);
  });

  group('filter', () {
    setUp(() async {
      final done = await h.createJob('done job');
      await h.repo.markRunning(done);
      await h.repo.completeJob(done, _summaryResult());
      final failed = await h.createJob('failed job');
      await h.repo.failJob(failed, JobFailureKind.generationFailed);
      await h.createJob('queued job');
      await cubit.fetchJobs();
    });

    test('each chip maps to the stored states it stands for', () async {
      Future<List<String?>> previewsFor(JobRunStatus? filter) async {
        cubit.selectFilter(filter);
        await settle();
        return cubit.state.jobs.map((j) => j.preview).toList();
      }

      expect(await previewsFor(JobRunStatus.completed), ['done job']);
      expect(await previewsFor(JobRunStatus.failed), ['failed job']);
      expect(await previewsFor(JobRunStatus.pending), ['queued job']);
      expect(await previewsFor(JobRunStatus.running), isEmpty);
      expect(await previewsFor(null), hasLength(3));
      expect(cubit.state.selectedFilter, isNull);
    });
  });

  group('search', () {
    test('applies after the debounce, and only the last keystroke runs', () async {
      await h.createJob('ميزانية المشروع');
      await h.createJob('خطة التسويق');
      await cubit.fetchJobs();

      cubit.search('م');
      cubit.search('ميز');
      cubit.search('ميزانية');
      expect(cubit.state.searchQuery, 'ميزانية', reason: 'the field text is updated immediately');
      expect(cubit.state.jobs, hasLength(2), reason: 'but the query has not run yet');

      await settle();
      expect(cubit.state.jobs.map((j) => j.preview), ['ميزانية المشروع']);

      cubit.search('');
      await settle();
      expect(cubit.state.jobs, hasLength(2));
    });

    test('searches the full transcript, not just the preview', () async {
      final tail = '${List.filled(60, 'كلمة').join(' ')} عبارة فريدة في النهاية';
      await h.createJob(tail);
      await h.createJob('آخر');
      await cubit.fetchJobs();
      cubit.search('فريدة');
      await settle();
      expect(cubit.state.jobs, hasLength(1));
    });

    test('search combines with the filter', () async {
      final a = await h.createJob('ميزانية أ');
      await h.repo.failJob(a, JobFailureKind.generationFailed);
      await h.createJob('ميزانية ب');
      await cubit.fetchJobs();
      cubit.selectFilter(JobRunStatus.failed);
      cubit.search('ميزانية');
      await settle();
      expect(cubit.state.jobs.map((j) => j.preview), ['ميزانية أ']);
    });
  });

  group('paging', () {
    test('loads a page at a time and reports when there is more', () async {
      for (var i = 0; i < JobsQuery.defaultLimit + 5; i++) {
        await h.createJob('job $i');
      }
      await cubit.fetchJobs();
      expect(cubit.state.jobs, hasLength(JobsQuery.defaultLimit));
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      expect(cubit.state.jobs, hasLength(JobsQuery.defaultLimit + 5));
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.isLoadingMore, isFalse);
    });

    test('loadMore does nothing when everything is loaded', () async {
      await h.createJob('only');
      await cubit.fetchJobs();
      await cubit.loadMore();
      expect(cubit.state.jobs, hasLength(1));
    });

    test('changing the filter starts again from the first page', () async {
      for (var i = 0; i < JobsQuery.defaultLimit + 5; i++) {
        await h.createJob('job $i');
      }
      await cubit.fetchJobs();
      await cubit.loadMore();
      cubit.selectFilter(JobRunStatus.pending);
      await settle();
      expect(cubit.state.jobs, hasLength(JobsQuery.defaultLimit));
      expect(cubit.state.hasMore, isTrue);
    });
  });

  group('delete', () {
    test('removes the row at once and from the database', () async {
      final a = await h.createJob('a');
      await h.createJob('b');
      await cubit.fetchJobs();

      final future = cubit.deleteJob(a);
      expect(cubit.state.jobs.map((j) => j.id).contains(a), isFalse, reason: 'optimistic removal, before the write finishes');
      await future;
      await settle();
      expect(cubit.state.jobs, hasLength(1));
      expect(await h.repo.getJob(a), isNull);
      expect(cubit.state.deleteError, isNull);
    });

    test('a failed delete restores the row and signals the error once', () async {
      final repo = JobsRepositoryImpl(_FailingDeleteDataSource(JobsLocalDataSourceImpl(h.db.jobsDao)), newId: () => 'x');
      final flaky = JobsCubit(repo, searchDebounce: const Duration(milliseconds: 20));
      addTearDown(flaky.close);
      final id = await h.createJob('keep me');
      await flaky.fetchJobs();

      await flaky.deleteJob(id);
      await settle();
      expect(flaky.state.jobs.map((j) => j.id), [id], reason: 'the row is back');
      expect(flaky.state.deleteError, AppError.storage);
      expect(flaky.state.deleteErrorToken, 1);

      await flaky.deleteJob(id);
      await settle();
      expect(flaky.state.deleteErrorToken, 2, reason: 'a repeat failure re-signals');
    });
  });

  test('a failing query reports a storage error', () async {
    final repo = JobsRepositoryImpl(_FailingWatchDataSource(JobsLocalDataSourceImpl(h.db.jobsDao)), newId: () => 'x');
    final failing = JobsCubit(repo);
    addTearDown(failing.close);
    await failing.fetchJobs();
    expect(failing.state.status, JobsStatus.failure);
    expect(failing.state.lastError, AppError.storage);
    expect(failing.state.jobs, isEmpty);
  });

  test('refresh re-runs the query and keeps the data', () async {
    await h.createJob('a');
    await cubit.fetchJobs();
    await cubit.refresh();
    expect(cubit.state.jobs, hasLength(1));
    expect(cubit.state.status, JobsStatus.success);
  });

  test('closing stops listening to the database', () async {
    await cubit.fetchJobs();
    await cubit.close();
    await h.createJob('after close');
    await settle(); // must not throw (emit after close)
  });
}

class _FailingDeleteDataSource implements JobsLocalDataSource {
  _FailingDeleteDataSource(this._inner);

  final JobsLocalDataSource _inner;

  @override
  Future<void> deleteJob(String id) => Future.error(StateError('disk full'));

  @override
  Stream<List<JobEntity>> watchJobs(JobsQuery query) => _inner.watchJobs(query);

  @override
  Stream<JobDetailEntity?> watchJob(String id) => _inner.watchJob(id);

  @override
  Future<JobDetailEntity?> getJob(String id) => _inner.getJob(id);

  @override
  Future<void> insertJob(JobDetailEntity job) => _inner.insertJob(job);

  @override
  Future<TransitionOutcome> transition(String id, {required Set<JobRunStatus> from, required JobRunStatus to, required DateTime at, JobFailureKind? failureKind}) =>
      _inner.transition(id, from: from, to: to, at: at, failureKind: failureKind);

  @override
  Future<TransitionOutcome> completeJob(String id, Summary summary, DateTime at) => _inner.completeJob(id, summary, at);

  @override
  Future<int> failActiveJobs(JobFailureKind kind, DateTime at) => _inner.failActiveJobs(kind, at);
}

SummaryResult _summaryResult() => const SummaryResult(
  summary: 'ملخص',
  validation: ValidationReport(),
  debug: SummaryDebugInfo(jobId: 'x', chunkCount: 1, failedChunkCount: 0, processingTimeMs: 1),
);

class _FailingWatchDataSource extends _FailingDeleteDataSource {
  _FailingWatchDataSource(super.inner);

  @override
  Stream<List<JobEntity>> watchJobs(JobsQuery query) => Stream.error(StateError('no such table'));
}
