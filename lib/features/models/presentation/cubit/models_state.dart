import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/features/models/presentation/cubit/model_tile_status.dart';

@immutable
class ModelsState {
  const ModelsState({this.tiers = const [], this.lastError});

  final List<ModelTileState> tiers;

  /// Raw error from the last failed download — localized at display time,
  /// matching the jobs feature's `lastError` convention.
  final ApiError? lastError;

  ModelsState copyWith({List<ModelTileState>? tiers, ApiError? lastError, bool clearError = false}) =>
      ModelsState(tiers: tiers ?? this.tiers, lastError: clearError ? null : (lastError ?? this.lastError));
}
