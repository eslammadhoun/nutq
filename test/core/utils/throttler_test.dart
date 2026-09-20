import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/utils/throttler.dart';

void main() {
  const interval = Duration(milliseconds: 50);

  test('the first value goes through immediately', () {
    final seen = <int>[];
    Throttler<int>(interval, seen.add).add(1);
    expect(seen, [1]);
  });

  test('values inside the interval are coalesced; the newest is flushed when it ends', () {
    fakeAsync((async) {
      final seen = <int>[];
      final t = Throttler<int>(interval, seen.add)..add(1);
      async.elapse(const Duration(milliseconds: 10));
      t
        ..add(2)
        ..add(3)
        ..add(4);
      expect(seen, [1]);
      async.elapse(const Duration(milliseconds: 45));
      expect(seen, [1, 4], reason: 'only the newest of 2, 3, 4 is delivered, at the end of the interval');
    });
  });

  test('a value after a quiet interval goes through immediately again', () {
    fakeAsync((async) {
      final seen = <int>[];
      final t = Throttler<int>(interval, seen.add)..add(1);
      async.elapse(const Duration(milliseconds: 80));
      t.add(2);
      expect(seen, [1, 2]);
    });
  });

  test('delivery is bounded by the interval however fast values arrive', () {
    fakeAsync((async) {
      final seen = <int>[];
      final t = Throttler<int>(interval, seen.add);
      for (var i = 0; i < 100; i++) {
        t.add(i);
        async.elapse(const Duration(milliseconds: 5)); // 500 ms of input
      }
      async.elapse(interval);
      expect(seen.length, lessThanOrEqualTo(12), reason: '500 ms / 50 ms ≈ 10 deliveries, plus the leading one');
      expect(seen.last, 99, reason: 'the final value is never lost');
    });
  });

  test('flush delivers the pending value now, and only once', () {
    fakeAsync((async) {
      final seen = <int>[];
      final t = Throttler<int>(interval, seen.add)
        ..add(1)
        ..add(2)
        ..flush();
      expect(seen, [1, 2]);
      async.elapse(interval * 2);
      expect(seen, [1, 2], reason: 'the timer does not deliver it a second time');
      t.flush();
      expect(seen, [1, 2], reason: 'nothing pending');
    });
  });

  test('cancel drops the pending value', () {
    fakeAsync((async) {
      final seen = <int>[];
      final t = Throttler<int>(interval, seen.add)
        ..add(1)
        ..add(2)
        ..cancel();
      async.elapse(interval * 2);
      expect(seen, [1]);
      t.add(3);
      expect(seen, [1, 3], reason: 'usable again after cancel');
    });
  });
}
