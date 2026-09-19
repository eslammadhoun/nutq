import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nutq/features/jobs/presentation/cubit/jobs_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

/// UI-state holder for the Jobs list screen. Holds filter/search selection
/// only; there is no data source behind it.
class JobsCubit extends Cubit<JobsState> {
  JobsCubit() : super(const JobsState(status: JobsStatus.success));

  Future<void> fetchJobs() async {}

  Future<void> refresh() => fetchJobs();

  Future<void> loadMore() async {}

  Future<void> deleteJob(String jobId) async {}

  void selectFilter(JobStatus? status) {
    if (status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: status));
    }
  }

  void search(String query) => emit(state.copyWith(searchQuery: query));
}
