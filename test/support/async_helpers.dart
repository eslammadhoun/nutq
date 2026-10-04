import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Waits until [condition] is true, polling, instead of sleeping a fixed time
/// that is too short on a busy machine and wastefully long on a fast one.
/// Fails the test if it is still false after [timeout].
Future<void> eventually(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 3),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail(reason ?? 'condition not met within ${timeout.inMilliseconds} ms');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

/// Lets pending work run for a short, fixed time. Only for asserting that
/// something does NOT happen (there is nothing to wait for); use [eventually]
/// whenever something should happen.
Future<void> quietPeriod([Duration duration = const Duration(milliseconds: 60)]) =>
    Future<void>.delayed(duration);
