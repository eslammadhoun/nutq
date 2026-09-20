import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_action_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_app_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_progress_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_status_hero_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/summary_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/transcript_card.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/l10n/app_localizations.dart';

import 'support/job_harness.dart';

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
  late JobHarness h;

  setUp(() => h = JobHarness());
  tearDown(() async {
    // Let the cubit close (and its cancellation write) finish before the db closes.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await h.dispose();
  });

  /// Seeds a job in the database, then opens the screen on it (which starts a
  /// pending job).
  Future<JobDetailCubit> open(
    WidgetTester tester,
    String text, {
    ContentLanguage language = ContentLanguage.ar,
    Locale locale = const Locale('en'),
    Future<void> Function(String id)? seed,
  }) async {
    final id = (await tester.runAsync(() => h.createJob(text, language: language)))!;
    if (seed != null) await tester.runAsync(() => seed(id));
    final cubit = h.detailCubit(id);
    addTearDown(cubit.close);
    await _pump(tester, cubit, locale: locale);
    await tester.pump(const Duration(milliseconds: 50));
    return cubit;
  }

  /// Pumps until the job reaches a final state.
  Future<void> untilSettled(WidgetTester tester, JobDetailCubit cubit) async {
    for (var i = 0; i < 200 && !(cubit.state.job?.status.isTerminal ?? false); i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('shows the live progress card while running, then the finished summary', (tester) async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 3) await gate.future;
      return null;
    };
    final cubit = await open(tester, sampleTranscript);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(JobProgressCard), findsOneWidget);
    expect(find.text('Processing'), findsWidgets);
    expect(find.textContaining('sections'), findsOneWidget);
    expect(find.text('Cancel Job'), findsOneWidget);
    expect(find.text("The summary isn't ready yet."), findsOneWidget);
    final barBefore = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;

    gate.complete();
    await untilSettled(tester, cubit);

    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Summary Complete'), findsOneWidget);
    expect(find.text('الملخص النهائي للمحاضرة'), findsOneWidget);
    expect(find.text('فكرة رئيسية عن الموضوع'), findsOneWidget);
    expect(find.text('Copy Text'), findsOneWidget);
    expect(find.text('Cancel Job'), findsNothing);
    expect(barBefore, lessThan(1.0));
  });

  testWidgets('a reopened finished job shows its stored summary with no progress and no model run', (tester) async {
    final first = await open(tester, sampleTranscript);
    await untilSettled(tester, first);
    final id = first.jobId;
    final callsAfterFirst = h.gemma.calls;

    final reopened = h.detailCubit(id);
    addTearDown(reopened.close);
    await _pump(tester, reopened);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('الملخص النهائي للمحاضرة'), findsOneWidget);
    expect(find.text('Summary Complete'), findsOneWidget);
    expect(h.gemma.calls, callsAfterFirst);
  });

  testWidgets('an interrupted job shows a localized notice, not raw error text', (tester) async {
    final cubit = await open(
      tester,
      sampleTranscript,
      seed: (id) async {
        await h.repo.markRunning(id);
        await h.repo.recoverInterruptedJobs();
      },
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(cubit.state.job!.failureKind, JobFailureKind.interrupted);
    expect(find.text('This job was interrupted because the app was closed before it finished.'), findsOneWidget);
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Failed'), findsWidgets);
    expect(h.gemma.calls, 0);
  });

  testWidgets('renders the failure notice in Arabic (RTL)', (tester) async {
    await open(
      tester,
      sampleTranscript,
      locale: const Locale('ar'),
      seed: (id) async {
        await h.repo.markRunning(id);
        await h.repo.recoverInterruptedJobs();
      },
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('توقفت هذه المهمة لأن التطبيق أُغلق قبل أن تنتهي.'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(JobDetailScreen))), TextDirection.rtl);
  });

  testWidgets('a missing job shows a "no longer exists" message', (tester) async {
    final cubit = h.detailCubit('nope');
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('This job no longer exists.'), findsOneWidget);
    expect(find.byType(JobStatusHeroCard), findsNothing);
  });

  testWidgets('tapping Cancel Job ends in the cancelled state', (tester) async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    final cubit = await open(tester, sampleTranscript);
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Cancel Job'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(h.gemma.cancelled, isTrue);

    gate.complete();
    await untilSettled(tester, cubit);
    expect(cubit.state.job!.status, JobRunStatus.cancelled);
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Cancelled'), findsWidgets);
  });

  testWidgets('summary text appears word by word, fully expanded, while the job runs', (tester) async {
    const longFinal =
        'الملخص النهائي يشرح الفكرة الرئيسية للمحاضرة ثم ينتقل إلى النقاط المهمة والأرقام والتواريخ ويختم بالخلاصة والتوصيات النهائية للمستمعين في نهاية اللقاء';
    h.gemma.wordDelay = const Duration(milliseconds: 30);
    h.gemma.responder = (prompt, call) async =>
        prompt.contains('final summary of a full lecture') ? longFinal : null;
    final cubit = await open(tester, sampleTranscript);

    final seen = <String>[];
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      final live = cubit.state.streamingSummary;
      if (live != null && !(cubit.state.job?.status.isTerminal ?? false) && (seen.isEmpty || seen.last != live)) {
        seen.add(live);
        expect(find.text(live), findsOneWidget, reason: 'partial text is on screen: "$live"');
        expect(
          find.descendant(of: find.byType(SummaryCard), matching: find.text('Show more')),
          findsNothing,
          reason: 'streaming summary text is never collapsed',
        );
      }
    }
    await tester.pump(const Duration(milliseconds: 400));

    expect(seen, isNotEmpty);
    expect(find.text(longFinal), findsOneWidget);
    expect(cubit.state.job!.status, JobRunStatus.completed);
    expect(find.descendant(of: find.byType(SummaryCard), matching: find.text('Show more')), findsNothing);
  });

  testWidgets('completed state matches the Figma Job Detail measurements and colors', (tester) async {
    final cubit = await open(tester, sampleTranscript);
    await untilSettled(tester, cubit);
    expect(cubit.state.job!.status, JobRunStatus.completed);

    final colors = AppTheme.light.extension<AppColors>()!;

    final hero = tester.getSize(find.byType(JobStatusHeroCard));
    expect(hero.width, 358);
    expect(hero.height, greaterThanOrEqualTo(132));

    final cardBox = tester
        .widget<Container>(find.descendant(of: find.byType(JobDetailSectionCard).first, matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(cardBox.color, colors.surface);
    expect(cardBox.border, isNull);
    expect(cardBox.borderRadius, BorderRadius.circular(16));
    expect(cardBox.boxShadow!.single.blurRadius, 12);
    expect(cardBox.boxShadow!.single.offset, const Offset(0, 2));
    expect(cardBox.boxShadow!.single.color.a, closeTo(0.05, 0.001));

    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, colors.page);
    final appBar = tester.widget<Container>(find.descendant(of: find.byType(JobDetailAppBar), matching: find.byType(Container)).first);
    expect((appBar.decoration! as BoxDecoration).color, colors.surface);
    expect(tester.getSize(find.byType(JobDetailAppBar)).height, 56);

    expect(tester.getSize(find.byType(JobDetailActionBar)).height, 72);
    final copy = tester.widget<Container>(find.ancestor(of: find.text('Copy Text'), matching: find.byType(Container)).first);
    expect((copy.decoration! as BoxDecoration).color, colors.navIndicator);
    expect(colors.navIndicator, const Color(0xFF1A56DB));
    final share = tester.widget<Container>(find.ancestor(of: find.text('Share'), matching: find.byType(Container)).first);
    expect((share.decoration! as BoxDecoration).color, colors.borderDefault);

    final language = find.ancestor(of: find.text('Arabic'), matching: find.byType(Container)).first;
    expect(tester.getSize(language).height, 26);
    expect((tester.widget<Container>(language).decoration! as BoxDecoration).color, colors.statusProcessingBg);
    final tone = find.ancestor(of: find.text('Medium'), matching: find.byType(Container)).first;
    expect((tester.widget<Container>(tone).decoration! as BoxDecoration).color, colors.statusDoneBg);
  });

  group('text direction follows the job language, not the app locale', () {
    const cardPad = 16.0;
    const chipPad = 12.0;
    const headerTextInset = 28.0;

    testWidgets('Arabic job in an English app: transcript, summary and takeaways start from the right', (tester) async {
      const transcript = 'نص قصير.';
      const summary = 'ملخص قصير.';
      h.gemma.responder = (prompt, call) async {
        if (prompt.contains('information extraction assistant')) return 'MAIN:\nنقطة رئيسية';
        if (prompt.contains('final summary of a full lecture')) return summary;
        return null;
      };
      final cubit = await open(tester, transcript);
      await untilSettled(tester, cubit);
      expect(cubit.state.job!.status, JobRunStatus.completed);

      final transcriptCard = find.byType(TranscriptCard);
      final summaryCard = find.byType(SummaryCard);
      final tRight = tester.getTopRight(transcriptCard).dx - cardPad;
      final sRight = tester.getTopRight(summaryCard).dx - cardPad;

      expect(tester.getTopRight(find.text(transcript)).dx, closeTo(tRight, 1));
      expect(tester.getTopRight(find.text(summary)).dx, closeTo(sRight, 1));
      expect(tester.getTopRight(find.text('نقطة رئيسية')).dx, closeTo(sRight - chipPad, 1));
      expect(tester.getTopRight(find.text('KEY TAKEAWAYS')).dx, closeTo(sRight, 1));

      expect(tester.getTopLeft(find.text('AI Summary')).dx, closeTo(tester.getTopLeft(summaryCard).dx + cardPad + headerTextInset, 1));
      expect(tester.getTopLeft(find.text('Transcript')).dx, closeTo(tester.getTopLeft(transcriptCard).dx + cardPad + headerTextInset, 1));
    });

    testWidgets('English job in an Arabic app: transcript, summary and takeaways start from the left', (tester) async {
      const transcript = 'Short text.';
      const summary = 'Short summary.';
      h.gemma.responder = (prompt, call) async {
        if (prompt.contains('information extraction assistant')) return 'MAIN:\nKey point';
        if (prompt.contains('final summary of a full lecture')) return summary;
        return null;
      };
      final cubit = await open(tester, transcript, language: ContentLanguage.en, locale: const Locale('ar'));
      await untilSettled(tester, cubit);
      expect(cubit.state.job!.status, JobRunStatus.completed);

      final transcriptCard = find.byType(TranscriptCard);
      final summaryCard = find.byType(SummaryCard);
      final tLeft = tester.getTopLeft(transcriptCard).dx + cardPad;
      final sLeft = tester.getTopLeft(summaryCard).dx + cardPad;

      expect(tester.getTopLeft(find.text(transcript)).dx, closeTo(tLeft, 1));
      expect(tester.getTopLeft(find.text(summary)).dx, closeTo(sLeft, 1));
      expect(tester.getTopLeft(find.text('Key point')).dx, closeTo(sLeft + chipPad, 1));
      expect(tester.getTopLeft(find.text('أبرز النقاط')).dx, closeTo(sLeft, 1));

      final summaryHeaderRight = tester.getTopRight(summaryCard).dx - cardPad - headerTextInset;
      expect(tester.getTopRight(find.text('ملخص الذكاء الاصطناعي')).dx, closeTo(summaryHeaderRight, 1));
    });

    test('jobTextDirection maps job language codes', () {
      expect(jobTextDirection('ar'), TextDirection.rtl);
      expect(jobTextDirection('en'), TextDirection.ltr);
      expect(jobTextDirection('unknown'), TextDirection.ltr);
    });
  });
}
