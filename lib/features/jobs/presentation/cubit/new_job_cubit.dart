import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/file_picker_service.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class NewJobCubit extends Cubit<NewJobState> {
  NewJobCubit({
    required this.repository,
    required this.filePicker,
    required this.generateIdempotencyKey,
  }) : super(const NewJobState());

  final JobsRepository repository;
  final FilePickerService filePicker;
  final String Function() generateIdempotencyKey;

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

  void setFilename(String value) => emit(state.copyWith(filename: value));

  void setSourceUrl(String value) => emit(state.copyWith(sourceUrl: value));

  void toggleForceWhisper() =>
      emit(state.copyWith(forceWhisper: !state.forceWhisper));

  void toggleIdempotency() {
    if (state.idempotencyEnabled) {
      emit(state.copyWith(idempotencyEnabled: false, idempotencyKey: ''));
      return;
    }
    emit(
      state.copyWith(
        idempotencyEnabled: true,
        idempotencyKey: state.idempotencyKey ?? generateIdempotencyKey(),
      ),
    );
  }

  Future<void> pickMedia() async {
    final sourceType = state.sourceType;
    if (sourceType != NewJobSourceType.video &&
        sourceType != NewJobSourceType.audio) {
      return;
    }
    final media = sourceType == NewJobSourceType.audio
        ? PickableMedia.audio
        : PickableMedia.video;

    final file = await filePicker.pick(media: media);
    if (file == null || isClosed) return;

    emit(
      state.copyWith(
        pickedFile: file,
        filename: '',
        fileTooLarge: file.sizeBytes > UploadFile.maxBytes,
        status: NewJobStatus.idle,
      ),
    );
  }

  void clearPickedFile() =>
      emit(state.copyWith(pickedFile: null, filename: '', fileTooLarge: false));

  Future<void> submit() async {
    final snapshot = state;
    if (!snapshot.canSubmit || snapshot.status == NewJobStatus.submitting) return;

    emit(
      NewJobState(
        sourceType: snapshot.sourceType,
        language: snapshot.language,
        text: snapshot.text,
        pickedFile: snapshot.pickedFile,
        filename: snapshot.filename,
        sourceUrl: snapshot.sourceUrl,
        forceWhisper: snapshot.forceWhisper,
        idempotencyEnabled: snapshot.idempotencyEnabled,
        idempotencyKey: snapshot.idempotencyKey,
        fileTooLarge: snapshot.fileTooLarge,
        status: NewJobStatus.submitting,
      ),
    );

    final created = await repository.submitJob(_buildParams(snapshot));
    final job = switch (created) {
      Success(:final data) => data,
      Failure(:final error) => _fail(error),
    };
    if (job == null) return;
    if (snapshot.sourceType.wireValue == 'upload') {
      final slot = job.uploadSlot;
      if (slot == null) {
        _fail(const ApiError.server('missing upload_slot', null));
        return;
      }

      final uploaded = await repository.uploadToSlot(slot.uploadUrl, snapshot.pickedFile!);
      final failureAfterUpload = switch (uploaded) {
        Failure(:final error) => error,
        Success() => null,
      };
      if (failureAfterUpload != null) {
        _fail(failureAfterUpload);
        return;
      }

      final confirmed = await repository.confirmUpload(job.id);
      final confirmFailure = switch (confirmed) {
        Failure(:final error) => error,
        Success() => null,
      };
      if (confirmFailure != null) {
        _fail(confirmFailure);
        return;
      }
    }

    if (isClosed) return;
    emit(
      state.copyWith(status: NewJobStatus.success, submittedJobId: job.id),
    );
  }

  JobEntity? _fail(ApiError error) {
    if (isClosed) return null;
    emit(state.copyWith(status: NewJobStatus.failure, lastError: error));
    return null;
  }

  SubmitJobParams _buildParams(NewJobState snapshot) {
    final language = snapshot.language.wireValue;
    final idempotencyKey = snapshot.idempotencyEnabled ? snapshot.idempotencyKey : null;

    return switch (snapshot.sourceType) {
      NewJobSourceType.text => SubmitJobParams(
        sourceType: 'text',
        language: language,
        text: snapshot.text.trim(),
        idempotencyKey: idempotencyKey,
      ),
      NewJobSourceType.youtube => SubmitJobParams(
        sourceType: 'youtube',
        language: language,
        sourceUrl: snapshot.sourceUrl.trim(),
        forceWhisper: snapshot.forceWhisper,
        idempotencyKey: idempotencyKey,
      ),
      NewJobSourceType.video ||
      NewJobSourceType.audio => () {
        final file = snapshot.pickedFile!;
        final hasOverride = snapshot.filename.trim().isNotEmpty;
        return SubmitJobParams(
          sourceType: 'upload',
          language: language,
          filename: hasOverride ? snapshot.filename.trim() : file.name,
          contentType: file.contentType,
          sizeHint: file.sizeBytes,
          idempotencyKey: idempotencyKey,
        );
      }(),
    };
  }
}
