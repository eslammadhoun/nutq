import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack_status.dart';
import 'package:nutq/features/ai_models/domain/repositories/model_repository.dart';

/// The download progress of a set of model packs, as one figure.
@immutable
class ModelDownloadState {
  const ModelDownloadState({required this.packs, required this.statuses});

  /// The packs this screen is about.
  final List<ModelPack> packs;
  final Map<String, ModelPackStatus> statuses;

  ModelPackStatus statusOf(String id) => statuses[id]!;

  int get totalBytes => packs.fold(0, (sum, pack) => sum + pack.bytes);

  int get receivedBytes => packs.fold(0, (sum, pack) => sum + statusOf(pack.id).receivedBytes);

  double get progress => totalBytes == 0 ? 0 : receivedBytes / totalBytes;

  bool get isReady => packs.every((pack) => statusOf(pack.id).isReady);

  bool get isDownloading =>
      packs.any((pack) => statusOf(pack.id).phase == ModelPackPhase.downloading);

  /// Why the last download stopped, when one of the packs failed.
  AppError? get error {
    for (final pack in packs) {
      final status = statusOf(pack.id);
      if (status.phase == ModelPackPhase.failed) return status.error;
    }
    return null;
  }

  ModelDownloadState copyWith({Map<String, ModelPackStatus>? statuses}) =>
      ModelDownloadState(packs: packs, statuses: statuses ?? this.statuses);
}

/// Downloads, pauses and deletes the model packs a screen shows. The
/// repository keeps going if the screen closes; reopening it picks the
/// progress up again.
class ModelDownloadCubit extends Cubit<ModelDownloadState> {
  ModelDownloadCubit(this._repository, List<ModelPack> packs)
    : super(ModelDownloadState(packs: packs, statuses: _repository.statuses)) {
    _subscription = _repository.changes.listen(
      (statuses) => emit(state.copyWith(statuses: statuses)),
    );
  }

  final ModelRepository _repository;
  late final StreamSubscription<Map<String, ModelPackStatus>> _subscription;

  /// Downloads [ids], or every pack of this screen.
  void download([Iterable<String>? ids]) =>
      unawaited(_repository.download(ids ?? state.packs.map((pack) => pack.id)));

  /// Pauses: what arrived is kept, and [download] resumes from there.
  void pause() => _repository.cancel();

  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
