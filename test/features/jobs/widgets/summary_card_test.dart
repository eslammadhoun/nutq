import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/theme/app_theme.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/summary_card.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() {
  JobDetailEntity job(String summary, List<String> takeaways) => JobDetailEntity(
    id: 'j',
    status: JobRunStatus.completed,
    sourceType: JobSourceType.text,
    sourceLanguage: ContentLanguage.en,
    summaryLanguage: ContentLanguage.en,
    requestedLength: SummaryLength.medium,
    createdAt: DateTime.utc(2026, 10),
    updatedAt: DateTime.utc(2026, 10),
    summary: Summary(
      summaryText: summary,
      length: SummaryLength.medium,
      takeaways: takeaways,
      modelName: 'gemma',
      promptVersion: 'v3',
    ),
  );

  Future<void> pump(WidgetTester tester, JobDetailEntity job) => tester.pumpWidget(
    ScreenUtilPlusInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(child: SummaryCard(job: job)),
        ),
      ),
    ),
  );

  const first = 'The cabinet discussed the budget for next year.';
  const second = 'Spending on schools and hospitals will rise.';

  testWidgets('shows takeaways picked from a longer summary', (tester) async {
    await pump(tester, job('$first $second', [second]));
    expect(find.text('KEY TAKEAWAYS'), findsOneWidget);
  });

  testWidgets('hides takeaways that are the whole summary again', (tester) async {
    await pump(tester, job('$first\n$second', [first, second]));
    expect(find.text('KEY TAKEAWAYS'), findsNothing);
    expect(find.text(first), findsNothing);
  });
}
