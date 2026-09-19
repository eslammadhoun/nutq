import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/models/presentation/cubit/models_state.dart';

/// UI-state holder for the Models screen. There is no model manager behind
/// it yet, so the tier list stays empty.
class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit() : super(const ModelsState());

  Future<void> loadTiers() async {}

  Future<void> download(String modelId) async {}

  void cancelDownload(String modelId) {}

  Future<void> deleteModel(String modelId) async {}

  void clearError() => emit(state.copyWith(clearError: true));
}
