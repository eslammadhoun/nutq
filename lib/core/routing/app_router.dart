import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutq/features/auth/presentation/ui/login/screens/login_screen.dart';
import 'package:nutq/features/auth/presentation/ui/register/screens/register_screen.dart';
import 'package:nutq/features/home/presentation/screens/home_screen.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/onBoarding/presentation/screens/on_boarding_screen.dart';
import 'package:nutq/features/onBoarding/presentation/screens/splash_screen.dart';

class AppRouter {
  /// Global access to the navigator for imperative navigation from
  /// non-widget code (e.g. the session-expiry listener in main.dart).
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(settings, const SplashScreen());

      case Routes.onboarding:
        return _buildRoute(settings, const OnBoardingScreen());

      case Routes.login:
        return _buildRoute(
          settings,
          BlocProvider<AuthCubit>(
            create: (context) => sl<AuthCubit>(),
            child: LoginScreen(),
          ),
        );

      case Routes.register:
        return _buildRoute(
          settings,
          BlocProvider<AuthCubit>(
            create: (context) => sl<AuthCubit>(),
            child: RegisterScreen(),
          ),
        );

      case Routes.home:
        return _buildRoute(
          settings,
          BlocProvider<JobsCubit>(
            create: (context) => sl<JobsCubit>(),
            child: const HomeScreen(),
          ),
        );
      default:
        return _buildRoute(
          settings,
          Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => Text(context.l10n.routeNotFound),
              ),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,

      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 150),

      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
