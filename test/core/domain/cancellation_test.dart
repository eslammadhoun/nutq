import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';

void main() {
  test('onCancel listeners run once, on the first cancel', () {
    final token = CancellationToken();
    var calls = 0;
    token.onCancel(() => calls++);
    token
      ..cancel()
      ..cancel();
    expect(calls, 1);
  });

  test('a listener added after cancel runs at once', () {
    final token = CancellationToken()..cancel();
    var called = false;
    token.onCancel(() => called = true);
    expect(called, isTrue);
  });

  test('an unregistered listener is not called', () {
    final token = CancellationToken();
    var called = false;
    final remove = token.onCancel(() => called = true);
    remove();
    token.cancel();
    expect(called, isFalse);
  });
}
