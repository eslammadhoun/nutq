import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/l10n/app_localizations.dart';

/// Shared job display formatting — used by both [JobCard] (list) and the
/// Job Detail screen so status/source labels and colors never drift apart.

/// Locale-aware "Today, h:mm a" / "Yesterday" / "Jan 5" label. intl
/// localizes AM/PM and month names per locale (e.g. ص/م in Arabic).
String formatJobTimestamp(BuildContext context, DateTime utc) {
  final l10n = context.l10n;
  final local = utc.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(local.year, local.month, local.day);
  final locale = Localizations.localeOf(context).toString();
  final time = DateFormat('h:mm a', locale).format(local);

  if (date == today) return l10n.jobTodayLabel(time);
  if (date == today.subtract(const Duration(days: 1))) {
    return l10n.jobYesterdayLabel;
  }
  return DateFormat('MMM d', locale).format(local);
}

/// "6 Aug 2026 · 2 minutes ago" — the Job Detail hero card's fuller
/// timestamp, distinct from [formatJobTimestamp]'s compact list-row form.
String formatJobDetailTimestamp(BuildContext context, DateTime utc) {
  final locale = Localizations.localeOf(context).toString();
  final date = DateFormat('d MMM yyyy', locale).format(utc.toLocal());
  return '$date · ${formatRelativeTime(context, utc)}';
}

/// "Just now" / "2 minutes ago" / "3 hours ago" / "5 days ago" — not
/// pluralized (see [formatDuration]'s note: no ICU plural rules set up
/// yet), matching the rest of this file's convention.
String formatRelativeTime(BuildContext context, DateTime utc) {
  final l10n = context.l10n;
  final diff = DateTime.now().difference(utc.toLocal());
  if (diff.inMinutes < 1) return l10n.jobDetailJustNow;
  if (diff.inMinutes < 60) return l10n.jobDetailMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.jobDetailHoursAgo(diff.inHours);
  return l10n.jobDetailDaysAgo(diff.inDays);
}

String languageName(AppLocalizations l10n, String code) => switch (code) {
  'ar' => l10n.languageArabic,
  'en' => l10n.languageEnglish,
  _ => code,
};

/// "3m 42s" / "42s" — duration isn't split into localized minute/second
/// words since the app has no ICU plural rules set up yet; a compact
/// numeric form reads fine in both LTR and RTL layouts.
/// A file size for display: `512 KB`, `48 MB`, `1.2 GB`.
String formatBytes(int bytes) {
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
  if (bytes >= mb) return '${(bytes / mb).round()} MB';
  return '${(bytes / kb).ceil()} KB';
}

String formatDuration(double seconds) {
  final total = seconds.round();
  final minutes = total ~/ 60;
  final secs = total % 60;
  if (minutes == 0) return '${secs}s';
  return '${minutes}m ${secs}s';
}

({IconData icon, Color color, String label}) sourceTypeVisual(
  BuildContext context,
  JobSourceType type,
) {
  final colors = context.appColors;
  final l10n = context.l10n;
  return switch (type) {
    JobSourceType.video => (
      icon: Icons.slow_motion_video_outlined,
      color: colors.primary,
      label: l10n.sourceVideo,
    ),
    JobSourceType.audio => (
      icon: Icons.graphic_eq_rounded,
      color: colors.primary,
      label: l10n.sourceAudioFile,
    ),
    JobSourceType.youtube => (
      icon: Icons.play_arrow_rounded,
      color: colors.statusFailed,
      label: l10n.sourceYoutube,
    ),
    JobSourceType.text => (
      icon: Icons.text_snippet_rounded,
      color: colors.primary,
      label: l10n.sourceText,
    ),
  };
}

// Badge backgrounds are the status color at 12% opacity, matching the
// Figma design exactly (e.g. rgba(5,150,105,0.12) for Done) rather than
// the flat statusXBg tokens, which are different hex values.
({Color color, Color background, String label}) jobStatusVisual(
  BuildContext context,
  JobRunStatus status,
) {
  final colors = context.appColors;
  final l10n = context.l10n;
  return switch (status) {
    JobRunStatus.completed => (
      color: colors.statusDone,
      background: colors.statusDone.withValues(alpha: 0.12),
      label: l10n.statusDone,
    ),
    JobRunStatus.running => (
      color: colors.primary,
      background: colors.primary.withValues(alpha: 0.12),
      label: l10n.statusProcessing,
    ),
    JobRunStatus.pending => (
      color: colors.statusQueued,
      background: colors.statusQueued.withValues(alpha: 0.12),
      label: l10n.statusQueued,
    ),
    JobRunStatus.failed => (
      color: colors.statusFailed,
      background: colors.statusFailed.withValues(alpha: 0.12),
      label: l10n.statusFailed,
    ),
    JobRunStatus.cancelled => (
      color: colors.statusCancelled,
      background: colors.statusCancelled.withValues(alpha: 0.12),
      label: l10n.statusCancelled,
    ),
  };
}

/// Reading direction of a job's own text (transcript, summary, takeaways).
///
/// Follows the *job's* language, never the app locale: an Arabic job reads
/// right-to-left even in an English UI, and vice versa.
TextDirection jobTextDirection(String languageCode) =>
    const {'ar', 'fa', 'he', 'ur'}.contains(languageCode) ? TextDirection.rtl : TextDirection.ltr;

/// User-facing name of a job stage (no model or runtime details).
String jobStageLabel(AppLocalizations l10n, JobStage stage) => switch (stage) {
  JobStage.preparing => l10n.jobStagePreparing,
  JobStage.acquiring => l10n.jobStageAcquiring,
  JobStage.transcribing => l10n.jobStageTranscribing,
  JobStage.analyzing => l10n.jobStageAnalyzing,
  JobStage.summarizing => l10n.jobStageSummarizing,
  JobStage.combining => l10n.jobStageCombining,
  JobStage.checking => l10n.jobStageChecking,
  JobStage.finalizing => l10n.jobStageFinalizing,
  JobStage.completed => l10n.jobStageCompleted,
};

/// Localized message for why a job failed.
String jobFailureMessage(AppLocalizations l10n, JobFailureKind kind) => switch (kind) {
  JobFailureKind.emptyTranscript => l10n.jobFailureEmptyTranscript,
  JobFailureKind.modelUnavailable => l10n.jobFailureModelUnavailable,
  JobFailureKind.generationFailed => l10n.jobFailureGenerationFailed,
  JobFailureKind.interrupted => l10n.jobFailureInterrupted,
  JobFailureKind.sourceUnavailable => l10n.jobFailureSourceUnavailable,
  JobFailureKind.unsupportedMedia => l10n.jobFailureUnsupportedMedia,
  JobFailureKind.transcriptionFailed => l10n.jobFailureTranscriptionFailed,
  JobFailureKind.insufficientStorage => l10n.jobFailureInsufficientStorage,
};
