import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/usecases/run_summary_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../summarization/support/fake_gemma.dart';
import 'job_fixtures.dart';

/// Small budgets so a few paragraphs become several chunks.
const testSummarizationConfig = SummarizationConfig(
  targetTokens: 60,
  overlapTokens: 10,
  minTokens: 30,
  maxTokens: 90,
);

/// The real persistence and pipeline stack (in-memory SQLite, scripted model),
/// wired the way the app wires it.
class JobHarness {
  JobHarness() {
    db = newTestDatabase();
    repoFixture = TestRepo(db);
    gemma = FakeGemma();
    final summarization = SummarizationRepositoryImpl(dataSource: gemma);
    runJob = RunSummaryJob(
      jobs: repoFixture.repo,
      summarize: SummarizeTranscript(repository: summarization),
      summarization: summarization,
      config: testSummarizationConfig,
    );
  }

  late final AppDatabase db;
  late final TestRepo repoFixture;
  late final FakeGemma gemma;
  late final RunSummaryJob runJob;

  JobsRepositoryImpl get repo => repoFixture.repo;

  Future<String> createJob(
    String text, {
    ContentLanguage language = ContentLanguage.ar,
  }) async => (await repo.createJob(draft(text, language: language))).id;

  /// Opening a pending job starts it, so set [gemma]'s responder first.
  JobDetailCubit detailCubit(String jobId) => JobDetailCubit(
    repository: repo,
    runJob: runJob,
    jobId: jobId,
  );

  JobsCubit jobsCubit({Duration searchDebounce = const Duration(milliseconds: 20)}) =>
      JobsCubit(repo, searchDebounce: searchDebounce);

  Future<void> dispose() => db.close();
}

/// Six paragraphs of Arabic — several chunks under [testSummarizationConfig].
final sampleTranscript = List.generate(
  6,
  (i) =>
      'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024 وقال الدكتور أحمد محمد إن النتائج جيدة.',
).join('\n\n');
