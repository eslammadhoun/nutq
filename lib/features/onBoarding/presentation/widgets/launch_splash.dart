import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/splash_art.dart';

/// Android's launch screen, the same as iOS's: [SplashArt] at its design size
/// (390×844, not scaled), centered on [SplashArt.gradient], in the phone's
/// theme. Android 12+ allows only an icon on a color for its own launch
/// screen, so the system shows a plain color (styles.xml) and the app this,
/// while it starts.
class LaunchSplash extends StatelessWidget {
  const LaunchSplash({super.key});

  @override
  Widget build(BuildContext context) {
    // Shown before the app's own widgets, so it reads the screen size itself:
    // empty until Android has laid out the window, and then updated.
    return MediaQuery.fromView(
      view: View.of(context),
      child: Builder(
        builder: (context) {
          final screen = MediaQuery.sizeOf(context);
          if (screen.isEmpty) return const SizedBox.shrink();
          return ScreenUtilPlusInit(
            // The design size is the screen's own, so the typography's .sp is 1
            // and the art comes out in design points, as in the iOS images.
            designSize: screen,
            builder: (_, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              home: Builder(
                builder: (context) {
                  final dark = Theme.of(context).brightness == Brightness.dark;
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
                    child: Material(
                      type: MaterialType.transparency,
                      child: DecoratedBox(
                        decoration: BoxDecoration(gradient: SplashArt.gradient(dark: dark)),
                        child: ClipRect(
                          child: OverflowBox(
                            minWidth: SplashArt.size.width,
                            maxWidth: SplashArt.size.width,
                            minHeight: SplashArt.size.height,
                            maxHeight: SplashArt.size.height,
                            child: const SplashArt(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
