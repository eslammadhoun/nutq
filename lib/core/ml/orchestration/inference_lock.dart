import 'dart:async';
import 'dart:collection';

/// Process-wide mutual-exclusion lock ensuring whisper.cpp (ASR) and
/// llama.cpp (LLM) inference never run concurrently on the same device
/// (plan Section 5) — both native libraries are heavy CPU/GPU consumers
/// and running them side by side would starve whichever started second
/// (or worse, contend for the same Metal/NDK GPU context).
///
/// A simple FIFO async mutex: [acquire] resolves once every earlier
/// acquirer has [release]d. There is no re-entrancy support — a pipeline
/// that acquires twice on the same call stack will deadlock itself, so
/// callers acquire once around their whole inference call, not per event.
///
/// [AsrPipeline] and `SummarizationPipeline` each take an [InferenceLock]
/// constructor parameter, defaulting to [InferenceLock.shared] — the one
/// process-wide instance both pipelines are expected to actually share in
/// production (nothing besides this default wires them to the same
/// instance, since neither pipeline is constructed via DI yet — see
/// `dependency_injection.dart`'s comment on `ModelDownloadService`).
class InferenceLock {
  InferenceLock();

  /// The instance production callers should share. Tests construct their
  /// own `InferenceLock()` instead, so pipeline tests never contend with
  /// each other via shared static state.
  static final InferenceLock shared = InferenceLock();

  final Queue<Completer<void>> _waiters = Queue();
  bool _locked = false;

  /// True while some caller holds the lock.
  bool get isLocked => _locked;

  /// Waits until the lock is free, then holds it. Always pair with
  /// [release] (ideally in a `try`/`finally`), or use [run].
  Future<void> acquire() {
    if (!_locked) {
      _locked = true;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  /// Releases the lock, handing it to the next waiter (if any) in FIFO
  /// order. A no-op if nothing currently holds the lock.
  void release() {
    if (!_locked) return;
    if (_waiters.isEmpty) {
      _locked = false;
      return;
    }
    final next = _waiters.removeFirst();
    next.complete();
  }

  /// Runs [action] with the lock held, releasing it afterward even if
  /// [action] throws.
  Future<T> run<T>(Future<T> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}
