import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/routing/app_router.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/core/theme/theme_cubit.dart';
import 'package:nutq/features/jobs/domain/services/job_runner.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const NutqApp());
  // After the first frame: recover jobs an earlier session left running, then
  // start processing the queue. Nothing here delays startup.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(sl<JobRunner>().start()),
  );
}

class NutqApp extends StatelessWidget {
  const NutqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
      ],
      child: ScreenUtilPlusInit(
        // Figma frames are 390×844 (iPhone 14).
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) => MaterialApp(
              title: 'Nutq',
              debugShowCheckedModeBanner: false,
              navigatorKey: AppRouter.navigatorKey,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // No splash screen of its own: the system launch screen shows
              // SplashArt until the first frame, then this route.
              initialRoute: sl<AppPreferences>().hasSeenOnboarding
                  ? Routes.home
                  : Routes.onboarding,
              // Just that route; by default Flutter would also push '/' under it.
              onGenerateInitialRoutes: (name) => [
                AppRouter.generateRoute(RouteSettings(name: name)),
              ],
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                final bool isDark = context.isDark;
                return DecoratedBox(
                  decoration: AppTheme.backgroundDecoration(isDark),
                  child: child!,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
