import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/profile/domain/job_storage.dart';

@immutable
class ProfileState {
  const ProfileState({this.usage, this.deleting = false, this.lastError});

  /// Null until measured.
  final StorageUsage? usage;
  final bool deleting;
  final AppError? lastError;
}

/// The Settings tab's storage line and "Delete all jobs". Theme and language
/// have their own app-wide cubits.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._storage) : super(const ProfileState());

  final JobStorage _storage;

  Future<void> refresh() async {
    try {
      final usage = await _storage.usage();
      if (!isClosed) emit(ProfileState(usage: usage, deleting: state.deleting));
    } catch (_) {
      if (!isClosed) emit(ProfileState(usage: state.usage, lastError: AppError.storage));
    }
  }

  Future<void> deleteAllJobs() async {
    if (state.deleting) return;
    emit(ProfileState(usage: state.usage, deleting: true));
    try {
      await _storage.deleteAllJobs();
      if (isClosed) return;
      emit(const ProfileState());
      await refresh();
    } catch (_) {
      if (!isClosed) emit(ProfileState(usage: state.usage, lastError: AppError.storage));
    }
  }
}
