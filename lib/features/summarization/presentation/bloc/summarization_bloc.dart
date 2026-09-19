import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_event.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_state.dart';

class SummarizationBloc extends Bloc<SummarizationEvent, SummarizationState> {
  SummarizationBloc({
    required this._summarize,
    required this._repository,
    this.baseConfig = const SummarizationConfig(),
  }) : super(const SummarizationIdle()) {
    on<SummarizationStarted>(_onStarted);
    on<SummarizationProgressed>((e, emit) {
      if (state is SummarizationRunning) emit(SummarizationRunning(e.progress));
    });
    on<SummarizationCancelRequested>(_onCancel);
    on<SummarizationReset>((_, emit) => emit(const SummarizationIdle()));
  }

  final SummarizeTranscript _summarize;
  final SummarizationRepository _repository;
  final SummarizationConfig baseConfig;

  CancellationToken? _token;

  Future<void> _onStarted(
    SummarizationStarted event,
    Emitter<SummarizationState> emit,
  ) async {
    if (state is SummarizationRunning) return;
    final token = _token = CancellationToken();
    emit(const SummarizationRunning(SummarizationProgress(SummarizationStage.preparing)));
    try {
      final result = await _summarize(
        event.transcript,
        baseConfig.copyWith(length: event.length),
        cancellation: token,
        onProgress: (p) {
          if (!isClosed) add(SummarizationProgressed(p));
        },
      );
      emit(SummarizationSuccess(result));
    } on SummarizationCancelledException {
      emit(const SummarizationCancelled());
    } on SummarizationFailure catch (f) {
      emit(SummarizationFailed(f.kind));
    } catch (_) {
      emit(const SummarizationFailed(SummarizationFailureKind.generationFailed));
    } finally {
      _token = null;
    }
  }

  Future<void> _onCancel(
    SummarizationCancelRequested event,
    Emitter<SummarizationState> emit,
  ) async {
    _token?.cancel();
    await _repository.cancel();
  }

  @override
  Future<void> close() {
    _token?.cancel();
    return super.close();
  }
}
