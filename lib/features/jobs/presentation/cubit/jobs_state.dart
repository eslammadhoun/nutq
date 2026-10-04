import 'package:flutter/foundation.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';

enum JobsStatus { initial, loading, success, failure }

@immutable
class JobsState {
  const JobsState({
    this.status = JobsStatus.initial,
    this.jobs = const [],
    this.selectedFilter,
    this.searchQuery = '',
    this.hasMore = false,
    this.isLoadingMore = false,
    this.lastError,
    this.deleteError,
    this.deleteErrorToken = 0,
  });

  final JobsStatus status;

  /// Jobs matching the current filter and search, newest first.
  final List<JobEntity> jobs;
  final JobRunStatus? selectedFilter;

  /// Text in the search field (applied to the query after a short debounce).
  final String searchQuery;

  /// True while more jobs exist beyond the ones loaded.
  final bool hasMore;
  final bool isLoadingMore;

  /// Raw error from the last failed load — localized at display time.
  final AppError? lastError;

  /// Transient signal for a one-off SnackBar, paired with [deleteErrorToken]
  /// (bumped on every failure) so `listenWhen` fires on repeats.
  final AppError? deleteError;
  final int deleteErrorToken;

  JobsState copyWith({
    JobsStatus? status,
    List<JobEntity>? jobs,
    JobRunStatus? selectedFilter,
    bool clearFilter = false,
    String? searchQuery,
    bool? hasMore,
    bool? isLoadingMore,
    AppError? lastError,
    bool clearLastError = false,
    AppError? deleteError,
    int? deleteErrorToken,
  }) => JobsState(
    status: status ?? this.status,
    jobs: jobs ?? this.jobs,
    selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    searchQuery: searchQuery ?? this.searchQuery,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    lastError: clearLastError ? null : (lastError ?? this.lastError),
    deleteError: deleteError ?? this.deleteError,
    deleteErrorToken: deleteErrorToken ?? this.deleteErrorToken,
  );
}
