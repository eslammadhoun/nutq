import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

enum JobsStatus { initial, loading, success, failure }

@immutable
class JobsState {
  const JobsState({
    this.status = JobsStatus.initial,
    this.allJobs = const [],
    this.selectedFilter,
    this.searchQuery = '',
    this.nextCursor,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final JobsStatus status;
  final List<Job> allJobs;
  final JobStatus? selectedFilter;
  final String searchQuery;
  final String? nextCursor;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => nextCursor != null;

  List<Job> get filteredJobs {
    final query = searchQuery.trim().toLowerCase();
    return allJobs.where((job) {
      final matchesFilter =
          selectedFilter == null || job.status == selectedFilter;
      final matchesQuery =
          query.isEmpty || job.subtitle.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  JobsState copyWith({
    JobsStatus? status,
    List<Job>? allJobs,
    JobStatus? selectedFilter,
    bool clearFilter = false,
    String? searchQuery,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return JobsState(
      status: status ?? this.status,
      allJobs: allJobs ?? this.allJobs,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}
