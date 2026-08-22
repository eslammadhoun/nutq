import 'package:flutter/material.dart';
import 'package:nutq/core/widgets/app_bottom_nav_bar.dart';
import 'package:nutq/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:nutq/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:nutq/features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppNavTab _current = AppNavTab.home;

  static const _tabs = [
    AppNavTab.home,
    AppNavTab.alerts,
    AppNavTab.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabs.indexOf(_current),
        children: const [JobsScreen(), AlertsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: _current,
        onTap: (tab) => setState(() => _current = tab),
      ),
    );
  }
}
