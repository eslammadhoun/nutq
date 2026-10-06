import 'package:flutter/services.dart';
import 'package:nutq/core/domain/device_status.dart';

/// Reads `status` from the `nutq/device` channel in `ios/Runner/AppDelegate.swift`.
class PlatformDeviceStatus implements DeviceStatus {
  const PlatformDeviceStatus();

  static const _channel = MethodChannel('nutq/device');

  @override
  Future<DeviceSnapshot> snapshot() async {
    try {
      final status = await _channel.invokeMapMethod<String, Object?>('status');
      return DeviceSnapshot(
        footprintMB: status?['footprintMB'] as int?,
        thermal: status?['thermal'] as String?,
      );
    } on MissingPluginException {
      return const DeviceSnapshot();
    } on PlatformException {
      return const DeviceSnapshot();
    }
  }
}
