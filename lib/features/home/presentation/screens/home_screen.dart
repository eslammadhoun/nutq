import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/widgets/app_bottom_nav_bar.dart';
import 'package:nutq/features/alerts/domain/job_alert.dart';
import 'package:nutq/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:nutq/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:nutq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:nutq/features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AlertsCubit>(create: (_) => sl<AlertsCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
      ],
      child: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  AppNavTab _current = AppNavTab.home;

  static const _tabs = [AppNavTab.home, AppNavTab.alerts, AppNavTab.profile];

  void _select(AppNavTab tab) {
    if (tab == _current) return;
    final alerts = context.read<AlertsCubit>();
    if (_current == AppNavTab.alerts) alerts.closed();
    if (tab == AppNavTab.alerts) alerts.opened();
    // The job count and media size may have changed since it was last shown.
    if (tab == AppNavTab.profile) context.read<ProfileCubit>().refresh();
    setState(() => _current = tab);
  }

  /// A job finished while the app is open: say so, with a way to open it.
  void _showBanner(BuildContext context, JobAlert alert) {
    final l10n = context.l10n;
    final title = alert.title.isEmpty ? l10n.alertsUntitled : alert.title;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            alert.succeeded ? l10n.alertBannerDone(title) : l10n.alertBannerFailed(title),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          action: SnackBarAction(
            label: l10n.alertBannerView,
            onPressed: () => Navigator.pushNamed(context, Routes.jobDetail, arguments: alert.jobId),
          ),
        ),
      );
    context.read<AlertsCubit>().bannerShown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlertsCubit, AlertsState>(
      listenWhen: (previous, current) => current.fresh != null && previous.fresh != current.fresh,
      listener: (context, state) => _showBanner(context, state.fresh!),
      child: Scaffold(
        body: IndexedStack(
          index: _tabs.indexOf(_current),
          children: [
            BlocProvider<JobsCubit>(
              create: (context) => sl<JobsCubit>(),
              child: JobsScreen(onOpenAlerts: () => _select(AppNavTab.alerts)),
            ),
            const AlertsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BlocSelector<AlertsCubit, AlertsState, int>(
          selector: (state) => state.unreadCount,
          builder: (context, unread) => AppBottomNavBar(
            current: _current,
            onTap: _select,
            // The dots on the open tab already show what is new.
            alertsBadgeCount: _current == AppNavTab.alerts ? 0 : unread,
          ),
        ),
      ),
    );
  }
}
