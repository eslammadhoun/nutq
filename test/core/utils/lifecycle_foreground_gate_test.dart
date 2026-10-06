import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/utils/lifecycle_foreground_gate.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const gate = LifecycleForegroundGate();

  tearDown(() => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));

  test('passes at once in the foreground', () async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await gate.whenInForeground(CancellationToken());
  });

  test('in the background, waits until the app is back', () async {
    binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    var passed = false;
    final waiting = gate.whenInForeground(CancellationToken()).then((_) => passed = true);
    await pumpEventQueue();
    expect(passed, isFalse);

    binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await waiting;
    expect(passed, isTrue);
  });

  test('cancelling while waiting throws CancelledException', () async {
    binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final token = CancellationToken();
    final waiting = gate.whenInForeground(token);
    token.cancel();
    await expectLater(waiting, throwsA(isA<CancelledException>()));
  });
}
