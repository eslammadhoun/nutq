import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/session/session_manager.dart';

void main() {
  group('SessionManager', () => _tests());
}

void _tests() {
  late SessionManager manager;

  setUp(() => manager = SessionManager());

  test('notifyExpired delivers SessionEvent.expired to listeners', () async {
    final received = <SessionEvent>[];
    final done = Completer<void>();
    final sub = manager.events.listen((event) {
      received.add(event);
      if (!done.isCompleted) done.complete();
    });

    manager.notifyExpired();
    await done.future.timeout(const Duration(seconds: 5));
    await sub.cancel();

    expect(received, [SessionEvent.expired]);
  });

  test('broadcasts to multiple concurrent listeners', () async {
    final first = <SessionEvent>[];
    final second = <SessionEvent>[];

    manager.events.listen(first.add);
    manager.events.listen(second.add);
    manager.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    expect(first, [SessionEvent.expired]);
    expect(second, [SessionEvent.expired]);
  });

  test('no events before notifyExpired', () async {
    var received = 0;

    manager.events.listen((_) => received++);
    await Future<void>.delayed(Duration.zero);

    expect(received, 0);
  });
}
