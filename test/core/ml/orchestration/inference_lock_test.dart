import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/ml/orchestration/inference_lock.dart';

void main() {
  group('InferenceLock', () {
    test('a second acquire() does not resolve until the first release()s', () async {
      final lock = InferenceLock();
      final order = <String>[];

      await lock.acquire();
      order.add('first-acquired');

      final secondAcquired = Completer<void>();
      unawaited(
        lock.acquire().then((_) {
          order.add('second-acquired');
          secondAcquired.complete();
        }),
      );

      // Give the second acquire a chance to (wrongly) resolve if the lock
      // were broken — it must not have, since the first holder hasn't
      // released yet.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(order, ['first-acquired']);

      order.add('releasing-first');
      lock.release();
      await secondAcquired.future;

      expect(order, ['first-acquired', 'releasing-first', 'second-acquired']);
      lock.release();
    });

    test('run() releases even when the action throws', () async {
      final lock = InferenceLock();

      await expectLater(
        lock.run<void>(() async => throw StateError('boom')),
        throwsA(isA<StateError>()),
      );

      expect(lock.isLocked, isFalse);

      // Lock must be usable again after the throwing action released it.
      var ran = false;
      await lock.run(() async => ran = true);
      expect(ran, isTrue);
    });

    test('waiters are served in FIFO order', () async {
      final lock = InferenceLock();
      final order = <int>[];

      await lock.acquire();

      final waiters = <Future<void>>[];
      for (var i = 0; i < 3; i++) {
        waiters.add(lock.acquire().then((_) => order.add(i)));
      }

      lock.release(); // hands off to waiter 0
      await Future<void>.delayed(Duration.zero);
      lock.release(); // hands off to waiter 1
      await Future<void>.delayed(Duration.zero);
      lock.release(); // hands off to waiter 2

      await Future.wait(waiters);
      expect(order, [0, 1, 2]);
    });

    test('release() on an already-unlocked lock is a no-op', () async {
      final lock = InferenceLock();
      expect(lock.isLocked, isFalse);
      lock.release();
      expect(lock.isLocked, isFalse);
    });

    test('InferenceLock.shared is a single process-wide instance', () {
      expect(identical(InferenceLock.shared, InferenceLock.shared), isTrue);
    });
  });
}
