import 'package:flutter/foundation.dart';
import 'package:nutq/core/errors/app_error.dart';

enum ModelPackPhase {
  /// Not on the phone, or only partly: [ModelPackStatus.receivedBytes] says
  /// how much a resumed download will skip.
  missing,
  downloading,
  ready,

  /// The last download stopped with [ModelPackStatus.error]. What was already
  /// received is kept, so a retry resumes.
  failed,
}

/// Where one model pack stands on this phone.
@immutable
class ModelPackStatus {
  const ModelPackStatus({
    required this.phase,
    required this.totalBytes,
    this.receivedBytes = 0,
    this.error,
  });

  final ModelPackPhase phase;
  final int receivedBytes;
  final int totalBytes;
  final AppError? error;

  bool get isReady => phase == ModelPackPhase.ready;

  double get progress => totalBytes == 0 ? 0 : (receivedBytes / totalBytes).clamp(0, 1);

  @override
  bool operator ==(Object other) =>
      other is ModelPackStatus &&
      other.phase == phase &&
      other.receivedBytes == receivedBytes &&
      other.totalBytes == totalBytes &&
      other.error == error;

  @override
  int get hashCode => Object.hash(phase, receivedBytes, totalBytes, error);

  @override
  String toString() => 'ModelPackStatus($phase, $receivedBytes/$totalBytes, $error)';
}
