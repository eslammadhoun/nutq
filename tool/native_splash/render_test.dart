// Renders the iOS launch screen images from SplashArt.
//
//   flutter test tool/native_splash/render_test.dart
//
// Writes two image sets, each with a dark variant:
// - LaunchImage: SplashArt (390×844pt, transparent), centered on screen by
//   LaunchScreen.storyboard.
// - LaunchGradient: the design's background gradient, stretched to fill the
//   screen behind it.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/splash_art.dart';

const _assets = 'ios/Runner/Assets.xcassets';

/// The design's background, bottom to top (Figma "Splash — Light" / "Dark").
const _lightGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [Color(0xFFE8F0FE), Color(0xFFF3F7FF), Color(0xFFFFFFFF)],
);
const _darkGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [Color(0xFF0B1120), Color(0xFF111827), Color(0xFF0F1729)],
  stops: [0, 0.6, 1],
);

Future<void> _loadFonts() async {
  final families = {
    'Inter': ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'],
    'NotoSansArabic': ['Regular', 'Medium', 'SemiBold', 'Bold'],
  };
  for (final MapEntry(key: family, value: weights) in families.entries) {
    final loader = FontLoader(family);
    for (final weight in weights) {
      final bytes = File('assets/fonts/$family-$weight.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  Future<void> render(
    WidgetTester tester, {
    required bool dark,
    required Widget child,
    required Map<String, double> outputs,
  }) async {
    // The view is the design's size, and ScreenUtil's design size equals it,
    // so the typography's .sp is 1.
    tester.view.physicalSize = SplashArt.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: SplashArt.size,
        builder: (_, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Material(
            type: MaterialType.transparency,
            child: RepaintBoundary(key: boundary, child: child),
          ),
        ),
      ),
    );
    // Let the logo's SVG load.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    for (final MapEntry(key: path, value: ratio) in outputs.entries) {
      await tester.runAsync(() async {
        final image = await render.toImage(pixelRatio: ratio);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  }

  for (final dark in [false, true]) {
    final suffix = dark ? 'Dark' : '';
    final mode = dark ? 'dark' : 'light';

    testWidgets('launch image ($mode)', (tester) async {
      await render(
        tester,
        dark: dark,
        child: const SplashArt(),
        outputs: {
          for (final (scale, name) in [(1, ''), (2, '@2x'), (3, '@3x')])
            '$_assets/LaunchImage.imageset/LaunchImage$suffix$name.png': scale.toDouble(),
        },
      );
    });

    testWidgets('launch gradient ($mode)', (tester) async {
      // A vertical gradient stretches without loss, so one size serves all.
      await render(
        tester,
        dark: dark,
        child: SizedBox.fromSize(
          size: SplashArt.size,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: dark ? _darkGradient : _lightGradient),
          ),
        ),
        outputs: {'$_assets/LaunchGradient.imageset/LaunchGradient$suffix.png': 1},
      );
    });
  }
}
