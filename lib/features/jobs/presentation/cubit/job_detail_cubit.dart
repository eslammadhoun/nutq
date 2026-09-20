import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:nutq/features/summarization/data/prompts/prompt_version.dart';
import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

/// Runs one on-device summary job for [transcript] and mirrors it as a
/// `JobDetailEntity` for the Job Detail screen, updating on every event of the
/// pipeline's progress stream.
///
/// Raw status strings follow the backend vocabulary the screen already maps
/// (`pending`, `summarizing`, `completed`, `failed`, `cancelled`).
class JobDetailCubit extends Cubit<JobDetailState> {
  JobDetailCubit({
    required this._summarize,
    required this._repository,
    required this.transcript,
    this.language = 'ar',
    this.config = const SummarizationConfig(),
  }) : super(const JobDetailState()) {
    _start();
  }

  final SummarizeTranscript _summarize;
  final SummarizationRepository _repository;
  final String transcript;
  final String language;
  final SummarizationConfig config;

  final CancellationToken _token = CancellationToken();
  final DateTime _createdAt = DateTime.now().toUtc();
  late final String _jobId = 'local-${_createdAt.millisecondsSinceEpoch}';
  StreamSubscription<SummarizationUpdate>? _subscription;

  static final _wordSplit = RegExp(r'\s+');

  void _start() {
    final text = transcript.trim();
    final wordCount = text.isEmpty ? 0 : text.split(_wordSplit).length;
    emit(
      state.copyWith(
        status: JobDetailStatus.success,
        job: _job(
          status: 'pending',
          transcript: Transcript(
            language: language,
            wordCount: wordCount,
            modelName: '',
            modelVersion: '',
            text: text,
          ),
        ),
        transcriptText: text,
      ),
    );

    _subscription = _summarize
        .stream(text, config, cancellation: _token)
        .listen(_onUpdate, onError: _onError);
  }

  void _onUpdate(SummarizationUpdate update) {
    switch (update) {
      case SummarizationProgressUpdate(:final progress):
        emit(
          state.copyWith(
            job: _withStatus('summarizing'),
            progress: progress,
          ),
        );
      case SummarizationCompletedUpdate(:final result):
        emit(
          state.copyWith(
            job: _withStatus(
              'completed',
              summary: Summary(
                summaryText: result.summary,
                toneAndFormat: config.length.name,
                takeaways: [for (final t in result.keyPoints) {'text': t}],
                modelName: 'gemma3-1b-it-q4',
                promptVersion: summarizationPromptVersion,
                tokensIn: result.debug.inputTokens,
                tokensOut: result.debug.outputTokens,
              ),
            ),
            clearProgress: true,
            summaryTakeaways: [for (final t in result.keyPoints) {'text': t}],
            summaryNeedsReview: result.validation.isSuspicious,
            isCancelling: false,
          ),
        );
    }
  }

  void _onError(Object error) {
    if (error is SummarizationCancelledException) {
      emit(
        state.copyWith(
          job: _withStatus('cancelled'),
          clearProgress: true,
          isCancelling: false,
        ),
      );
      return;
    }
    final kind = error is SummarizationFailure
        ? error.kind
        : SummarizationFailureKind.generationFailed;
    emit(
      state.copyWith(
        job: _withStatus('failed'),
        clearProgress: true,
        failureKind: kind,
        isCancelling: false,
      ),
    );
  }

  /// Nothing to reload: state is pushed by the pipeline stream.
  Future<void> refresh() async {}

  Future<void> cancelJob() async {
    if (state.isCancelling) return;
    emit(state.copyWith(isCancelling: true));
    _token.cancel();
    await _repository.cancel();
  }

  JobDetailEntity _job({
    required String status,
    Transcript? transcript,
    Summary? summary,
  }) => JobDetailEntity(
    id: _jobId,
    status: status,
    sourceType: 'text',
    language: language,
    createdAt: _createdAt,
    updatedAt: DateTime.now().toUtc(),
    transcript: transcript,
    summary: summary,
  );

  JobDetailEntity _withStatus(String status, {Summary? summary}) {
    final current = state.job!;
    return JobDetailEntity(
      id: current.id,
      status: status,
      sourceType: current.sourceType,
      language: current.language,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
      transcript: current.transcript,
      summary: summary ?? current.summary,
    );
  }

  @override
  Future<void> close() async {
    final running = state.job?.status == 'pending' || state.job?.status == 'summarizing';
    _token.cancel();
    await _subscription?.cancel();
    if (running) await _repository.cancel();
    return super.close();
  }
}
