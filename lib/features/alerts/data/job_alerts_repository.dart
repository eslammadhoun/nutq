import 'dart:async';

import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/alerts/domain/alerts_repository.dart';
import 'package:nutq/features/alerts/domain/job_alert.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

/// Alerts read straight from the jobs: every completed or failed job is one.
/// No table of its own; only what was seen and dismissed is kept, in
/// preferences, so a deleted job's alert simply disappears.
class JobAlertsRepository implements AlertsRepository {
  JobAlertsRepository(this._jobs, this._prefs);

  final JobsRepository _jobs;
  final AppPreferences _prefs;
  final _dismissals = StreamController<void>.broadcast();

  /// The most alerts kept in the list.
  static const limit = 100;

  @override
  Stream<List<JobAlert>> watchAlerts() {
    late final StreamController<List<JobAlert>> controller;
    StreamSubscription<List<JobEntity>>? jobs;
    StreamSubscription<void>? dismissals;
    var latest = const <JobEntity>[];

    void publish() {
      final dismissed = _prefs.alertsDismissed;
      controller.add(
        [
          for (final job in latest)
            if (!dismissed.contains(job.id)) _toAlert(job),
        ]..sort((a, b) => b.at.compareTo(a.at)),
      );
    }

    controller = StreamController<List<JobAlert>>(
      onListen: () {
        jobs = _jobs
            .watchJobs(
              const JobsQuery(
                statuses: {JobRunStatus.completed, JobRunStatus.failed},
                limit: limit,
              ),
            )
            .listen((list) {
              latest = list;
              publish();
            }, onError: controller.addError);
        dismissals = _dismissals.stream.listen((_) => publish());
      },
      onCancel: () async {
        await jobs?.cancel();
        await dismissals?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  DateTime? get seenAt => _prefs.alertsSeenAt;

  @override
  Future<void> markSeen(DateTime at) => _prefs.setAlertsSeenAt(at);

  @override
  Future<void> dismiss(Iterable<String> jobIds) async {
    await _prefs.setAlertsDismissed({..._prefs.alertsDismissed, ...jobIds});
    _dismissals.add(null);
  }

  Future<void> dispose() => _dismissals.close();

  static JobAlert _toAlert(JobEntity job) => JobAlert(
    jobId: job.id,
    title: (job.sourceTitle?.trim().isNotEmpty ?? false)
        ? job.sourceTitle!.trim()
        : (job.preview ?? '').trim(),
    at: job.updatedAt,
    failure: job.status == JobRunStatus.failed
        ? job.failureKind ?? JobFailureKind.generationFailed
        : null,
  );
}
