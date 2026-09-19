import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

/// UI-state holder for the New Job sheet: form fields only. Picking media and
/// submitting are no-ops until a data source is attached.
class NewJobCubit extends Cubit<NewJobState> {
  NewJobCubit() : super(const NewJobState());

  void changeSourceType(int index) {
    final newType = NewJobSourceType.values[index];
    if (newType == state.sourceType) return;
    emit(state.copyWith(sourceType: newType, fileTooLarge: false));
  }

  void toggleLanguage() {
    final next = state.language == JobLanguage.ar
        ? JobLanguage.en
        : JobLanguage.ar;
    emit(state.copyWith(language: next));
  }

  void setText(String value) => emit(state.copyWith(text: value));

  void setSourceUrl(String value) => emit(state.copyWith(sourceUrl: value));

  void toggleIdempotency() {
    if (state.idempotencyEnabled) {
      emit(state.copyWith(idempotencyEnabled: false, idempotencyKey: ''));
      return;
    }
    emit(
      state.copyWith(
        idempotencyEnabled: true,
        idempotencyKey: state.idempotencyKey,
      ),
    );
  }

  Future<void> pickMedia() async {}

  void clearPickedFile() =>
      emit(state.copyWith(pickedFile: null, fileTooLarge: false));

  Future<void> submit() async {}
}
