import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Where downloaded models live, and how much room is left there.
abstract interface class ModelStorage {
  /// The folder that holds every pack. Created if missing.
  Future<String> root();

  /// Free bytes on the volume of [root], or null when unknown.
  Future<int?> freeBytes();

  /// Folders where the inference engine may write its own files next to the
  /// app's data, such as LiteRT's `.xnnpack_cache` on the CPU.
  Future<List<String>> engineCacheFolders();
}

/// Asks `modelStorage` on the `nutq/device` channel (AppDelegate.swift,
/// MainActivity.kt) for a folder that is never backed up: on iOS Application
/// Support marked excluded from iCloud backup, on Android `noBackupFilesDir`.
/// Hundreds of MB of models that can be downloaded again do not belong in a
/// backup.
class PlatformModelStorage implements ModelStorage {
  const PlatformModelStorage();

  static const _channel = MethodChannel('nutq/device');

  @override
  Future<String> root() async {
    try {
      final info = await _channel.invokeMapMethod<String, Object?>('modelStorage');
      final path = info?['path'] as String?;
      if (path != null) return path;
    } on MissingPluginException {
      // Desktop and tests: no native side.
    }
    return '${(await getApplicationSupportDirectory()).path}/models';
  }

  @override
  Future<List<String>> engineCacheFolders() async => [
    (await getApplicationSupportDirectory()).path,
    (await getApplicationDocumentsDirectory()).path,
  ];

  @override
  Future<int?> freeBytes() async {
    try {
      final info = await _channel.invokeMapMethod<String, Object?>('modelStorage');
      return (info?['freeBytes'] as num?)?.toInt();
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
