import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nutq/features/jobs/domain/services/background_job.dart';
import 'package:nutq/l10n/app_localizations.dart';

/// Talks to `ios/Runner/JobBridge.swift` (silent audio and the lock screen)
/// or, on Android, `JobPlugin.kt` (a foreground service and its notification),
/// which keep a media job running outside the app and show its progress.
///
/// The bridge has no strings of its own: [localizations] supplies them in the
/// app's current language at the start of every job.
class PlatformBackgroundJob implements BackgroundJob {
  PlatformBackgroundJob({
    required this._localizations,
    this._notifyWhenDone = _always,
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler(_onNativeCall);
  }

  static const channelName = 'nutq/background_job';

  final AppLocalizations Function() _localizations;

  /// The Settings switch for the "Summary ready" notification, read when a
  /// job ends.
  final bool Function() _notifyWhenDone;

  static bool _always() => true;
  final MethodChannel _channel;
  final _commands = StreamController<BackgroundJobCommand>.broadcast();

  @override
  Stream<BackgroundJobCommand> get commands => _commands.stream;

  Future<Object?> _onNativeCall(MethodCall call) async {
    if (call.method != 'command') return null;
    switch (call.arguments) {
      case 'pause':
        _commands.add(BackgroundJobCommand.pause);
      case 'resume':
        _commands.add(BackgroundJobCommand.resume);
      case 'cancel':
        _commands.add(BackgroundJobCommand.cancel);
    }
    return null;
  }

  /// The bridge's strings, with `{percent}` and `{title}` left for it to fill.
  static Map<String, String> labelsOf(AppLocalizations l10n) => {
    'locale': l10n.localeName,
    'transcribing': l10n.backgroundJobTranscribing('{percent}'),
    'summarizing': l10n.backgroundJobSummarizing('{percent}'),
    'waitingForApp': l10n.backgroundJobWaitingForApp('{percent}'),
    'paused': l10n.backgroundJobPaused('{percent}'),
    'interruptedTitle': l10n.backgroundJobInterruptedTitle('{percent}'),
    'interruptedBody': l10n.backgroundJobInterruptedBody('{title}'),
    'readyTitle': l10n.backgroundJobReadyTitle,
    'readyBody': l10n.backgroundJobReadyBody('{title}'),
    'doneTitle': l10n.backgroundJobDoneTitle,
    'doneBody': l10n.backgroundJobDoneBody('{title}'),
    // Android's notification buttons and settings names.
    'pauseAction': l10n.backgroundJobPauseAction,
    'resumeAction': l10n.backgroundJobResumeAction,
    'cancelAction': l10n.backgroundJobCancelAction,
    'progressChannel': l10n.backgroundJobProgressChannel,
    'doneChannel': l10n.backgroundJobDoneChannel,
  };

  @override
  Future<void> begin({required String title}) =>
      _invoke('begin', {'title': title, 'labels': labelsOf(_localizations())});

  @override
  Future<void> update({required double progress, Duration? estimatedTotal}) => _invoke('update', {
    'progress': progress,
    if (estimatedTotal != null) 'duration': _seconds(estimatedTotal),
  });

  @override
  Future<void> setPhase(BackgroundJobPhase phase) => _invoke('setPhase', {'phase': phase.name});

  @override
  Future<void> setPaused(bool paused) => _invoke('setPaused', {'paused': paused});

  @override
  Future<void> end({required bool completed}) =>
      _invoke('end', {'completed': completed, 'notify': _notifyWhenDone()});

  Future<void> _invoke(String method, Map<String, Object> arguments) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // No bridge: the job simply runs while the app is open.
    } on PlatformException catch (e) {
      debugPrint('Background job $method failed: ${e.message}');
    }
  }

  static double _seconds(Duration d) => d.inMicroseconds / Duration.microsecondsPerSecond;
}
