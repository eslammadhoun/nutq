import 'package:flutter/material.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/onBoarding/presentation/screens/on_boarding_screen.dart';
import 'package:nutq/features/onBoarding/presentation/screens/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case Routes.onboarding:
        return MaterialPageRoute(builder: (context) => OnBoardingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
