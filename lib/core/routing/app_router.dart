import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/home/presentation/screens/home_screen.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:nutq/features/models/presentation/cubit/models_cubit.dart';
import 'package:nutq/features/models/presentation/screens/models_screen.dart';
import 'package:nutq/features/onBoarding/presentation/screens/on_boarding_screen.dart';
import 'package:nutq/features/onBoarding/presentation/screens/splash_screen.dart';
import 'package:nutq/features/summarization/presentation/bloc/summarization_bloc.dart';
import 'package:nutq/features/summarization/presentation/pages/summarization_page.dart';

class AppRouter {
  /// Global access to the navigator for imperative navigation from
  /// non-widget code.
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(settings, const SplashScreen());

      case Routes.onboarding:
        return _buildRoute(settings, const OnBoardingScreen());

      case Routes.home:
        return _buildRoute(settings, HomeScreen());

      case Routes.jobDetail:
        return _buildRoute(
          settings,
          BlocProvider<JobDetailCubit>(
            create: (_) => sl<JobDetailCubit>(),
            child: const JobDetailScreen(),
          ),
        );
      case Routes.models:
        return _buildRoute(
          settings,
          BlocProvider<ModelsCubit>(
            create: (_) => sl<ModelsCubit>(),
            child: const ModelsScreen(),
          ),
        );

      case Routes.summarization:
        return _buildRoute(
          settings,
          BlocProvider<SummarizationBloc>(
            create: (_) => sl<SummarizationBloc>(),
            child: const SummarizationPage(),
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
