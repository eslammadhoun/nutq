import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/alerts/domain/alerts_repository.dart';
import 'package:nutq/features/alerts/domain/job_alert.dart';

@immutable
class AlertsState {
  const AlertsState({
    this.alerts = const [],
    this.unread = const {},
    this.loaded = false,
    this.fresh,
  });

  final List<JobAlert> alerts;

  /// Job ids of alerts the user has not seen; drawn with a dot and counted on
  /// the tab badge.
  final Set<String> unread;

  final bool loaded;

  /// A job that just finished while the app is open, for a banner. Cleared
  /// once shown.
  final JobAlert? fresh;

  int get unreadCount => unread.length;

  AlertsState copyWith({
    List<JobAlert>? alerts,
    Set<String>? unread,
    bool? loaded,
    JobAlert? fresh,
    bool clearFresh = false,
  }) => AlertsState(
    alerts: alerts ?? this.alerts,
    unread: unread ?? this.unread,
    loaded: loaded ?? this.loaded,
    fresh: clearFresh ? null : (fresh ?? this.fresh),
  );
}

/// The Alerts tab and its badge: finished jobs, which are unread, and a
/// banner for one that finishes while the app is open.
class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const AlertsState()) {
    _subscription = _repository.watchAlerts().listen(_onAlerts);
  }

  final AlertsRepository _repository;
  final DateTime Function() _now;
  late final StreamSubscription<List<JobAlert>> _subscription;

  /// Whether the Alerts tab is on screen: alerts arriving then are seen at
  /// once.
  bool _open = false;

  void _onAlerts(List<JobAlert> alerts) {
    if (isClosed) return;
    final seenAt = _repository.seenAt;
    final known = {for (final a in state.alerts) a.jobId};
    // Nothing is fresh on the first load: those finished before this session.
    final arrived = state.loaded
        ? alerts.where((a) => !known.contains(a.jobId)).toList()
        : const <JobAlert>[];
    final unread = {
      for (final a in alerts)
        if (!_open && (seenAt == null || a.at.isAfter(seenAt))) a.jobId,
      // Still dotted while the tab is open, until it is left.
      if (_open) ...state.unread.where((id) => alerts.any((a) => a.jobId == id)),
    };
    emit(
      state.copyWith(
        alerts: alerts,
        unread: unread,
        loaded: true,
        fresh: arrived.isEmpty ? null : arrived.first,
      ),
    );
    if (_open && arrived.isNotEmpty) unawaited(_repository.markSeen(_now()));
  }

  /// The Alerts tab came on screen: everything listed is now seen, though the
  /// dots stay until the tab is left so the user can tell what is new.
  Future<void> opened() async {
    _open = true;
    await _repository.markSeen(_now());
  }

  void closed() {
    _open = false;
    if (state.unread.isNotEmpty) emit(state.copyWith(unread: const {}));
  }

  void bannerShown() => emit(state.copyWith(clearFresh: true));

  Future<void> dismiss(String jobId) async {
    emit(
      state.copyWith(
        alerts: [
          for (final a in state.alerts)
            if (a.jobId != jobId) a,
        ],
        unread: {...state.unread}..remove(jobId),
      ),
    );
    await _repository.dismiss([jobId]);
  }

  Future<void> clearAll() async {
    final ids = [for (final a in state.alerts) a.jobId];
    emit(state.copyWith(alerts: const [], unread: const {}));
    await _repository.dismiss(ids);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
