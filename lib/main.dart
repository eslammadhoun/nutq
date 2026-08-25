import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/routing/app_router.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const NutqApp());
}

class NutqApp extends StatelessWidget {
  const NutqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocaleCubit>.value(
      value: sl<LocaleCubit>(),
      child: ScreenUtilPlusInit(
        // Figma frames are 390×844 (iPhone 14).
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) =>
            BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) => MaterialApp(
                title: 'Nutq',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: ThemeMode.system,
                locale: locale,
                supportedLocales: supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                initialRoute: Routes.splash,
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
    );
  }
}
