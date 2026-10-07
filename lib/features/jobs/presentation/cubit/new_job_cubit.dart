import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/media_files.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

/// State of the New Job sheet: the form fields, and saving the job.
class NewJobCubit extends Cubit<NewJobState> {
  NewJobCubit(
    this._submitJob,
    this._media, {
    required Set<JobSourceType> supportedSources,
    bool Function(String link)? recognizesLink,
  }) : _recognizesLink = recognizesLink ?? _anyLink,
       super(NewJobState(supportedSources: supportedSources));

  final bool Function(String link) _recognizesLink;

  static bool _anyLink(String link) => link.trim().isNotEmpty;

  final SubmitJob _submitJob;
  final MediaFiles _media;
  bool _picking = false;

  void changeSourceType(int index) {
    final newType = JobSourceType.values[index];
    if (newType == state.sourceType) return;
    // A file picked on the audio tab is not a video, and the reverse.
    emit(state.copyWith(sourceType: newType, pickedFile: null, fileTooLarge: false));
  }

  void toggleLanguage() {
    final next = state.language == JobLanguage.ar ? JobLanguage.en : JobLanguage.ar;
    emit(state.copyWith(language: next));
  }

  void setText(String value) => emit(state.copyWith(text: value));

  void setSourceUrl(String value) =>
      emit(state.copyWith(sourceUrl: value, sourceUrlValid: _recognizesLink(value)));

  /// Opens the system picker for the current tab (audio or video). A file
  /// over [UploadFile.maxBytes] is kept so the sheet can say why it cannot be
  /// submitted.
  Future<void> pickMedia() async {
    final type = state.sourceType;
    if (_picking || (type != JobSourceType.audio && type != JobSourceType.video)) return;
    _picking = true;
    try {
      final file = await _media.pick(type);
      if (isClosed || file == null || state.sourceType != type) return;
      emit(
        state.copyWith(pickedFile: file, fileTooLarge: file.sizeBytes > UploadFile.maxBytes),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: NewJobStatus.failure, lastError: AppError.storage));
    } finally {
      _picking = false;
    }
  }

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
      // A picked file is moved into app storage first: the job owns it from
      // then on and deletes it with the job.
      final picked = state.pickedFile;
      final mediaPath = _isMedia && picked != null ? await _media.import(picked) : null;
      final job = await _submitJob(_draft(mediaPath));
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

  bool get _isMedia =>
      state.sourceType == JobSourceType.audio || state.sourceType == JobSourceType.video;

  NewJobDraft _draft(String? mediaPath) {
    final language = ContentLanguage.fromCode(state.language.wireValue);
    return switch (state.sourceType) {
      JobSourceType.text => NewJobDraft.text(text: state.text, language: language),
      JobSourceType.youtube => NewJobDraft.youtube(url: state.sourceUrl, language: language),
      JobSourceType.audio || JobSourceType.video => NewJobDraft.media(
        type: state.sourceType,
        filePath: mediaPath!,
        language: language,
        mimeType: state.pickedFile!.contentType,
        title: state.pickedFile!.name,
      ),
    };
  }
}
