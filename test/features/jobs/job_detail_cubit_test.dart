import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/core/domain/content_language.dart';

import 'support/job_harness.dart';

const _longFinal =
    'الملخص النهائي يشرح الفكرة الرئيسية للمحاضرة ثم ينتقل إلى النقاط المهمة والأرقام والتواريخ ويختم بالخلاصة';

void main() {
  late JobHarness h;
  late List<JobDetailCubit> opened;

  setUp(() {
    h = JobHarness();
    opened = [];
  });

  tearDown(() async {
    for (final c in opened) {
      await c.close();
    }
    await h.dispose();
  });

  JobDetailCubit open(String id) {
    final cubit = h.detailCubit(id);
    opened.add(cubit);
    return cubit;
  }

  /// Waits until the stored job reaches a final state (or 3s).
  Future<void> untilSettled(JobDetailCubit cubit) async {
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (!(cubit.state.job?.status.isTerminal ?? false) && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }

  test('starts loading, then shows the stored job while the queue runs it', () async {
    final id = await h.submit(sampleTranscript);
    final cubit = open(id);
    expect(cubit.state.status, JobDetailStatus.loading);

    await Future<void>.delayed(const Duration(milliseconds: 5));
    final job = cubit.state.job!;
    expect(cubit.state.status, JobDetailStatus.success);
    expect(job.id, id);
    expect(job.transcript!.text, sampleTranscript.trim());
    expect(job.transcript!.wordCount, sampleTranscript.trim().split(RegExp(r'\s+')).length);
    await untilSettled(cubit);
  });

  test('streams progress into state, then completes with the stored summary and takeaways', () async {
    final id = await h.submit(sampleTranscript);
    final cubit = open(id);
    final seen = <JobDetailState>[];
    final sub = cubit.stream.listen(seen.add);
    await untilSettled(cubit);
    await sub.cancel();

    final stages = seen.map((s) => s.progress?.stage).whereType<JobStage>().toList();
    expect(stages, contains(JobStage.analyzing));
    expect(stages, contains(JobStage.finalizing));
    final fractions = seen.map((s) => s.progress?.fraction).whereType<double>().toList();
    for (var i = 1; i < fractions.length; i++) {
      expect(fractions[i], greaterThanOrEqualTo(fractions[i - 1]));
    }
    expect(seen.where((s) => s.job?.status == JobRunStatus.running), isNotEmpty);

    final done = cubit.state;
    expect(done.job!.status, JobRunStatus.completed);
    expect(done.progress, isNull);
    expect(done.streamingSummary, isNull, reason: 'the stored summary takes over once the job settles');
    expect(done.job!.summary!.summaryText, 'الملخص النهائي للمحاضرة');
    expect(done.job!.summary!.takeaways, ['فكرة رئيسية عن الموضوع']);
    expect(done.job!.summary!.length.name, 'medium');
  });

  test('the result really is saved: a second open shows it without running again', () async {
    final id = await h.submit(sampleTranscript);
    final first = open(id);
    await untilSettled(first);
    final callsAfterFirst = h.gemma.calls;

    final second = open(id);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(second.state.job!.status, JobRunStatus.completed);
    expect(second.state.job!.summary!.summaryText, 'الملخص النهائي للمحاضرة');
    expect(second.state.progress, isNull);
    expect(h.gemma.calls, callsAfterFirst, reason: 'reopening a finished job does not run the model');
  });

  test('flags a summary whose numbers are not in the transcript', () async {
    h.gemma.responder = (prompt, call) async =>
        prompt.contains('final summary of a full lecture') ? 'شارك 9999 شخصا في الفعالية.' : null;
    final cubit = open(await h.submit(sampleTranscript));
    await untilSettled(cubit);
    expect(cubit.state.job!.status, JobRunStatus.completed);
    expect(cubit.state.job!.summary!.needsReview, isTrue);
  });

  test('a failed run is stored as failed with its failure kind', () async {
    h.gemma.responder = (prompt, call) async {
      if (prompt.contains('final summary of a full lecture')) throw const GemmaGenerationException('x');
      return null;
    };
    final cubit = open(await h.submit(sampleTranscript));
    await untilSettled(cubit);
    expect(cubit.state.job!.status, JobRunStatus.failed);
    expect(cubit.state.job!.failureKind, JobFailureKind.generationFailed);
    expect(cubit.state.progress, isNull);
  });

  test('an interrupted job (app killed mid-run) shows as failed/interrupted after recovery', () async {
    final id = await h.createJob(sampleTranscript);
    await h.repo.markRunning(id);
    await h.repo.recoverInterruptedJobs();

    final cubit = open(id);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(cubit.state.job!.status, JobRunStatus.failed);
    expect(cubit.state.job!.failureKind, JobFailureKind.interrupted);
    expect(h.gemma.calls, 0, reason: 'a settled job is never re-run');
  });

  test('cancelJob stops the model and the stored job ends as cancelled', () async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    final cubit = open(await h.submit(sampleTranscript));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(cubit.state.job!.status, JobRunStatus.running);

    unawaited(cubit.cancelJob());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.isCancelling, isTrue);
    expect(h.gemma.cancelled, isTrue);

    gate.complete();
    await untilSettled(cubit);
    expect(cubit.state.job!.status, JobRunStatus.cancelled);
    expect(cubit.state.isCancelling, isFalse);
    expect(cubit.state.progress, isNull);
    expect(cubit.state.streamingSummary, isNull);
    expect(h.gemma.calls, 1);
  });

  test('leaving the screen does NOT stop the job: it finishes in the background', () async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 1) await gate.future;
      return null;
    };
    final id = await h.submit(sampleTranscript);
    final cubit = open(id);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect((await h.repo.getJob(id))!.status, JobRunStatus.running);

    await cubit.close();
    expect(h.gemma.cancelled, isFalse, reason: 'closing a screen never touches the model');
    gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect((await h.repo.getJob(id))!.status, JobRunStatus.completed);
  });

  test('a screen opened mid-run picks up the live progress already made', () async {
    final gate = Completer<void>();
    h.gemma.responder = (prompt, call) async {
      if (call == 3) await gate.future;
      return null;
    };
    final id = await h.submit(sampleTranscript);
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final late = open(id);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(late.state.job!.status, JobRunStatus.running);
    expect(late.state.progress, isNotNull, reason: 'progress is replayed, not waited for');
    expect(late.state.progress!.fraction, greaterThan(0.02));
    gate.complete();
    await untilSettled(late);
    expect(late.state.job!.status, JobRunStatus.completed);
  });

  test('a pending job that is not queued just shows as pending (opening a screen starts nothing)', () async {
    final id = await h.createJob(sampleTranscript);
    final cubit = open(id);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(cubit.state.job!.status, JobRunStatus.pending);
    expect(h.gemma.calls, 0);
  });

  test('a job that does not exist shows notFound', () async {
    final cubit = open('nope');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(cubit.state.status, JobDetailStatus.notFound);
    expect(cubit.state.job, isNull);
  });

  test('a job deleted while open flips to notFound', () async {
    final id = await h.submit(sampleTranscript);
    final first = open(id);
    await untilSettled(first);
    await h.repo.deleteJob(id);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(first.state.status, JobDetailStatus.notFound);
  });

  test('the job language drives the pipeline (English)', () async {
    final id = await h.submit(
      'Attendance reached 250 people in 2024. The team said results were good.',
      language: ContentLanguage.en,
    );
    final cubit = open(id);
    await untilSettled(cubit);
    expect(cubit.state.job!.sourceLanguage, ContentLanguage.en);
    expect(h.gemma.prompts, isNotEmpty);
    expect(h.gemma.prompts.every((p) => p.contains('English') && !p.contains('Arabic')), isTrue);
  });

  group('word-by-word summary', () {
    test('streamingSummary grows as prefixes, is throttled, then hands over to the stored summary', () async {
      h.gemma.responder = (prompt, call) async =>
          prompt.contains('final summary of a full lecture') ? _longFinal : null;
      final cubit = open(await h.submit(sampleTranscript));
      final live = <String>[];
      final sub = cubit.stream.listen((s) {
        final t = s.streamingSummary;
        if (t != null && (live.isEmpty || live.last != t)) live.add(t);
      });
      await untilSettled(cubit);
      await sub.cancel();

      expect(live, isNotEmpty);
      for (var i = 1; i < live.length; i++) {
        expect(live[i].startsWith(live[i - 1]), isTrue);
      }
      expect(live.length, lessThan(_longFinal.split(' ').length), reason: 'coalesced, not one rebuild per word');
      expect(cubit.state.job!.summary!.summaryText, _longFinal);
      expect(cubit.state.streamingSummary, isNull);
    });

    test('a running job has no stored summary yet', () async {
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (prompt.contains('final summary of a full lecture')) {
          await gate.future;
          return _longFinal;
        }
        return null;
      };
      final cubit = open(await h.submit(sampleTranscript));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.job!.status, JobRunStatus.running);
      expect(cubit.state.job!.summary, isNull);
      gate.complete();
      await untilSettled(cubit);
      expect(cubit.state.job!.status, JobRunStatus.completed);
    });

    test('cancelling clears the partial text', () async {
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (prompt.contains('final summary of a full lecture')) {
          await gate.future;
          return _longFinal;
        }
        return null;
      };
      final cubit = open(await h.submit(sampleTranscript));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      unawaited(cubit.cancelJob());
      gate.complete();
      await untilSettled(cubit);
      expect(cubit.state.job!.status, JobRunStatus.cancelled);
      expect(cubit.state.streamingSummary, isNull);
    });
  });

  test('a database failure while loading is reported and can be retried', () async {
    // A closed database makes watching fail.
    final broken = JobHarness();
    final brokenId = await broken.createJob(sampleTranscript);
    await broken.db.close();
    final cubit = broken.detailCubit(brokenId);
    opened.add(cubit);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.status, JobDetailStatus.failure);
    expect(cubit.state.lastError, AppError.storage);
  });
}
