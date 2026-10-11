import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/alerts/data/job_alerts_repository.dart';
import 'package:nutq/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/async_helpers.dart';
import '../jobs/support/job_fixtures.dart';

void main() {
  late JobsRepositoryImpl jobs;
  late AppPreferences prefs;
  late JobAlertsRepository repository;
  late DateTime clock;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPreferences(await SharedPreferences.getInstance());
    final db = newTestDatabase();
    addTearDown(db.close);
    clock = DateTime.utc(2026, 10, 6, 12);
    jobs = JobsRepositoryImpl(
      JobsLocalDataSourceImpl(db.jobsDao),
      newId: () => 'job-${clock.microsecondsSinceEpoch}',
      removeFile: (_) async {},
      now: () => clock = clock.add(const Duration(minutes: 1)),
    );
    repository = JobAlertsRepository(jobs, prefs);
    addTearDown(repository.dispose);
  });

  Future<String> finished(String text, {JobFailureKind? failure}) async {
    final id = (await jobs.createJob(draft(text))).id;
    await jobs.markRunning(id);
    if (failure == null) {
      await jobs.completeJob(id, testSummary());
    } else {
      await jobs.failJob(id, failure);
    }
    return id;
  }

  group('JobAlertsRepository', () {
    test('lists finished and failed jobs, newest finished first, not active ones', () async {
      final done = await finished('نص مكتمل');
      final failed = await finished('نص فشل', failure: JobFailureKind.interrupted);
      await jobs.createJob(draft('ما زال ينتظر'));

      final alerts = await repository.watchAlerts().first;
      expect(alerts.map((a) => a.jobId), [failed, done]);
      expect(alerts.first.failure, JobFailureKind.interrupted);
      expect(alerts.last.succeeded, isTrue);
      expect(alerts.last.title, 'نص مكتمل', reason: 'falls back to the text preview');
    });

    test('dismissed alerts disappear and stay gone; deleted jobs take theirs', () async {
      final a = await finished('أ');
      final b = await finished('ب');
      final seen = <List<String>>[];
      final sub = repository.watchAlerts().listen((l) => seen.add([for (final x in l) x.jobId]));
      addTearDown(sub.cancel);
      await eventually(() => seen.isNotEmpty);

      await repository.dismiss([a]);
      await eventually(() => seen.last.length == 1);
      expect(seen.last, [b]);
      expect(prefs.alertsDismissed, {a});

      await jobs.deleteJob(b);
      await eventually(() => seen.last.isEmpty);
    });
  });

  group('AlertsCubit', () {
    test('counts alerts after the last visit as unread', () async {
      await finished('قديم');
      await repository.markSeen(clock);
      await finished('جديد');
      final cubit = AlertsCubit(repository, now: () => clock);
      addTearDown(cubit.close);
      await eventually(() => cubit.state.loaded);
      expect(cubit.state.alerts, hasLength(2));
      expect(cubit.state.unreadCount, 1);
    });

    test('opening the tab marks everything seen but keeps the dots until it is left', () async {
      await finished('أ');
      final cubit = AlertsCubit(repository, now: () => clock);
      addTearDown(cubit.close);
      await eventually(() => cubit.state.loaded);
      expect(cubit.state.unreadCount, 1);

      await cubit.opened();
      expect(repository.seenAt, clock);
      expect(cubit.state.unreadCount, 1, reason: 'dots stay while the tab is open');
      cubit.closed();
      expect(cubit.state.unreadCount, 0);
    });

    test('a job that finishes while the app is open is offered as a banner, once', () async {
      final cubit = AlertsCubit(repository, now: () => clock);
      addTearDown(cubit.close);
      await finished('قبل');
      await eventually(() => cubit.state.loaded && cubit.state.alerts.isNotEmpty);
      expect(cubit.state.fresh?.title, anyOf(isNull, 'قبل'));
      cubit.bannerShown();

      await finished('جديد');
      await eventually(() => cubit.state.fresh != null);
      expect(cubit.state.fresh!.title, 'جديد');
      cubit.bannerShown();
      expect(cubit.state.fresh, isNull);
    });

    test('dismiss and clear all', () async {
      final a = await finished('أ');
      await finished('ب');
      final cubit = AlertsCubit(repository, now: () => clock);
      addTearDown(cubit.close);
      await eventually(() => cubit.state.alerts.length == 2);

      await cubit.dismiss(a);
      expect(cubit.state.alerts.map((x) => x.jobId), isNot(contains(a)));
      await cubit.clearAll();
      expect(cubit.state.alerts, isEmpty);
      expect(await repository.watchAlerts().first, isEmpty, reason: 'remembered');
    });
  });
}
