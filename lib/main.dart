import 'package:flutter/material.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/routing/app_router.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const NutqApp());
}

class NutqApp extends StatelessWidget {
  const NutqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = sl<AppPreferences>();
    return MaterialApp(
      title: 'Nutq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: prefs.isLoggedIn ? Routes.jobs : Routes.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
