import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nutq/features/transcription/domain/background_job.dart';
import 'package:nutq/l10n/app_localizations.dart';

/// Talks to `ios/Runner/JobBridge.swift`, which keeps the app alive in the
/// background with silent audio and shows the job on the lock screen.
///
/// The bridge has no strings of its own: [localizations] supplies them in the
/// app's current language at the start of every job.
class IosBackgroundJob implements BackgroundJob {
  IosBackgroundJob({required this._localizations, MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler(_onNativeCall);
  }

  static const channelName = 'nutq/background_job';

  final AppLocalizations Function() _localizations;
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
    }
    return null;
  }

  /// The bridge's strings, with `{percent}` and `{title}` left for it to fill.
  static Map<String, String> labelsOf(AppLocalizations l10n) => {
    'locale': l10n.localeName,
    'running': l10n.backgroundJobRunning('{percent}'),
    'paused': l10n.backgroundJobPaused('{percent}'),
    'interruptedTitle': l10n.backgroundJobInterruptedTitle('{percent}'),
    'interruptedBody': l10n.backgroundJobInterruptedBody('{title}'),
    'readyTitle': l10n.backgroundJobReadyTitle,
    'readyBody': l10n.backgroundJobReadyBody('{title}'),
  };

  @override
  Future<void> begin({required String title, Duration? duration}) => _invoke('begin', {
    'title': title,
    'labels': labelsOf(_localizations()),
    if (duration != null) 'duration': _seconds(duration),
  });

  @override
  Future<void> update({required double progress, Duration? duration}) => _invoke('update', {
    'progress': progress,
    if (duration != null) 'duration': _seconds(duration),
  });

  @override
  Future<void> setPaused(bool paused) => _invoke('setPaused', {'paused': paused});

  @override
  Future<void> end({required bool completed}) => _invoke('end', {'completed': completed});

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
