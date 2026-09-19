import 'package:flutter/foundation.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

@immutable
sealed class SummarizationEvent {
  const SummarizationEvent();
}

class SummarizationStarted extends SummarizationEvent {
  const SummarizationStarted({required this.transcript, required this.length});

  final String transcript;
  final SummaryLength length;
}

class SummarizationCancelRequested extends SummarizationEvent {
  const SummarizationCancelRequested();
}

class SummarizationReset extends SummarizationEvent {
  const SummarizationReset();
}

/// Internal: pipeline progress relayed into the bloc.
class SummarizationProgressed extends SummarizationEvent {
  const SummarizationProgressed(this.progress);

  final SummarizationProgress progress;
}
