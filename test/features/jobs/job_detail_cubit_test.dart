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

  /// Waits until the job reaches a final state (or 3s), instead of sleeping a
  /// fixed time that can be too short on a busy machine.
  Future<void> settle(JobDetailCubit cubit) async {
    const terminal = {'completed', 'failed', 'cancelled'};
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (!terminal.contains(cubit.state.job?.status) && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

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
    await settle(cubit);

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
    await settle(cubit);
    expect(cubit.state.job!.status, 'completed');
    expect(cubit.state.summaryNeedsReview, isTrue);
    await cubit.close();
  });

  test('a failed job ends as failed with the raw failure kind for the UI to localize', () async {
    final cubit = build('   ');
    await settle(cubit);
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
    await settle(cubit);
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
    await settle(cubit);
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
    await settle(cubit);
    expect(gemma.calls, 1);
  });

  group('word-by-word summary', () {
    const longFinal = 'الملخص النهائي يشرح الفكرة الرئيسية للمحاضرة ثم ينتقل إلى النقاط المهمة والأرقام والتواريخ ويختم بالخلاصة';

    test('streamingSummary grows as prefixes, is throttled, and ends equal to the final summary', () async {
      final cubit = build(_text);
      gemma.responder = (prompt, call) async => prompt.contains('final summary of a full lecture') ? longFinal : null;
      final live = <String>[];
      final sub = cubit.stream.listen((s) {
        final t = s.streamingSummary;
        if (t != null && (live.isEmpty || live.last != t)) live.add(t);
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(live, isNotEmpty);
      for (var i = 1; i < live.length; i++) {
        expect(live[i].startsWith(live[i - 1]), isTrue);
      }
      expect(live.length, lessThan(longFinal.split(' ').length), reason: 'coalesced, not one rebuild per word');
      expect(cubit.state.streamingSummary, longFinal);
      expect(cubit.state.job!.summary!.summaryText, longFinal);
      expect(cubit.state.job!.status, 'completed');
      await sub.cancel();
      await cubit.close();
    });

    test('while streaming the job is still summarizing with no final summary yet', () async {
      final cubit = build(_text);
      final gate = Completer<void>();
      gemma.responder = (prompt, call) async {
        if (prompt.contains('final summary of a full lecture')) {
          await gate.future;
          return longFinal;
        }
        return null;
      };
      await Future<void>.delayed(const Duration(milliseconds: 100));
      gate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final mid = cubit.state;
      // Whatever moment we sample, a running job never has a final summary.
      if (mid.job!.status == 'summarizing') {
        expect(mid.job!.summary, isNull);
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(cubit.state.job!.status, 'completed');
      await cubit.close();
    });

    test('cancelling clears the partial text instead of leaving half a summary', () async {
      final cubit = build(_text);
      final gate = Completer<void>();
      gemma.responder = (prompt, call) async {
        if (prompt.contains('final summary of a full lecture')) {
          await gate.future;
          return longFinal;
        }
        return null;
      };
      await Future<void>.delayed(const Duration(milliseconds: 100));
      unawaited(cubit.cancelJob());
      gate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(cubit.state.job!.status, 'cancelled');
      expect(cubit.state.streamingSummary, isNull);
      await cubit.close();
    });

    test('a mid-stream failure clears the partial text', () async {
      final cubit = build(_text);
      gemma.responder = (prompt, call) async {
        if (prompt.contains('final summary of a full lecture')) throw const GemmaGenerationException('x');
        return null;
      };
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(cubit.state.job!.status, 'failed');
      expect(cubit.state.streamingSummary, isNull);
      await cubit.close();
    });
  });

  group('language', () {
    test('the chosen language drives the model prompts (English)', () async {
      final cubit = build('Attendance reached 250 people in 2024. The team said results were good.', language: 'en');
      await settle(cubit);
      expect(cubit.state.job!.language, 'en');
      expect(gemma.prompts, isNotEmpty);
      expect(gemma.prompts.every((p) => p.contains('English') && !p.contains('Arabic')), isTrue);
      await cubit.close();
    });

    test('Arabic is used when the toggle says ar', () async {
      final cubit = build('نص عربي قصير عن موضوع مهم.', language: 'ar');
      await settle(cubit);
      expect(gemma.prompts.every((p) => p.contains('Arabic')), isTrue);
      await cubit.close();
    });
  });
}
