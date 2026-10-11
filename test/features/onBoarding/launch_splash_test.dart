import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/launch_splash.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/splash_art.dart';

void main() {
  for (final size in [const Size(411, 914), const Size(360, 640)]) {
    testWidgets('draws the iOS launch art at its design size on a $size screen', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const LaunchSplash());

      expect(tester.getSize(find.byType(SplashArt)), SplashArt.size);
      expect(tester.getCenter(find.byType(SplashArt)), size.center(Offset.zero));
      expect(tester.getSize(find.text('Nutq')).height, closeTo(52, 1), reason: 'type at 1:1');
    });
  }
}
