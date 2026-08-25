import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class NewJobCubit extends Cubit<NewJobState> {
  NewJobCubit() : super(NewJobState());

  void changeJobUploadType({required int index}) {
    JobUploadType currentJobType = state.jobUploadType;
    if (JobUploadType.values[index] != currentJobType) {
      emit(state.copyWith(jobUploadType: JobUploadType.values[index]));
    }
  }

  void toggleJobLanguage() {
    final int currentJobLanguage = state.jobLanguage.index;
    final JobLanguage newJobLanguage =
        JobLanguage.values[currentJobLanguage == 0 ? 1 : 0];
    emit(state.copyWith(jobLanguage: newJobLanguage));
  }

  void toggleIdempotencyKey() {
    final bool currentValue = state.idempotencyKey;
    emit(state.copyWith(idempotencyKey: !currentValue));
  }
}
