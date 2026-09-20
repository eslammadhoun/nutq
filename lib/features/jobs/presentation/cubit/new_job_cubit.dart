import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';
import 'package:nutq/core/domain/content_language.dart';

/// State of the New Job sheet: the form fields, and saving the job.
class NewJobCubit extends Cubit<NewJobState> {
  NewJobCubit(this._repository) : super(const NewJobState());

  final JobsRepository _repository;

  void changeSourceType(int index) {
    final newType = JobSourceType.values[index];
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

  Future<void> pickMedia() async {}

  void clearPickedFile() =>
      emit(state.copyWith(pickedFile: null, fileTooLarge: false));

  /// Saves the job as `pending`; the sheet then opens it. Processing starts
  /// when Job Detail opens, so the job exists (and survives a crash) first.
  Future<void> submit() async {
    if (!state.canSubmit ||
        state.status == NewJobStatus.submitting ||
        state.status == NewJobStatus.success) {
      return;
    }
    emit(state.copyWith(status: NewJobStatus.submitting, lastError: null));
    try {
      final job = await _repository.createJob(
        NewJobDraft.text(
          text: state.text,
          language: ContentLanguage.fromCode(state.language.wireValue),
        ),
      );
      if (isClosed) return;
      emit(
        state.copyWith(status: NewJobStatus.success, submittedJobId: job.id),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NewJobStatus.failure,
          lastError: AppError.storage,
        ),
      );
    }
  }
}
