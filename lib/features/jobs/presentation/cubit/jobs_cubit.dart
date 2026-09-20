import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';

/// The jobs list. The database is the source of truth: the cubit subscribes to
/// a live query, so jobs created, finished or deleted anywhere appear here
/// without a manual refresh. Filtering, searching and paging are done by the
/// query, not in memory.
class JobsCubit extends Cubit<JobsState> {
  JobsCubit(
    this._repository, {
    this.searchDebounce = const Duration(milliseconds: 300),
  }) : super(const JobsState());

  final JobsRepository _repository;
  final Duration searchDebounce;

  static const _pageSize = JobsQuery.defaultLimit;

  StreamSubscription<List<JobEntity>>? _subscription;
  Timer? _searchTimer;
  int _limit = _pageSize;
  String _appliedSearch = '';

  JobsQuery get _query => JobsQuery(
    statuses: state.selectedFilter == null ? null : {state.selectedFilter!},
    text: _appliedSearch,
    limit: _limit,
  );

  /// Starts (or restarts) the live query. Completes once the first result — or
  /// an error — has arrived.
  Future<void> fetchJobs() {
    if (state.jobs.isEmpty) emit(state.copyWith(status: JobsStatus.loading));
    return _subscribe();
  }

  /// Pull-to-refresh. The query is live already, so this only re-runs it.
  Future<void> refresh() => _subscribe();

  Future<void> loadMore() {
    if (!state.hasMore || state.isLoadingMore) return Future.value();
    emit(state.copyWith(isLoadingMore: true));
    _limit += _pageSize;
    return _subscribe();
  }

  void selectFilter(JobRunStatus? status) {
    emit(
      status == null ? state.copyWith(clearFilter: true) : state.copyWith(selectedFilter: status),
    );
    _limit = _pageSize;
    unawaited(_subscribe());
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () {
      if (isClosed || query == _appliedSearch) return;
      _appliedSearch = query;
      _limit = _pageSize;
      unawaited(_subscribe());
    });
  }

  /// Removes the row immediately (the swipe gesture already animated it away),
  /// then deletes it. If that fails the query is re-run, which brings the row
  /// back, and the error is surfaced once.
  Future<void> deleteJob(String jobId) async {
    emit(
      state.copyWith(
        jobs: [
          for (final j in state.jobs)
            if (j.id != jobId) j,
        ],
      ),
    );
    try {
      await _repository.deleteJob(jobId);
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          deleteError: AppError.storage,
          deleteErrorToken: state.deleteErrorToken + 1,
        ),
      );
      await _subscribe();
    }
  }

  Future<void> _subscribe() async {
    await _subscription?.cancel();
    final firstResult = Completer<void>();
    void complete() {
      if (!firstResult.isCompleted) firstResult.complete();
    }

    _subscription = _repository
        .watchJobs(_query)
        .listen(
          (entities) {
            if (isClosed) return;
            emit(
              state.copyWith(
                status: JobsStatus.success,
                jobs: entities,
                hasMore: entities.length >= _limit,
                isLoadingMore: false,
                clearLastError: true,
              ),
            );
            complete();
          },
          onError: (Object _) {
            if (!isClosed) {
              emit(
                state.copyWith(
                  status: JobsStatus.failure,
                  isLoadingMore: false,
                  lastError: AppError.storage,
                ),
              );
            }
            complete();
          },
        );
    return firstResult.future;
  }

  @override
  Future<void> close() async {
    _searchTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
