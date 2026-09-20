import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/l10n/app_localizations.dart';

/// User-facing stage names (no model/runtime details).
String summarizationStageLabel(AppLocalizations l10n, SummarizationStage stage) => switch (stage) {
  SummarizationStage.preparing => l10n.summarizeStagePreparing,
  SummarizationStage.analyzing => l10n.summarizeStageAnalyzing,
  SummarizationStage.summarizing => l10n.summarizeStageSummarizing,
  SummarizationStage.combining => l10n.summarizeStageCombining,
  SummarizationStage.checking => l10n.summarizeStageChecking,
  SummarizationStage.finalizing => l10n.summarizeStageFinalizing,
  SummarizationStage.completed => l10n.summarizeStageCompleted,
};
