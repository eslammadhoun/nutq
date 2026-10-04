import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/usecases/process_job.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';

import '../../../support/sample_text.dart';
import '../support/fake_transcript_source.dart';
import '../support/job_harness.dart';

void main() {
  late JobHarness h;

  setUp(() => h = JobHarness());
  tearDown(() => h.dispose());

  Future<JobRunStatus> statusOf(String id) async => (await h.repo.getJob(id))!.status;

  group('pasted text', () {
    test('runs a pending job to completion and saves the summary with its provenance', () async {
      final id = await h.createJob(sampleTranscript);
      h.gemma.responder = (prompt, call) async => 'النقطة رقم $call من المحاضرة.';
      final events = await h.processJob(id).events.toList();

      final job = (await h.repo.getJob(id))!;
      expect(job.status, JobRunStatus.completed);
      expect(h.gemma.calls, greaterThan(1), reason: 'one call per section');
      expect(
        job.summary!.summaryText,
        [for (var i = 1; i <= h.gemma.calls; i++) 'النقطة رقم $i من المحاضرة.'].join('\n\n'),
        reason: 'one paragraph per section, in source order',
      );
      expect(job.summary!.takeaways, isEmpty);
      expect(job.summary!.needsReview, isFalse);
      expect(job.summary!.modelName, h.summarization.modelId);
      expect(job.summary!.promptVersion, h.summarization.promptVersion);
      expect(job.summary!.tokensOut, greaterThan(0));
      expect(job.failureKind, isNull);

      final stages = events.whereType<JobRunProgress>().map((e) => e.progress.stage).toList();
      expect(stages.first, JobStage.preparing);
      expect(stages, contains(JobStage.summarizing));
      expect(events.whereType<JobRunPartialSummary>().last.text, job.summary!.summaryText);
    });

    test('progress is monotonic and stays within 0–1', () async {
      final id = await h.createJob(sampleTranscript);
      final fractions = (await h.processJob(id).events.toList())
          .whereType<JobRunProgress>()
          .map((e) => e.progress.fraction)
          .toList();
      for (var i = 1; i < fractions.length; i++) {
        expect(fractions[i], greaterThanOrEqualTo(fractions[i - 1]), reason: 'step $i');
      }
      expect(fractions.every((f) => f >= 0 && f <= 1), isTrue);
      expect(fractions.last, 1.0);
    });

    test('the job is "running" while the pipeline works, and only then completed', () async {
      final id = await h.createJob(sampleTranscript);
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 2) await gate.future;
        return null;
      };
      final done = h.processJob(id).events.drain<void>();
      await pumpEventQueue();
      expect(await statusOf(id), JobRunStatus.running);

      gate.complete();
      await done;
      expect(await statusOf(id), JobRunStatus.completed);
    });

    test('the summary language and length drive the pipeline, not the source language', () async {
      final job = await h.repo.createJob(
        NewJobDraft.text(
          text: englishTranscript(3),
          language: ContentLanguage.en,
          summaryLanguage: ContentLanguage.ar,
        ),
      );
      await h.processJob(job.id).events.drain<void>();
      expect(h.gemma.prompts, isNotEmpty);
      expect(h.gemma.prompts.every((p) => p.startsWith('لخّص النص التالي')), isTrue);
    });
  });

  group('failures and cancellation', () {
    test('a pipeline failure marks the job failed with a matching reason', () async {
      final id = await h.createJob(sampleTranscript);
      h.gemma.responder = (prompt, call) async => throw const GemmaGenerationException('x');
      await h.processJob(id).events.drain<void>();

      final job = (await h.repo.getJob(id))!;
      expect(job.status, JobRunStatus.failed);
      expect(job.failureKind, JobFailureKind.generationFailed);
      expect(job.summary, isNull);
    });

    test('an unexpected error is recorded as failed, not left running', () async {
      final id = await h.createJob(sampleTranscript);
      h.gemma.responder = (prompt, call) async => throw StateError('surprise');
      await h.processJob(id).events.drain<void>();
      expect(await statusOf(id), JobRunStatus.failed);
    });

    test('cancel() stops the model and records the job as cancelled', () async {
      final id = await h.createJob(sampleTranscript);
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final run = h.processJob(id);
      final done = run.events.drain<void>();
      await pumpEventQueue();

      await run.cancel();
      expect(h.gemma.cancelled, isTrue);
      gate.complete();
      await done;

      expect(await statusOf(id), JobRunStatus.cancelled);
      expect(h.gemma.calls, 1, reason: 'no further model calls after cancelling');
      expect((await h.repo.getJob(id))!.summary, isNull);
    });

    test('cancelling the event subscription cancels the job and the model', () async {
      final id = await h.createJob(sampleTranscript);
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final sub = h.processJob(id).events.listen((_) {});
      await pumpEventQueue();
      expect(await statusOf(id), JobRunStatus.running);

      unawaited(sub.cancel());
      gate.complete();
      await pumpEventQueue(times: 50);

      expect(h.gemma.cancelled, isTrue);
      expect(await statusOf(id), JobRunStatus.cancelled);
    });

    test('a job that is not pending is left alone', () async {
      final id = await h.createJob(sampleTranscript);
      await h.repo.cancelJob(id);
      final events = await h.processJob(id).events.toList();
      expect(events, isEmpty);
      expect(h.gemma.calls, 0);
      expect(await statusOf(id), JobRunStatus.cancelled);
    });

    test('running a job twice does not run the pipeline twice', () async {
      final id = await h.createJob(sampleTranscript);
      await h.processJob(id).events.drain<void>();
      final calls = h.gemma.calls;
      await h.processJob(id).events.drain<void>();
      expect(h.gemma.calls, calls);
    });

    test('two runs racing for one job: the loser leaves it alone', () async {
      final id = await h.createJob(sampleTranscript);
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final first = h.processJob(id).events.drain<void>();
      final second = h.processJob(id).events.drain<void>();
      await pumpEventQueue();
      gate.complete();
      await Future.wait([first, second]);

      expect(
        await statusOf(id),
        JobRunStatus.completed,
        reason: 'the loser did not fail or cancel the job',
      );
      expect(h.gemma.calls, greaterThan(0));
    });

    test('a missing job is reported', () async {
      await expectLater(h.processJob('nope').events, emitsError(isA<JobNotFoundException>()));
    });

    test('a job deleted mid-run does not crash the run', () async {
      final id = await h.createJob(sampleTranscript);
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final done = h.processJob(id).events.drain<void>();
      await pumpEventQueue();
      await h.repo.deleteJob(id);
      gate.complete();
      await done;
      expect(await h.repo.getJob(id), isNull);
    });
  });

  group('the source strategy', () {
    late FakeMediaSource audio;

    Future<String> audioJob() async => (await h.repo.createJob(
      NewJobDraft.media(
        type: JobSourceType.audio,
        filePath: '/f.m4a',
        language: ContentLanguage.ar,
      ),
    )).id;

    Future<void> useSource(FakeMediaSource source) async {
      audio = source;
      await h.dispose();
      h = JobHarness(extraSources: [source]);
    }

    test('a source with no registered implementation fails the job as unsupported', () async {
      final id = await audioJob(); // the default harness has only the text source
      await h.processJob(id).events.drain<void>();
      final job = (await h.repo.getJob(id))!;
      expect(job.status, JobRunStatus.failed);
      expect(job.failureKind, JobFailureKind.unsupportedMedia);
      expect(h.gemma.calls, 0);
    });

    test('resolves, stores the transcript with its model, then summarizes it', () async {
      await useSource(FakeMediaSource());
      final id = await audioJob();
      expect(
        (await h.repo.getJob(id))!.transcript,
        isNull,
        reason: 'no transcript before the source runs',
      );

      await h.processJob(id).events.drain<void>();

      final job = (await h.repo.getJob(id))!;
      expect(job.status, JobRunStatus.completed);
      expect(job.transcript!.text, audio.text);
      expect(job.transcript!.modelName, 'fake-asr');
      expect(job.transcript!.wordCount, audio.text.split(' ').length);
      expect(job.summary, isNotNull);
      expect(
        h.gemma.prompts.first,
        contains(audio.text),
        reason: 'the summary is made from the resolved text',
      );
    });

    test(
      'source and summarization progress share one monotonic bar split at the source share',
      () async {
        await useSource(FakeMediaSource(progressShare: 0.4));
        final id = await audioJob();
        final progress = (await h.processJob(id).events.toList())
            .whereType<JobRunProgress>()
            .map((e) => e.progress)
            .toList();

        final stages = progress.map((p) => p.stage).toList();
        expect(
          stages,
          containsAll([JobStage.acquiring, JobStage.transcribing, JobStage.summarizing]),
        );
        for (var i = 1; i < progress.length; i++) {
          expect(
            progress[i].fraction,
            greaterThanOrEqualTo(progress[i - 1].fraction),
            reason: 'step $i (${progress[i].stage})',
          );
        }
        final lastSourceFraction = progress
            .lastWhere((p) => p.stage == JobStage.transcribing)
            .fraction;
        expect(
          lastSourceFraction,
          closeTo(0.4, 1e-9),
          reason: 'the source fills exactly its share',
        );
        final firstSummarization = progress.firstWhere((p) => p.stage == JobStage.summarizing);
        expect(firstSummarization.fraction, greaterThanOrEqualTo(0.4));
        expect(progress.last.fraction, 1.0);
      },
    );

    test('the bar never goes backwards even if a source restarts its own scale per phase', () async {
      // FakeMediaSource reports acquiring 0.5→1 then transcribing 0.5→1, so its raw fractions dip.
      await useSource(FakeMediaSource(progressShare: 0.4));
      final id = await audioJob();
      final raw = (await h.processJob(id).events.toList())
          .whereType<JobRunProgress>()
          .map((e) => e.progress.fraction)
          .toList();
      expect(raw.toSet().length, greaterThan(3));
      for (var i = 1; i < raw.length; i++) {
        expect(raw[i], greaterThanOrEqualTo(raw[i - 1]));
      }
    });

    test('what the source learns about the media is stored while it works', () async {
      await useSource(
        FakeMediaSource(
          info: const SourceInfo(title: 'Lecture 3', durationSeconds: 1800, filePath: '/dl/l3.m4a'),
        ),
      );
      final id = await audioJob();
      await h.processJob(id).events.drain<void>();
      final job = (await h.repo.getJob(id))!;
      expect(job.sourceTitle, 'Lecture 3');
      expect(job.durationSeconds, 1800);
      expect(job.sourceFilePath, '/dl/l3.m4a');
    });

    test(
      'a source failure fails the job with its own reason and never reaches the model',
      () async {
        await useSource(
          FakeMediaSource(error: const JobFailure(JobFailureKind.sourceUnavailable, 'offline')),
        );
        final id = await audioJob();
        await h.processJob(id).events.drain<void>();
        final job = (await h.repo.getJob(id))!;
        expect(job.status, JobRunStatus.failed);
        expect(job.failureKind, JobFailureKind.sourceUnavailable);
        expect(job.transcript, isNull);
        expect(h.gemma.calls, 0);
      },
    );

    test('a source returning blank text fails the job as an empty transcript', () async {
      await useSource(FakeMediaSource(text: '   '));
      final id = await audioJob();
      await h.processJob(id).events.drain<void>();
      expect((await h.repo.getJob(id))!.failureKind, JobFailureKind.emptyTranscript);
    });

    test('cancelling while the source works records the job as cancelled', () async {
      final gate = Completer<void>();
      await useSource(FakeMediaSource(gate: gate));
      final id = await audioJob();
      final run = h.processJob(id);
      final done = run.events.drain<void>();
      await pumpEventQueue();
      expect(await statusOf(id), JobRunStatus.running);

      await run.cancel();
      gate.complete();
      await done;
      expect(await statusOf(id), JobRunStatus.cancelled);
      expect(h.gemma.calls, 0);
    });

    test(
      'a text job whose source has nothing to resolve fails instead of hanging as pending',
      () async {
        final id = await h.createJob('   x   ');
        // Simulate a stored job that lost its transcript.
        await h.db.customStatement('DELETE FROM job_transcripts');
        await h.processJob(id).events.drain<void>();
        final job = (await h.repo.getJob(id))!;
        expect(job.status, JobRunStatus.failed, reason: 'never silently left pending');
        expect(job.failureKind, JobFailureKind.emptyTranscript);
      },
    );
  });
}
