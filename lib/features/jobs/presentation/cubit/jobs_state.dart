import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

@immutable
class JobsState {
  const JobsState({
    required this.allJobs,
    this.selectedFilter,
    this.searchQuery = '',
  });

  final List<Job> allJobs;
  final JobStatus? selectedFilter;
  final String searchQuery;

  List<Job> get filteredJobs {
    final query = searchQuery.trim().toLowerCase();
    return allJobs.where((job) {
      final matchesFilter =
          selectedFilter == null || job.status == selectedFilter;
      final matchesQuery =
          query.isEmpty || job.title.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  JobsState copyWith({
    List<Job>? allJobs,
    JobStatus? selectedFilter,
    bool clearFilter = false,
    String? searchQuery,
  }) {
    return JobsState(
      allJobs: allJobs ?? this.allJobs,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
