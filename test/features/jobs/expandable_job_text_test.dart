import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/expandable_job_text.dart';
import 'package:nutq/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
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
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: child))),
      ),
    ),
  );
}

ExpandableJobText _text(String text, {bool force = false}) => ExpandableJobText(
  text,
  style: const TextStyle(fontSize: 15),
  textDirection: TextDirection.ltr,
  forceExpanded: force,
);

String _shownText(WidgetTester tester) => tester.widget<Text>(find.byType(Text).first).data!;

void main() {
  final huge = List.generate(60000, (i) => 'word$i').join(' '); // ~500 KB

  testWidgets('short text is shown as is, with no toggle', (tester) async {
    await _pump(tester, _text('a short line'));
    expect(find.text('a short line'), findsOneWidget);
    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('a long transcript collapses to a bounded preview, never the whole text', (tester) async {
    await _pump(tester, _text(huge));
    final shown = _shownText(tester);
    expect(shown.length, lessThanOrEqualTo(ExpandableJobText.previewChars));
    expect(huge.startsWith(shown), isTrue, reason: 'the preview is the start of the text');
    expect(find.text('Show more'), findsOneWidget, reason: 'text longer than the preview always offers expansion');
  });

  testWidgets('the preview is cut at a word boundary, never mid-word', (tester) async {
    await _pump(tester, _text(huge));
    final shown = _shownText(tester);
    final rest = huge.substring(shown.length);
    expect(rest.startsWith(' ') || shown.endsWith(' '), isTrue, reason: 'cut between words');
    expect(RegExp(r'word\d+$').hasMatch(shown), isTrue, reason: 'the last word is whole');
  });

  testWidgets('tapping expands to the full text and back', (tester) async {
    await _pump(tester, _text(huge));
    await tester.tap(find.text('Show more'));
    await tester.pump();
    expect(_shownText(tester), huge);
    expect(find.text('Show less'), findsOneWidget);

    await tester.tapAt(const Offset(40, 40)); // the toggle itself is off-screen for a huge text; the whole block is tappable
    await tester.pump();
    expect(_shownText(tester).length, lessThanOrEqualTo(ExpandableJobText.previewChars));
  });

  testWidgets('text just over four lines but under the preview limit still gets a toggle', (tester) async {
    final medium = List.filled(120, 'word').join(' '); // ~600 chars, many lines
    await _pump(tester, _text(medium));
    expect(find.text('Show more'), findsOneWidget);
    expect(_shownText(tester), medium, reason: 'under the limit, the whole text is the (ellipsized) collapsed text');
  });

  testWidgets('a text with no spaces is still cut safely', (tester) async {
    final noSpaces = 'ا' * 5000;
    await _pump(tester, _text(noSpaces));
    expect(_shownText(tester).length, ExpandableJobText.previewChars);
  });

  testWidgets('forceExpanded shows everything with no toggle (streaming text)', (tester) async {
    await _pump(tester, _text(huge, force: true));
    expect(_shownText(tester), huge);
    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('Arabic text is cut without splitting characters', (tester) async {
    final arabic = List.generate(3000, (i) => 'المشروع$i').join(' ');
    await _pump(tester, _text(arabic));
    final shown = _shownText(tester);
    expect(arabic.startsWith(shown), isTrue);
    expect(shown.runes.every((r) => r != 0xFFFD), isTrue);
  });
}
