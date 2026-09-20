import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_progress_card.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:nutq/l10n/app_localizations.dart';

import '../summarization/support/fake_gemma.dart';

const _config = SummarizationConfig(targetTokens: 60, overlapTokens: 10, minTokens: 30, maxTokens: 90);
final _text = List.generate(
  6,
  (i) => 'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024.',
).join('\n\n');

Future<void> _pump(WidgetTester tester, JobDetailCubit cubit, {Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocProvider<JobDetailCubit>.value(value: cubit, child: const JobDetailScreen()),
      ),
    ),
  );
}

void main() {
  late FakeGemma gemma;

  JobDetailCubit build(String text) {
    gemma = FakeGemma();
    final repository = SummarizationRepositoryImpl(dataSource: gemma);
    return JobDetailCubit(
      summarize: SummarizeTranscript(repository: repository),
      repository: repository,
      transcript: text,
      config: _config,
    );
  }

  testWidgets('shows the live progress card while running, then the finished summary', (tester) async {
    final gate = Completer<void>();
    final cubit = build(_text);
    gemma.responder = (prompt, call) async {
      if (call == 3) await gate.future; // hold mid-way through the chunks
      return null;
    };
    addTearDown(cubit.close);

    await _pump(tester, cubit);
    await tester.pump(const Duration(milliseconds: 50));

    // Running: progress card with a stage name and section count; cancel offered.
    expect(find.byType(JobProgressCard), findsOneWidget);
    expect(find.text('Processing'), findsWidgets);
    expect(find.textContaining('sections'), findsOneWidget);
    expect(find.text('Cancel Job'), findsOneWidget);
    expect(find.text(_text.split('\n').first), findsNothing); // long text is collapsed/expandable, not raw-dumped
    expect(find.text("The summary isn't ready yet."), findsOneWidget);

    final barBefore = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;

    gate.complete();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    // Finished: progress card gone, summary + takeaway shown, share/copy offered.
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Summary Complete'), findsOneWidget);
    expect(find.text('الملخص النهائي للمحاضرة'), findsOneWidget);
    expect(find.text('فكرة رئيسية عن الموضوع'), findsOneWidget);
    expect(find.text('Copy Text'), findsOneWidget);
    expect(find.text('Cancel Job'), findsNothing);
    expect(barBefore, lessThan(1.0));
  });

  testWidgets('shows a localized failure notice, not raw error text', (tester) async {
    final cubit = build('   ');
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('There is no transcript text to summarize.'), findsOneWidget);
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Failed'), findsWidgets);
  });

  testWidgets('renders the failure notice in Arabic (RTL)', (tester) async {
    final cubit = build('   ');
    addTearDown(cubit.close);
    await _pump(tester, cubit, locale: const Locale('ar'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('لا يوجد نص لتلخيصه.'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(JobDetailScreen))), TextDirection.rtl);
  });

  testWidgets('tapping Cancel Job ends in the cancelled state', (tester) async {
    final gate = Completer<void>();
    final cubit = build(_text);
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Cancel Job'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(gemma.cancelled, isTrue);

    gate.complete();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Cancelled'), findsWidgets);
  });
}
