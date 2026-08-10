import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

part 'jobs_state.dart';

class JobsCubit extends Cubit<JobsState> {
  JobsCubit(this._repo) : super(const JobsInitial());

  final JobsRepository _repo;

  Future<void> loadJobs() async {
    emit(const JobsLoading());
    final result = await _repo.getJobs();
    switch (result) {
      case Success(:final data):
        emit(JobsLoaded(jobs: data.items, nextCursor: data.nextCursor));
      case Failure(:final message):
        emit(JobsError(message));
    }
  }

  Future<void> refresh() => loadJobs();

  Future<void> loadMore() async {
    final current = state;
    if (current is! JobsLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, actionError: null));
    final result = await _repo.getJobs(cursor: current.nextCursor);
    switch (result) {
      case Success(:final data):
        emit(
          current.copyWith(
            jobs: [...current.jobs, ...data.items],
            nextCursor: data.nextCursor,
            isLoadingMore: false,
          ),
        );
      case Failure(:final message):
        emit(current.copyWith(isLoadingMore: false, actionError: message));
    }
  }

  Future<void> submitTextJob(String text) async {
    final current = state;
    if (current is! JobsLoaded || current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, actionError: null));
    final result = await _repo.submitTextJob(text: text);
    switch (result) {
      case Success(:final data):
        emit(
          current.copyWith(jobs: [data, ...current.jobs], isSubmitting: false),
        );
      case Failure(:final message):
        emit(current.copyWith(isSubmitting: false, actionError: message));
    }
  }
}
