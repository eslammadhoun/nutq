import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';

/// UI-state holder for the Job Detail screen. There is no data source behind
/// it, so the screen stays in its initial state.
class JobDetailCubit extends Cubit<JobDetailState> {
  JobDetailCubit() : super(const JobDetailState());

  Future<void> refresh() async {}

  Future<void> cancelJob() async {}
}
