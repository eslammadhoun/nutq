import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';

import '../summarization/support/fake_gemma.dart';

const _config = SummarizationConfig(targetTokens: 60, overlapTokens: 10, minTokens: 30, maxTokens: 90);
final _text = List.generate(
  6,
  (i) => 'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024 وقال الدكتور أحمد محمد إن النتائج جيدة.',
).join('\n\n');

void main() {
  late FakeGemma gemma;
  late SummarizationRepositoryImpl repository;

  JobDetailCubit build(String text, {String language = 'ar'}) {
    gemma = FakeGemma();
    repository = SummarizationRepositoryImpl(dataSource: gemma);
    return JobDetailCubit(
      summarize: SummarizeTranscript(repository: repository),
      repository: repository,
      transcript: text,
      language: language,
      config: _config,
    );
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 100));

  test('immediately exposes a pending text job carrying the submitted transcript', () {
    final cubit = build(_text);
    final job = cubit.state.job!;
    expect(cubit.state.status, JobDetailStatus.success);
    expect(job.status, 'pending');
    expect(job.sourceType, 'text');
    expect(job.language, 'ar');
    expect(job.id, startsWith('local-'));
    expect(job.transcript!.text, _text.trim());
    expect(job.transcript!.wordCount, _text.trim().split(RegExp(r'\s+')).length);
    expect(cubit.state.transcriptText, _text.trim());
    cubit.close();
  });

  test('streams progress into state, then completes with the summary and takeaways', () async {
    final cubit = build(_text, language: 'en');
    final seen = <JobDetailState>[];
    final sub = cubit.stream.listen(seen.add);
    await settle();

    final stages = seen.map((s) => s.progress?.stage).whereType<SummarizationStage>().toList();
    expect(stages, contains(SummarizationStage.analyzing));
    expect(stages, contains(SummarizationStage.finalizing));
    expect(seen.where((s) => s.job?.status == 'summarizing'), isNotEmpty);

    final fractions = seen.map((s) => s.progress?.fraction).whereType<double>().toList();
    for (var i = 1; i < fractions.length; i++) {
      expect(fractions[i], greaterThanOrEqualTo(fractions[i - 1]));
    }

    final done = cubit.state;
    expect(done.job!.status, 'completed');
    expect(done.progress, isNull);
    expect(done.job!.language, 'en');
    expect(done.job!.summary!.summaryText, 'الملخص النهائي للمحاضرة');
    expect(done.job!.summary!.toneAndFormat, 'medium');
    expect(done.summaryTakeaways, [
      {'text': 'فكرة رئيسية عن الموضوع'},
    ]);
    expect(done.failureKind, isNull);
    await sub.cancel();
    await cubit.close();
  });

  test('flags a summary whose numbers are not in the transcript', () async {
    final cubit = build(_text);
    gemma.responder = (prompt, call) async =>
        prompt.contains('final summary of a full lecture') ? 'شارك 9999 شخصا في الفعالية.' : null;
    await settle();
    expect(cubit.state.job!.status, 'completed');
    expect(cubit.state.summaryNeedsReview, isTrue);
    await cubit.close();
  });

  test('a failed job ends as failed with the raw failure kind for the UI to localize', () async {
    final cubit = build('   ');
    await settle();
    expect(cubit.state.job!.status, 'failed');
    expect(cubit.state.failureKind, SummarizationFailureKind.emptyTranscript);
    expect(cubit.state.progress, isNull);
    await cubit.close();
  });

  test('model failure on the final step → failed / generationFailed', () async {
    final cubit = build(_text);
    gemma.responder = (prompt, call) async {
      if (prompt.contains('final summary of a full lecture')) throw const GemmaGenerationException('x');
      return null;
    };
    await settle();
    expect(cubit.state.job!.status, 'failed');
    expect(cubit.state.failureKind, SummarizationFailureKind.generationFailed);
    await cubit.close();
  });

  test('cancelJob stops the job, tells the model to stop, and ends as cancelled', () async {
    final cubit = build(_text);
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state.job!.status, isIn(['pending', 'summarizing']));

    unawaited(cubit.cancelJob());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.isCancelling, isTrue);
    expect(gemma.cancelled, isTrue);

    gate.complete();
    await settle();
    expect(cubit.state.job!.status, 'cancelled');
    expect(cubit.state.isCancelling, isFalse);
    expect(cubit.state.progress, isNull);
    expect(gemma.calls, 1);
    await cubit.close();
  });

  test('leaving the screen (close) while running cancels the model', () async {
    final cubit = build(_text);
    final gate = Completer<void>();
    gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await cubit.close();
    expect(gemma.cancelled, isTrue);
    gate.complete();
    await settle();
    expect(gemma.calls, 1);
  });
}
