import 'dart:isolate';

/// Runs CPU-heavy, pure work somewhere other than the UI thread.
///
/// [task] must be a top-level or static function (not a closure over app
/// objects) and [argument] and the result must be sendable between isolates:
/// plain data, records, lists and simple immutable objects — never streams,
/// controllers, sessions or anything holding a native resource.
abstract interface class BackgroundWork {
  Future<R> run<A, R>(R Function(A argument) task, A argument);
}

/// Runs the task in a short-lived isolate. Use in the app.
class IsolateBackgroundWork implements BackgroundWork {
  const IsolateBackgroundWork();

  @override
  Future<R> run<A, R>(R Function(A argument) task, A argument) =>
      Isolate.run(() => task(argument));
}

/// Runs the task right here. Deterministic and fake-async friendly; use in
/// tests and where the work is trivially small.
class InlineBackgroundWork implements BackgroundWork {
  const InlineBackgroundWork();

  @override
  Future<R> run<A, R>(R Function(A argument) task, A argument) =>
      Future.sync(() => task(argument));
}
