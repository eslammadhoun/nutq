import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/widgets/app_bottom_nav_bar.dart';
import 'package:nutq/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:nutq/features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppNavTab _current = AppNavTab.home;

  static const _tabs = [AppNavTab.home, AppNavTab.alerts, AppNavTab.profile];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabs.indexOf(_current),
        children: [
          BlocProvider<JobsCubit>(
            create: (context) => sl<JobsCubit>(),
            child: const JobsScreen(),
          ),
          AlertsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: _current,
        onTap: (tab) => setState(() => _current = tab),
      ),
    );
  }
}
