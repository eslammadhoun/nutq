import 'dart:async';

/// Passes values to [sink] at most once per [interval], always delivering the
/// latest value: the first value goes through immediately and starts a
/// cooldown; values arriving during the cooldown are coalesced and the newest
/// is delivered when it ends (starting another cooldown).
///
/// Used to keep a fast producer (for example a model streaming words) from
/// rebuilding the UI on every value. It only uses timers, never the wall
/// clock, so it behaves the same under `fakeAsync`.
class Throttler<T> {
  Throttler(this.interval, this._sink);

  final Duration interval;
  final void Function(T value) _sink;

  Timer? _cooldown;
  T? _pending;
  bool _hasPending = false;

  void add(T value) {
    if (_cooldown == null) {
      _deliver(value);
    } else {
      _pending = value;
      _hasPending = true;
    }
  }

  /// Delivers the pending value now, if any.
  void flush() {
    if (!_hasPending) return;
    final value = _pending as T;
    _pending = null;
    _hasPending = false;
    _deliver(value);
  }

  /// Drops the pending value and stops the cooldown.
  void cancel() {
    _cooldown?.cancel();
    _cooldown = null;
    _pending = null;
    _hasPending = false;
  }

  void _deliver(T value) {
    _cooldown?.cancel();
    _cooldown = Timer(interval, _cooldownEnded);
    _sink(value);
  }

  void _cooldownEnded() {
    _cooldown = null;
    flush();
  }
}
