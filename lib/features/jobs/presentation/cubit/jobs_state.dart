part of 'jobs_cubit.dart';

class _Unset {
  const _Unset();
}

const _unset = _Unset();

sealed class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

final class JobsInitial extends JobsState {
  const JobsInitial();
}

final class JobsLoading extends JobsState {
  const JobsLoading();
}

final class JobsError extends JobsState {
  const JobsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class JobsLoaded extends JobsState {
  const JobsLoaded({
    required this.jobs,
    required this.nextCursor,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.actionError,
  });

  final List<JobModel> jobs;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String? actionError;

  bool get hasMore => nextCursor != null;

  // `nextCursor` and `actionError` must be explicitly settable to null (no
  // more pages / error cleared), so a plain `value ?? this.value` default
  // won't do — it can never null out an existing value. `_unset` lets a
  // caller distinguish "didn't pass this" from "passed null on purpose".
  JobsLoaded copyWith({
    List<JobModel>? jobs,
    Object? nextCursor = _unset,
    bool? isLoadingMore,
    bool? isSubmitting,
    Object? actionError = _unset,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      nextCursor: identical(nextCursor, _unset)
          ? this.nextCursor
          : nextCursor as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionError: identical(actionError, _unset)
          ? this.actionError
          : actionError as String?,
    );
  }

  @override
  List<Object?> get props => [
    jobs,
    nextCursor,
    isLoadingMore,
    isSubmitting,
    actionError,
  ];
}
