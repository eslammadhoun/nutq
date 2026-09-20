import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_action_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_app_bar.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_progress_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_status_hero_card.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/summary_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/transcript_card.dart';
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

  JobDetailCubit build(String text, {String language = 'ar'}) {
    gemma = FakeGemma();
    final repository = SummarizationRepositoryImpl(dataSource: gemma);
    return JobDetailCubit(
      summarize: SummarizeTranscript(repository: repository),
      repository: repository,
      transcript: text,
      language: language,
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

  testWidgets('summary text appears word by word, fully expanded, while the job runs', (tester) async {
    const longFinal =
        'الملخص النهائي يشرح الفكرة الرئيسية للمحاضرة ثم ينتقل إلى النقاط المهمة والأرقام والتواريخ ويختم بالخلاصة والتوصيات النهائية للمستمعين في نهاية اللقاء';
    final cubit = build(_text);
    gemma.wordDelay = const Duration(milliseconds: 30);
    gemma.responder = (prompt, call) async {
      if (prompt.contains('final summary of a full lecture')) return longFinal;
      return null;
    };
    addTearDown(cubit.close);
    await _pump(tester, cubit);

    // Sample the on-screen summary as the stream progresses.
    final seen = <String>[];
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      final live = cubit.state.streamingSummary;
      if (live != null && cubit.state.job!.status != 'completed' && (seen.isEmpty || seen.last != live)) {
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
    expect(cubit.state.job!.status, 'completed');
    // Once finished, the text the user watched arrive does not snap shut.
    expect(
      find.descendant(of: find.byType(SummaryCard), matching: find.text('Show more')),
      findsNothing,
    );
  });

  testWidgets('completed state matches the Figma Job Detail measurements and colors', (tester) async {
    final cubit = build(_text);
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    expect(cubit.state.job!.status, 'completed');

    final colors = AppTheme.light.extension<AppColors>()!;

    // Hero: 358 wide (16px gutters), at least 132 tall.
    final hero = tester.getSize(find.byType(JobStatusHeroCard));
    expect(hero.width, 358);
    expect(hero.height, greaterThanOrEqualTo(132));

    // Cards: white surface, 16px radius, no border, soft 5% shadow, 12px vertical padding.
    final cardBox = tester
        .widget<Container>(find.descendant(of: find.byType(JobDetailSectionCard).first, matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(cardBox.color, colors.surface);
    expect(cardBox.border, isNull);
    expect(cardBox.borderRadius, BorderRadius.circular(16));
    expect(cardBox.boxShadow!.single.blurRadius, 12);
    expect(cardBox.boxShadow!.single.offset, const Offset(0, 2));
    expect(cardBox.boxShadow!.single.color.a, closeTo(0.05, 0.001));

    // Page background is the light page tone; the top band and bottom bar are white surface.
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, colors.page);
    final appBar = tester.widget<Container>(find.descendant(of: find.byType(JobDetailAppBar), matching: find.byType(Container)).first);
    expect((appBar.decoration! as BoxDecoration).color, colors.surface);
    expect(tester.getSize(find.byType(JobDetailAppBar)).height, 56);

    // Bottom bar: 72 tall; Share is the neutral button, Copy Text the brand blue.
    expect(tester.getSize(find.byType(JobDetailActionBar)).height, 72);
    final copy = tester.widget<Container>(find.ancestor(of: find.text('Copy Text'), matching: find.byType(Container)).first);
    expect((copy.decoration! as BoxDecoration).color, colors.navIndicator);
    expect(colors.navIndicator, const Color(0xFF1A56DB));
    final share = tester.widget<Container>(find.ancestor(of: find.text('Share'), matching: find.byType(Container)).first);
    expect((share.decoration! as BoxDecoration).color, colors.borderDefault);

    // Section headers: tag chips are 26 tall pills with the design's colors.
    final language = find.ancestor(of: find.text('Arabic'), matching: find.byType(Container)).first;
    expect(tester.getSize(language).height, 26);
    expect((tester.widget<Container>(language).decoration! as BoxDecoration).color, colors.statusProcessingBg);
    final tone = find.ancestor(of: find.text('Medium'), matching: find.byType(Container)).first;
    expect((tester.widget<Container>(tone).decoration! as BoxDecoration).color, colors.statusDoneBg);
  });

  group('text direction follows the job language, not the app locale', () {
    // Card content is inset 16px; takeaway chips add 12px of their own padding.
    const cardPad = 16.0;
    const chipPad = 12.0;
    const headerTextInset = 28.0; // glyph (20) + gap (8)

    Future<void> pumpDone(WidgetTester tester, JobDetailCubit cubit, Locale locale) async {
      addTearDown(cubit.close);
      await _pump(tester, cubit, locale: locale);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));
      expect(cubit.state.job!.status, 'completed');
    }

    testWidgets('Arabic job in an English app: transcript, summary and takeaways start from the right', (tester) async {
      const transcript = 'نص قصير.';
      const summary = 'ملخص قصير.';
      final cubit = build(transcript, language: 'ar');
      gemma.responder = (prompt, call) async {
        if (prompt.contains('information extraction assistant')) return 'MAIN:\nنقطة رئيسية';
        if (prompt.contains('final summary of a full lecture')) return summary;
        return null;
      };
      await pumpDone(tester, cubit, const Locale('en'));

      final transcriptCard = find.byType(TranscriptCard);
      final summaryCard = find.byType(SummaryCard);
      final tRight = tester.getTopRight(transcriptCard).dx - cardPad;
      final sRight = tester.getTopRight(summaryCard).dx - cardPad;

      expect(tester.getTopRight(find.text(transcript)).dx, closeTo(tRight, 1));
      expect(tester.getTopRight(find.text(summary)).dx, closeTo(sRight, 1));
      expect(tester.getTopRight(find.text('نقطة رئيسية')).dx, closeTo(sRight - chipPad, 1));
      expect(tester.getTopRight(find.text('KEY TAKEAWAYS')).dx, closeTo(sRight, 1));

      // Card headers are UI chrome: they keep the app's (English, left-to-right) direction.
      expect(tester.getTopLeft(find.text('AI Summary')).dx, closeTo(tester.getTopLeft(summaryCard).dx + cardPad + headerTextInset, 1));
      expect(tester.getTopLeft(find.text('Transcript')).dx, closeTo(tester.getTopLeft(transcriptCard).dx + cardPad + headerTextInset, 1));
    });

    testWidgets('English job in an Arabic app: transcript, summary and takeaways start from the left', (tester) async {
      const transcript = 'Short text.';
      const summary = 'Short summary.';
      final cubit = build(transcript, language: 'en');
      gemma.responder = (prompt, call) async {
        if (prompt.contains('information extraction assistant')) return 'MAIN:\nKey point';
        if (prompt.contains('final summary of a full lecture')) return summary;
        return null;
      };
      await pumpDone(tester, cubit, const Locale('ar'));

      final transcriptCard = find.byType(TranscriptCard);
      final summaryCard = find.byType(SummaryCard);
      final tLeft = tester.getTopLeft(transcriptCard).dx + cardPad;
      final sLeft = tester.getTopLeft(summaryCard).dx + cardPad;

      expect(tester.getTopLeft(find.text(transcript)).dx, closeTo(tLeft, 1));
      expect(tester.getTopLeft(find.text(summary)).dx, closeTo(sLeft, 1));
      expect(tester.getTopLeft(find.text('Key point')).dx, closeTo(sLeft + chipPad, 1));
      expect(tester.getTopLeft(find.text('أبرز النقاط')).dx, closeTo(sLeft, 1));

      // Headers keep the app's (Arabic, right-to-left) direction.
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
