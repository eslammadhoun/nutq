import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/services/job_runner.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';

import '../support/job_harness.dart';

/// Distinct one-chunk transcripts, so a job can be recognised in the model's
/// prompts.
String _text(String tag) => 'نص قصير رقم $tag عن موضوع واحد فقط.';

void main() {
  late JobHarness h;

  setUp(() => h = JobHarness());
  tearDown(() => h.dispose());

  Future<JobRunStatus> statusOf(String id) async => (await h.repo.getJob(id))!.status;

  /// Polls until [check] passes (or 3s), instead of sleeping a fixed time.
  Future<void> eventually(FutureOr<bool> Function() check) async {
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (!await check() && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(await check(), isTrue, reason: 'condition not reached in time');
  }

  test('a submitted job runs to completion with no screen involved', () async {
    final id = await h.submit(_text('A'));
    await eventually(() async => await statusOf(id) == JobRunStatus.completed);
    expect((await h.repo.getJob(id))!.summary!.summaryText, isNotEmpty);
  });

  group('one at a time, in order', () {
    test('jobs run first-in first-out and never two at once', () async {
      var running = 0;
      var maxRunning = 0;
      final startOrder = <String>[];
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        for (final tag in ['AAA', 'BBB', 'CCC']) {
          if (prompt.contains(tag) && !startOrder.contains(tag)) startOrder.add(tag);
        }
        running++;
        if (running > maxRunning) maxRunning = running;
        if (call == 1) await gate.future;
        await Future<void>.delayed(const Duration(milliseconds: 2));
        running--;
        return null;
      };

      final a = await h.submit(_text('AAA'));
      final b = await h.submit(_text('BBB'));
      final c = await h.submit(_text('CCC'));
      await eventually(() async => await statusOf(a) == JobRunStatus.running);
      expect(await statusOf(b), JobRunStatus.pending, reason: 'waits its turn');
      expect(await statusOf(c), JobRunStatus.pending);

      gate.complete();
      await eventually(() async => await statusOf(c) == JobRunStatus.completed);
      expect(startOrder, ['AAA', 'BBB', 'CCC']);
      expect(maxRunning, 1);
      expect(await statusOf(a), JobRunStatus.completed);
      expect(await statusOf(b), JobRunStatus.completed);
    });

    test('enqueueing the same job twice runs it once', () async {
      final id = await h.createJob(_text('DUP'));
      h.runner
        ..enqueue(id)
        ..enqueue(id);
      await eventually(() async => await statusOf(id) == JobRunStatus.completed);
      final callsForOne = h.gemma.calls;

      final other = JobHarness();
      addTearDown(other.dispose);
      final id2 = await other.createJob(_text('DUP'));
      other.runner.enqueue(id2);
      await eventually(
        () async => (await other.repo.getJob(id2))!.status == JobRunStatus.completed,
      );
      expect(callsForOne, other.gemma.calls);
    });
  });

  group('cancel', () {
    test('a queued job is cancelled without ever running, and the others carry on', () async {
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final a = await h.submit(_text('AAA'));
      final b = await h.submit(_text('BBB'));
      final c = await h.submit(_text('CCC'));
      await eventually(() async => await statusOf(a) == JobRunStatus.running);

      await h.runner.cancel(b);
      expect(await statusOf(b), JobRunStatus.cancelled);

      gate.complete();
      await eventually(() async => await statusOf(c) == JobRunStatus.completed);
      expect(await statusOf(a), JobRunStatus.completed);
      expect(
        h.gemma.prompts.any((p) => p.contains('BBB')),
        isFalse,
        reason: 'B never reached the model',
      );
    });

    test('the running job is stopped and cancelled, and the next one starts', () async {
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final a = await h.submit(_text('AAA'));
      final b = await h.submit(_text('BBB'));
      await eventually(() async => await statusOf(a) == JobRunStatus.running);

      final cancelling = h.runner.cancel(a);
      await pumpEventQueue();
      expect(h.gemma.cancelled, isTrue);
      gate.complete();
      await cancelling;

      await eventually(() async => await statusOf(b) == JobRunStatus.completed);
      expect(await statusOf(a), JobRunStatus.cancelled);
    });

    test('cancelling an unknown or finished job does nothing', () async {
      await h.runner.cancel('nope');
      final id = await h.submit(_text('A'));
      await eventually(() async => await statusOf(id) == JobRunStatus.completed);
      await h.runner.cancel(id);
      expect(await statusOf(id), JobRunStatus.completed);
    });
  });

  group('live state', () {
    test(
      'is null when idle, carries progress while running, and is null again at the end',
      () async {
        final gate = Completer<void>();
        h.gemma.responder = (prompt, call) async {
          if (call == 1) await gate.future;
          return null;
        };
        final id = await h.createJob(_text('A'));
        final seen = <JobLive?>[];
        final sub = h.runner.watchLive(id).listen(seen.add);
        await pumpEventQueue();
        expect(seen, [null], reason: 'nothing running yet');

        h.runner.enqueue(id);
        await eventually(() => seen.any((l) => l?.progress != null));
        expect(seen.last!.progress!.stage, isIn(JobStage.values));

        gate.complete();
        await eventually(() => seen.last == null);
        expect(
          seen.whereType<JobLive>().map((l) => l.progress?.fraction).whereType<double>(),
          isNotEmpty,
        );
        await sub.cancel();
      },
    );

    test('a subscriber that arrives mid-run immediately gets the current state', () async {
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 2) await gate.future;
        return null;
      };
      final id = await h.submit(_text('A'));
      await eventually(() async => await statusOf(id) == JobRunStatus.running);
      await eventually(() async {
        final first = await h.runner.watchLive(id).first;
        return first?.progress != null;
      });

      final late = await h.runner.watchLive(id).first;
      expect(late, isNotNull, reason: 'a screen opened mid-run sees the progress already made');
      expect(late!.progress!.fraction, greaterThan(0));
      gate.complete();
    });

    test('the streaming summary is throttled, not delivered word by word', () async {
      const words = 40;
      final summary = List.generate(words, (i) => 'كلمة$i').join(' ');
      h.gemma.responder = (prompt, call) async =>
          prompt.contains('final summary of a full lecture') ? summary : null;
      final id = await h.createJob(_text('A'));
      final partials = <String>[];
      final sub = h.runner.watchLive(id).listen((l) {
        final t = l?.partialSummary;
        if (t != null && (partials.isEmpty || partials.last != t)) partials.add(t);
      });
      h.runner.enqueue(id);
      await eventually(() async => await statusOf(id) == JobRunStatus.completed);
      await sub.cancel();

      expect(partials, isNotEmpty);
      for (var i = 1; i < partials.length; i++) {
        expect(partials[i].startsWith(partials[i - 1]), isTrue);
      }
      expect(partials.length, lessThan(words), reason: 'coalesced, not one update per word');
    });

    test('live state of one job is never delivered to another job\'s watcher', () async {
      final a = await h.createJob(_text('A'));
      final b = await h.createJob(_text('B'));
      final seenB = <JobLive?>[];
      final sub = h.runner.watchLive(b).listen(seenB.add);
      h.runner.enqueue(a);
      await eventually(() async => await statusOf(a) == JobRunStatus.completed);
      await sub.cancel();
      expect(seenB.whereType<JobLive>(), isEmpty);
    });
  });

  group('start and recovery', () {
    test('jobs queued before start wait for it', () async {
      final fresh = JobHarness();
      addTearDown(fresh.dispose);
      // Replace with an un-started runner over the same stack.
      final runner = JobRunner(
        jobs: fresh.repo,
        process: fresh.processJob,
        now: () => DateTime.utc(2000),
      );
      addTearDown(runner.dispose);
      final id = await fresh.createJob(_text('A'));
      runner.enqueue(id);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(
        await fresh.repo.getJob(id).then((j) => j!.status),
        JobRunStatus.pending,
        reason: 'not started yet',
      );

      await runner.start();
      await eventually(() async => (await fresh.repo.getJob(id))!.status == JobRunStatus.completed);
    });

    test(
      'start fails jobs left active by an earlier session, but not this session\'s own',
      () async {
        final oldPending = await h.createJob(_text('OLD1'));
        final oldRunning = await h.createJob(_text('OLD2'));
        await h.repo.markRunning(oldRunning);
        final ownPending = await h.createJob(_text('OWN')); // created "after" the runner started

        // A runner whose session began after the first two jobs, before the last.
        final between = h.repoFixture.repo;
        final startedAt = (await between.getJob(
          oldRunning,
        ))!.createdAt.add(const Duration(seconds: 30));
        final runner = JobRunner(jobs: between, process: h.processJob, now: () => startedAt);
        addTearDown(runner.dispose);
        await runner.start();

        expect(await statusOf(oldPending), JobRunStatus.failed);
        expect((await h.repo.getJob(oldPending))!.failureKind, JobFailureKind.interrupted);
        expect(await statusOf(oldRunning), JobRunStatus.failed);
        expect(
          await statusOf(ownPending),
          JobRunStatus.pending,
          reason: 'created after the session began',
        );
      },
    );

    test('start is idempotent', () async {
      await h.runner.start();
      await h.runner.start();
      final id = await h.submit(_text('A'));
      await eventually(() async => await statusOf(id) == JobRunStatus.completed);
    });
  });

  group('idle release', () {
    test('onIdle fires once the queue has stayed empty, and not while busy', () async {
      var released = 0;
      final runner = JobRunner(
        jobs: h.repo,
        process: h.processJob,
        now: () => DateTime.utc(2000),
        idleAfter: const Duration(milliseconds: 120),
        onIdle: () async => released++,
      );
      addTearDown(runner.dispose);
      await runner.start();
      expect(released, 0, reason: 'nothing has run yet');

      final id = await h.createJob(_text('A'));
      runner.enqueue(id);
      await eventually(() async => await statusOf(id) == JobRunStatus.completed);
      expect(released, 0, reason: 'just finished; the idle period has not passed');

      await eventually(() => released == 1);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(released, 1, reason: 'released once, not repeatedly');
    });

    test('new work resets the idle timer', () async {
      var released = 0;
      final runner = JobRunner(
        jobs: h.repo,
        process: h.processJob,
        now: () => DateTime.utc(2000),
        idleAfter: const Duration(milliseconds: 150),
        onIdle: () async => released++,
      );
      addTearDown(runner.dispose);
      await runner.start();

      final first = await h.createJob(_text('A'));
      runner.enqueue(first);
      await eventually(() async => await statusOf(first) == JobRunStatus.completed);
      await Future<void>.delayed(const Duration(milliseconds: 90)); // inside the idle window
      final second = await h.createJob(_text('B'));
      runner.enqueue(second);
      await eventually(() async => await statusOf(second) == JobRunStatus.completed);
      await Future<void>.delayed(const Duration(milliseconds: 90));
      expect(released, 0, reason: 'the timer restarted when the second job finished');
      await eventually(() => released == 1);
    });
  });

  group('dispose', () {
    test('cancels the running job and drops the queue', () async {
      final gate = Completer<void>();
      h.gemma.responder = (prompt, call) async {
        if (call == 1) await gate.future;
        return null;
      };
      final a = await h.submit(_text('AAA'));
      final b = await h.submit(_text('BBB'));
      await eventually(() async => await statusOf(a) == JobRunStatus.running);

      final disposing = h.runner.dispose();
      gate.complete();
      await disposing;
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(await statusOf(a), JobRunStatus.cancelled);
      expect(await statusOf(b), JobRunStatus.pending, reason: 'never started');
      h.runner.enqueue(b); // must be a harmless no-op
    });
  });
}
