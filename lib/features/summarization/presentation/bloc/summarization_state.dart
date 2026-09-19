import 'package:flutter/foundation.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';

@immutable
sealed class SummarizationState {
  const SummarizationState();
}

class SummarizationIdle extends SummarizationState {
  const SummarizationIdle();
}

class SummarizationRunning extends SummarizationState {
  const SummarizationRunning(this.progress);

  final SummarizationProgress progress;
}

class SummarizationSuccess extends SummarizationState {
  const SummarizationSuccess(this.result);

  final SummaryResult result;
}

class SummarizationFailed extends SummarizationState {
  const SummarizationFailed(this.kind);

  /// Localized by the UI; never pre-formatted here.
  final SummarizationFailureKind kind;
}

class SummarizationCancelled extends SummarizationState {
  const SummarizationCancelled();
}
