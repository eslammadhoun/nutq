import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/transcript_card.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() {
  final job = JobDetailEntity(
    id: 'j',
    status: JobRunStatus.running,
    sourceType: JobSourceType.audio,
    sourceLanguage: ContentLanguage.en,
    summaryLanguage: ContentLanguage.en,
    requestedLength: SummaryLength.medium,
    createdAt: DateTime.utc(2026, 10),
    updatedAt: DateTime.utc(2026, 10),
  );

  Future<void> pump(WidgetTester tester, Widget card) => tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: SingleChildScrollView(child: card)),
      ),
    ),
  );

  final lines = [for (var i = 1; i <= 12; i++) 'line $i'];

  testWidgets('while transcribing, shows the newest lines live', (tester) async {
    await pump(tester, TranscriptCard(job: job, streamingTranscript: lines.join('\n')));
    expect(find.text('Live · 24 words'), findsOneWidget);
    final body = tester.widget<Text>(find.textContaining('line 12')).data!;
    expect(body.split('\n'), ['…', ...lines.sublist(12 - TranscriptCard.liveLines)]);
    expect(body, isNot(contains('line 4\n')));
  });

  testWidgets('a short live transcript is shown whole, with no ellipsis', (tester) async {
    await pump(tester, TranscriptCard(job: job, streamingTranscript: 'line 1\nline 2'));
    expect(find.text('line 1\nline 2'), findsOneWidget);
  });

  testWidgets('the stored transcript replaces the live one', (tester) async {
    final done = job.copyWith(
      status: JobRunStatus.completed,
      transcript: const Transcript(text: 'the whole transcript', wordCount: 3),
    );
    await pump(tester, TranscriptCard(job: done, streamingTranscript: 'line 1'));
    expect(find.textContaining('Live'), findsNothing);
    expect(find.textContaining('the whole transcript'), findsOneWidget);
  });

  testWidgets('with neither, says the transcript is not ready', (tester) async {
    await pump(tester, TranscriptCard(job: job));
    expect(find.text("The transcript isn't ready yet."), findsOneWidget);
  });
}
