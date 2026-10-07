import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/core/widgets/app_bottom_nav_bar.dart';
import 'package:nutq/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, {required int badge}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            current: AppNavTab.home,
            onTap: (_) {},
            alertsBadgeCount: badge,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('no badge without unread alerts', (tester) async {
    await _pump(tester, badge: 0);
    expect(find.text('0'), findsNothing);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('the badge shows the unread count, capped at 9+', (tester) async {
    await _pump(tester, badge: 2);
    expect(find.text('2'), findsOneWidget);

    await _pump(tester, badge: 12);
    expect(find.text('9+'), findsOneWidget);
  });
}
