import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

/// State of the New Job sheet: the form fields, and saving the job.
class NewJobCubit extends Cubit<NewJobState> {
  NewJobCubit(this._submitJob, {required Set<JobSourceType> supportedSources})
    : super(NewJobState(supportedSources: supportedSources));

  final SubmitJob _submitJob;

  void changeSourceType(int index) {
    final newType = JobSourceType.values[index];
    if (newType == state.sourceType) return;
    emit(state.copyWith(sourceType: newType, fileTooLarge: false));
  }

  void toggleLanguage() {
    final next = state.language == JobLanguage.ar ? JobLanguage.en : JobLanguage.ar;
    emit(state.copyWith(language: next));
  }

  void setText(String value) => emit(state.copyWith(text: value));

  void setSourceUrl(String value) => emit(state.copyWith(sourceUrl: value));

  Future<void> pickMedia() async {}

  void clearPickedFile() => emit(state.copyWith(pickedFile: null, fileTooLarge: false));

  /// Saves the job and queues it; the sheet then opens it. The job exists in
  /// storage before it runs, so a crash never loses it.
  Future<void> submit() async {
    if (!state.canSubmit ||
        state.status == NewJobStatus.submitting ||
        state.status == NewJobStatus.success) {
      return;
    }
    emit(state.copyWith(status: NewJobStatus.submitting, lastError: null));
    try {
      final job = await _submitJob(_draft());
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

  NewJobDraft _draft() {
    final language = ContentLanguage.fromCode(state.language.wireValue);
    return switch (state.sourceType) {
      JobSourceType.text => NewJobDraft.text(text: state.text, language: language),
      JobSourceType.youtube => NewJobDraft.youtube(url: state.sourceUrl, language: language),
      JobSourceType.audio || JobSourceType.video => NewJobDraft.media(
        type: state.sourceType,
        filePath: state.pickedFile!.path,
        language: language,
        mimeType: state.pickedFile!.contentType,
        title: state.pickedFile!.name,
      ),
    };
  }
}
