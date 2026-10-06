import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/foreground_gate.dart';

/// [ForegroundGate] backed by the Flutter app lifecycle.
class LifecycleForegroundGate implements ForegroundGate {
  const LifecycleForegroundGate();

  /// `resumed` is on screen. A null state is before the first frame, when the
  /// app is starting in the foreground.
  @override
  bool get isInForeground => _inForeground;

  static bool get _inForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  @override
  Stream<bool> get changes {
    late final StreamController<bool> controller;
    AppLifecycleListener? listener;
    controller = StreamController<bool>.broadcast(
      onListen: () => listener = AppLifecycleListener(
        onHide: () => controller.add(false),
        onResume: () => controller.add(true),
      ),
      onCancel: () {
        listener?.dispose();
        listener = null;
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }

  @override
  Future<void> whenInForeground(CancellationToken cancellation) async {
    cancellation.throwIfCancelled();
    if (_inForeground) return;

    final back = Completer<void>();
    final listener = AppLifecycleListener(
      onResume: () {
        if (!back.isCompleted) back.complete();
      },
    );
    final stopWaiting = cancellation.onCancel(() {
      if (!back.isCompleted) back.completeError(const CancelledException());
    });
    try {
      await back.future;
    } finally {
      stopWaiting();
      listener.dispose();
    }
  }
}
