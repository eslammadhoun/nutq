import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

class JobsCubit extends Cubit<JobsState> {
  JobsCubit({required this._repo}) : super(const JobsState());

  final JobsRepository _repo;

  static const _pageSize = 20;

  Future<void> fetchJobs() async {
    emit(state.copyWith(status: JobsStatus.loading));
    final result = await _repo.listJobs(limit: _pageSize);
    result.when(
      success: (page) => emit(
        state.copyWith(
          status: JobsStatus.success,
          allJobs: page.items.map(Job.fromEntity).toList(),
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
        ),
      ),
      failure: (error) => emit(
        state.copyWith(
          status: JobsStatus.failure,
          lastError: error,
        ),
      ),
    );
  }

  Future<void> refresh() => fetchJobs();

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final result = await _repo.listJobs(
      cursor: state.nextCursor,
      limit: _pageSize,
    );
    result.when(
      success: (page) => emit(
        state.copyWith(
          allJobs: [...state.allJobs, ...page.items.map(Job.fromEntity)],
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      ),
      failure: (_) => emit(state.copyWith(isLoadingMore: false)),
    );
  }

  void selectFilter(JobStatus? status) {
    if (status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: status));
    }
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
