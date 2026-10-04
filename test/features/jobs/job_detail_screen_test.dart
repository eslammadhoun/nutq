import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
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
import 'package:nutq/l10n/app_localizations.dart';

import 'support/job_harness.dart';

Future<void> _pump(
  WidgetTester tester,
  JobDetailCubit cubit, {
  Locale locale = const Locale('en'),
}) async {
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

/// The queue runs jobs in real time, outside the widget test's fake clock: let
/// real time pass, then render what changed.
Future<void> advance(WidgetTester tester, int milliseconds) async {
  await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: milliseconds)));
  await tester.pump();
}

void main() {
  late JobHarness h;

  setUp(() => h = JobHarness(autoStart: false));
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
    bool queued = true,
  }) async {
    await tester.runAsync(h.runner.start);
    final id = (await tester.runAsync(
      () => queued ? h.submit(text, language: language) : h.createJob(text, language: language),
    ))!;
    if (seed != null) await tester.runAsync(() => seed(id));
    final cubit = h.detailCubit(id);
    addTearDown(cubit.close);
    await _pump(tester, cubit, locale: locale);
    await advance(tester, 50);
    return cubit;
  }

  /// Lets real time pass until the job reaches a final state, then renders.
  Future<void> untilSettled(WidgetTester tester, JobDetailCubit cubit) async {
    for (var i = 0; i < 300 && !(cubit.state.job?.status.isTerminal ?? false); i++) {
      await advance(tester, 20);
    }
    await advance(tester, 100);
  }

  testWidgets('shows the live progress card while running, then the finished summary', (
    tester,
  ) async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return 'النقطة رقم $call من المحاضرة.';
    };
    final cubit = await open(tester, sampleTranscript);
    await advance(tester, 50);

    expect(find.byType(JobProgressCard), findsOneWidget);
    expect(find.text('Processing'), findsWidgets);
    expect(find.textContaining(RegExp(r'^\d+ of \d+ sections$')), findsOneWidget);
    expect(find.text('Cancel Job'), findsOneWidget);
    expect(find.text("The summary isn't ready yet."), findsOneWidget);
    final barBefore = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;

    gate.complete();
    await untilSettled(tester, cubit);

    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Summary Complete'), findsOneWidget);
    expect(find.text(cubit.state.job!.summary!.summaryText), findsOneWidget);
    expect(find.text('KEY TAKEAWAYS'), findsNothing, reason: 'the pipeline writes no takeaways');
    expect(find.text('Copy Text'), findsOneWidget);
    expect(find.text('Cancel Job'), findsNothing);
    expect(barBefore, lessThan(1.0));
  });

  testWidgets(
    'a reopened finished job shows its stored summary with no progress and no model run',
    (tester) async {
      final first = await open(tester, sampleTranscript);
      await untilSettled(tester, first);
      final id = first.jobId;
      final callsAfterFirst = h.gemma.calls;

      final reopened = h.detailCubit(id);
      addTearDown(reopened.close);
      await _pump(tester, reopened);
      await advance(tester, 100);

      expect(find.byType(JobProgressCard), findsNothing);
      expect(find.text(first.state.job!.summary!.summaryText), findsOneWidget);
      expect(find.text('Summary Complete'), findsOneWidget);
      expect(h.gemma.calls, callsAfterFirst);
    },
  );

  testWidgets('an interrupted job shows a localized notice, not raw error text', (tester) async {
    final cubit = await open(
      tester,
      sampleTranscript,
      queued: false,
      seed: (id) async {
        await h.repo.markRunning(id);
        await h.repo.recoverInterruptedJobs();
      },
    );
    await advance(tester, 100);

    expect(cubit.state.job!.failureKind, JobFailureKind.interrupted);
    expect(
      find.text('This job was interrupted because the app was closed before it finished.'),
      findsOneWidget,
    );
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Failed'), findsWidgets);
    expect(h.gemma.calls, 0);
  });

  testWidgets('renders the failure notice in Arabic (RTL)', (tester) async {
    await open(
      tester,
      sampleTranscript,
      locale: const Locale('ar'),
      queued: false,
      seed: (id) async {
        await h.repo.markRunning(id);
        await h.repo.recoverInterruptedJobs();
      },
    );
    await advance(tester, 100);

    expect(find.text('توقفت هذه المهمة لأن التطبيق أُغلق قبل أن تنتهي.'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(JobDetailScreen))), TextDirection.rtl);
  });

  testWidgets('a missing job shows a "no longer exists" message', (tester) async {
    final cubit = h.detailCubit('nope');
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await advance(tester, 100);
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
    await advance(tester, 50);

    await tester.tap(find.text('Cancel Job'));
    await advance(tester, 20);
    expect(h.gemma.cancelled, isTrue);

    gate.complete();
    await untilSettled(tester, cubit);
    expect(cubit.state.job!.status, JobRunStatus.cancelled);
    expect(find.byType(JobProgressCard), findsNothing);
    expect(find.text('Cancelled'), findsWidgets);
  });

  testWidgets('summary text appears word by word, fully expanded, while the job runs', (
    tester,
  ) async {
    const longFinal =
        'الملخص النهائي يشرح الفكرة الرئيسية للمحاضرة ثم ينتقل إلى النقاط المهمة والأرقام والتواريخ ويختم بالخلاصة والتوصيات النهائية للمستمعين في نهاية اللقاء';
    h.gemma.wordDelay = const Duration(milliseconds: 30);
    h.gemma.responder = (prompt, call) async => call == 1 ? longFinal : 'النقطة رقم $call.';
    final cubit = await open(tester, sampleTranscript);

    final seen = <String>[];
    for (var i = 0; i < 400 && !(cubit.state.job?.status.isTerminal ?? false); i++) {
      await advance(tester, 20);
      // Render anything the last frame's microtasks emitted, so the screen and
      // the state being compared are the same emission.
      await tester.pump();
      final live = cubit.state.streamingSummary;
      if (live != null &&
          !(cubit.state.job?.status.isTerminal ?? false) &&
          (seen.isEmpty || seen.last != live)) {
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
    expect(cubit.state.job!.status, JobRunStatus.completed);
    expect(cubit.state.job!.summary!.summaryText, startsWith(longFinal));
    expect(find.text(cubit.state.job!.summary!.summaryText), findsOneWidget);
    expect(
      find.descendant(of: find.byType(SummaryCard), matching: find.text('Show more')),
      findsNothing,
    );
  });

  testWidgets('completed state matches the Figma Job Detail measurements and colors', (
    tester,
  ) async {
    final cubit = await open(tester, sampleTranscript);
    await untilSettled(tester, cubit);
    expect(cubit.state.job!.status, JobRunStatus.completed);

    final colors = AppTheme.light.extension<AppColors>()!;

    final hero = tester.getSize(find.byType(JobStatusHeroCard));
    expect(hero.width, 358);
    expect(hero.height, greaterThanOrEqualTo(132));

    final cardBox =
        tester
                .widget<Container>(
                  find
                      .descendant(
                        of: find.byType(JobDetailSectionCard).first,
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(cardBox.color, colors.surface);
    expect(cardBox.border, isNull);
    expect(cardBox.borderRadius, BorderRadius.circular(16));
    expect(cardBox.boxShadow!.single.blurRadius, 12);
    expect(cardBox.boxShadow!.single.offset, const Offset(0, 2));
    expect(cardBox.boxShadow!.single.color.a, closeTo(0.05, 0.001));

    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, colors.page);
    final appBar = tester.widget<Container>(
      find.descendant(of: find.byType(JobDetailAppBar), matching: find.byType(Container)).first,
    );
    expect((appBar.decoration! as BoxDecoration).color, colors.surface);
    expect(tester.getSize(find.byType(JobDetailAppBar)).height, 56);

    expect(tester.getSize(find.byType(JobDetailActionBar)).height, 72);
    final copy = tester.widget<Container>(
      find.ancestor(of: find.text('Copy Text'), matching: find.byType(Container)).first,
    );
    expect((copy.decoration! as BoxDecoration).color, colors.navIndicator);
    expect(colors.navIndicator, const Color(0xFF1A56DB));
    final share = tester.widget<Container>(
      find.ancestor(of: find.text('Share'), matching: find.byType(Container)).first,
    );
    expect((share.decoration! as BoxDecoration).color, colors.borderDefault);

    final language = find.ancestor(of: find.text('Arabic'), matching: find.byType(Container)).first;
    expect(tester.getSize(language).height, 26);
    expect(
      (tester.widget<Container>(language).decoration! as BoxDecoration).color,
      colors.statusProcessingBg,
    );
    final tone = find.ancestor(of: find.text('Medium'), matching: find.byType(Container)).first;
    expect(
      (tester.widget<Container>(tone).decoration! as BoxDecoration).color,
      colors.statusDoneBg,
    );
  });

  group('text direction follows the job language, not the app locale', () {
    const cardPad = 16.0;
    const headerTextInset = 28.0;

    testWidgets(
      'Arabic job in an English app: transcript and summary start from the right',
      (tester) async {
        // One section: long enough to be summarized, short enough for one call.
        const transcript =
            'ناقش الاجتماع ميزانية العام القادم وخطط التوظيف في الأقسام الثلاثة، '
            'واتفق المديرون على زيادة الإنفاق على التدريب وتأجيل المشاريع الجديدة.';
        const summary = 'ملخص قصير.';
        h.gemma.responder = (prompt, call) async => summary;
        final cubit = await open(tester, transcript);
        await untilSettled(tester, cubit);
        expect(cubit.state.job!.status, JobRunStatus.completed);

        final transcriptCard = find.byType(TranscriptCard);
        final summaryCard = find.byType(SummaryCard);
        final tRight = tester.getTopRight(transcriptCard).dx - cardPad;
        final sRight = tester.getTopRight(summaryCard).dx - cardPad;

        expect(tester.getTopRight(find.text(transcript)).dx, closeTo(tRight, 1));
        expect(tester.getTopRight(find.text(summary)).dx, closeTo(sRight, 1));

        expect(
          tester.getTopLeft(find.text('AI Summary')).dx,
          closeTo(tester.getTopLeft(summaryCard).dx + cardPad + headerTextInset, 1),
        );
        expect(
          tester.getTopLeft(find.text('Transcript')).dx,
          closeTo(tester.getTopLeft(transcriptCard).dx + cardPad + headerTextInset, 1),
        );
      },
    );

    testWidgets(
      'English job in an Arabic app: transcript and summary start from the left',
      (tester) async {
        // One section: long enough to be summarized, short enough for one call.
        const transcript =
            'The meeting discussed next year budget and hiring plans across the three '
            'departments, and the managers agreed to spend more on training.';
        const summary = 'Short summary.';
        h.gemma.responder = (prompt, call) async => summary;
        final cubit = await open(
          tester,
          transcript,
          language: ContentLanguage.en,
          locale: const Locale('ar'),
        );
        await untilSettled(tester, cubit);
        expect(cubit.state.job!.status, JobRunStatus.completed);

        final transcriptCard = find.byType(TranscriptCard);
        final summaryCard = find.byType(SummaryCard);
        final tLeft = tester.getTopLeft(transcriptCard).dx + cardPad;
        final sLeft = tester.getTopLeft(summaryCard).dx + cardPad;

        expect(tester.getTopLeft(find.text(transcript)).dx, closeTo(tLeft, 1));
        expect(tester.getTopLeft(find.text(summary)).dx, closeTo(sLeft, 1));

        final summaryHeaderRight = tester.getTopRight(summaryCard).dx - cardPad - headerTextInset;
        expect(
          tester.getTopRight(find.text('ملخص الذكاء الاصطناعي')).dx,
          closeTo(summaryHeaderRight, 1),
        );
      },
    );

    test('jobTextDirection maps job language codes', () {
      expect(jobTextDirection('ar'), TextDirection.rtl);
      expect(jobTextDirection('en'), TextDirection.ltr);
      expect(jobTextDirection('unknown'), TextDirection.ltr);
    });
  });

  testWidgets('a streamed word rebuilds the summary but never the transcript (rebuild scoping)', (
    tester,
  ) async {
    final cubit = await open(tester, sampleTranscript);
    await untilSettled(tester, cubit);

    final rebuilds = <Type, int>{};
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      final type = element.widget.runtimeType;
      if (type == TranscriptCard ||
          type == SummaryCard ||
          type == JobStatusHeroCard ||
          type == JobProgressCard) {
        rebuilds[type] = (rebuilds[type] ?? 0) + 1;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);

    for (var i = 1; i <= 10; i++) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      cubit.emit(cubit.state.copyWith(streamingSummary: List.filled(i, 'الملخص').join(' ')));
      await tester.pump();
    }

    expect(
      rebuilds[SummaryCard],
      greaterThan(0),
      reason: 'the summary follows the streamed updates',
    );
    expect(rebuilds[TranscriptCard], isNull, reason: 'the (possibly huge) transcript is untouched');
    expect(rebuilds[JobStatusHeroCard], isNull);
  });

  testWidgets('progress ticks rebuild only the progress card', (tester) async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 2) await gate.future;
      return null;
    };
    final cubit = await open(tester, sampleTranscript);
    await advance(tester, 100);
    expect(find.byType(JobProgressCard), findsOneWidget);

    final rebuilds = <Type, int>{};
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      final type = element.widget.runtimeType;
      if (type == TranscriptCard || type == SummaryCard || type == JobProgressCard) {
        rebuilds[type] = (rebuilds[type] ?? 0) + 1;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);

    for (var i = 1; i <= 5; i++) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      cubit.emit(
        cubit.state.copyWith(
          progress: JobProgress(JobStage.analyzing, fraction: 0.1 * i, done: i, total: 10),
        ),
      );
      await tester.pump();
    }
    expect(rebuilds[JobProgressCard], greaterThanOrEqualTo(5));
    expect(rebuilds[TranscriptCard], isNull);
    expect(rebuilds[SummaryCard], isNull);
    gate.complete();
  });

  testWidgets('a job deleted while the screen is open switches to the "no longer exists" message', (
    tester,
  ) async {
    final cubit = await open(tester, sampleTranscript);
    await untilSettled(tester, cubit);
    expect(find.byType(TranscriptCard), findsOneWidget);

    await tester.runAsync(() => h.repo.deleteJob(cubit.jobId));
    await advance(tester, 100);
    expect(find.text('This job no longer exists.'), findsOneWidget);
    expect(find.byType(TranscriptCard), findsNothing);
  });
}
