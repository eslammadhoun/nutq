import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/ai_models/presentation/cubit/model_download_cubit.dart';
import 'package:nutq/features/ai_models/presentation/widgets/model_download_panel.dart';
import 'package:nutq/l10n/app_localizations.dart';

import 'support/fake_model_repository.dart';

Future<(FakeModelRepository, List<String>)> _pump(
  WidgetTester tester, {
  required Locale locale,
  required ThemeData theme,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final models = FakeModelRepository();
  final cubit = ModelDownloadCubit(models, models.requiredFor(.audio, .ar));
  addTearDown(cubit.close);
  final done = <String>[];
  await tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        theme: theme,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: ModelDownloadPanel(title: 'title', onDone: () => done.add('done')),
          ),
        ),
      ),
    ),
  );
  return (models, done);
}

void main() {
  testWidgets('download, pause, resume, retry, then continue', (tester) async {
    final (models, done) = await _pump(tester, locale: const Locale('en'), theme: AppTheme.light);

    expect(find.textContaining('631 MB'), findsWidgets, reason: 'the total size');
    expect(find.text('Wi-Fi recommended'), findsOneWidget);

    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(models.downloads, ['gemma', 'moonshine-ar']);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);

    models.fail('gemma', AppError.modelDownloadNoSpace);
    await tester.pump();
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('Not enough free space'), findsOneWidget);

    models
      ..finish('gemma')
      ..finish('moonshine-ar');
    await tester.pump();
    expect(find.text('The models are ready'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    expect(done, ['done']);
  });

  testWidgets('Arabic, dark', (tester) async {
    await _pump(tester, locale: const Locale('ar'), theme: AppTheme.dark);

    expect(find.text('تنزيل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
