import 'package:nutq/features/alerts/domain/job_alert.dart';

/// Finished jobs as alerts, and what the user has seen and dismissed.
abstract interface class AlertsRepository {
  /// Newest first, without dismissed ones. Emits again when jobs finish or
  /// alerts are dismissed.
  Stream<List<JobAlert>> watchAlerts();

  /// When the user last opened Alerts; later alerts are unread.
  DateTime? get seenAt;

  Future<void> markSeen(DateTime at);

  Future<void> dismiss(Iterable<String> jobIds);
}
