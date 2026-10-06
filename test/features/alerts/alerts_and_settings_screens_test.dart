import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/core/theme/theme_cubit.dart';
import 'package:nutq/features/alerts/domain/alerts_repository.dart';
import 'package:nutq/features/alerts/domain/job_alert.dart';
import 'package:nutq/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:nutq/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/profile/domain/job_storage.dart';
import 'package:nutq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:nutq/features/profile/presentation/screens/profile_screen.dart';
import 'package:nutq/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Alerts implements AlertsRepository {
  _Alerts(this.alerts);

  final List<JobAlert> alerts;
  final dismissed = <String>{};

  @override
  Stream<List<JobAlert>> watchAlerts() => Stream.value(alerts);

  @override
  DateTime? get seenAt => null;

  @override
  Future<void> markSeen(DateTime at) async {}

  @override
  Future<void> dismiss(Iterable<String> jobIds) async => dismissed.addAll(jobIds);
}

class _Storage implements JobStorage {
  int jobs = 3;

  @override
  Future<StorageUsage> usage() async => StorageUsage(jobs: jobs, mediaBytes: 12 * 1024 * 1024);

  @override
  Future<void> deleteAllJobs() async => jobs = 0;
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<BlocProvider> providers = const [],
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: providers,
      child: ScreenUtilPlusInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: screen,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Alerts screen', () {
    final now = DateTime.now().toUtc();

    testWidgets('lists finished and failed jobs, with unread dots, and clears them', (
      tester,
    ) async {
      final repository = _Alerts([
        JobAlert(jobId: 'a', title: 'talk.m4a', at: now),
        JobAlert(jobId: 'b', title: '', at: now, failure: JobFailureKind.unsupportedMedia),
      ]);
      final cubit = AlertsCubit(repository);
      addTearDown(cubit.close);
      await _pump(
        tester,
        const AlertsScreen(),
        providers: [BlocProvider<AlertsCubit>.value(value: cubit)],
      );

      expect(find.text('Summary ready'), findsOneWidget);
      expect(find.text('talk.m4a'), findsOneWidget);
      expect(find.text('Job failed'), findsOneWidget);
      expect(find.text('Untitled job'), findsOneWidget);
      expect(find.text("This file's format isn't supported."), findsOneWidget);

      await tester.tap(find.text('Clear all'));
      await tester.pump();
      expect(find.text('No alerts yet. Finished jobs show up here.'), findsOneWidget);
      expect(repository.dismissed, {'a', 'b'});
    });

    testWidgets('shows an empty state with nothing finished', (tester) async {
      final cubit = AlertsCubit(_Alerts(const []));
      addTearDown(cubit.close);
      await _pump(
        tester,
        const AlertsScreen(),
        providers: [BlocProvider<AlertsCubit>.value(value: cubit)],
      );
      expect(find.text('No alerts yet. Finished jobs show up here.'), findsOneWidget);
      expect(find.text('Clear all'), findsNothing);
    });
  });

  group('Settings screen', () {
    testWidgets('switches the theme, shows storage, and deletes all jobs after confirming', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      final theme = ThemeCubit(prefs);
      final locale = LocaleCubit(prefs);
      final storage = _Storage();
      final profile = ProfileCubit(storage);
      addTearDown(() async {
        await theme.close();
        await locale.close();
        await profile.close();
      });
      await _pump(
        tester,
        const ProfileScreen(),
        providers: [
          BlocProvider<ThemeCubit>.value(value: theme),
          BlocProvider<LocaleCubit>.value(value: locale),
          BlocProvider<ProfileCubit>.value(value: profile),
        ],
      );
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('3 jobs · 12 MB'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pump();
      expect(theme.state, ThemeMode.dark);

      await tester.tap(find.text('Delete all jobs'));
      await tester.pumpAndSettle();
      expect(find.text('Delete all jobs?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(storage.jobs, 0);
      expect(find.text('No jobs · 12 MB'), findsOneWidget);
    });
  });
}
