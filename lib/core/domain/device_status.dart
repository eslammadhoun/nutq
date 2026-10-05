import 'package:flutter/foundation.dart';

/// The app's memory and the phone's heat at one moment, for logs.
@immutable
class DeviceSnapshot {
  const DeviceSnapshot({this.footprintMB, this.thermal});

  /// The memory iOS counts against the app; what decides a memory kill.
  final int? footprintMB;

  /// `nominal`, `fair`, `serious` or `critical`.
  final String? thermal;

  @override
  String toString() => 'footprint=${footprintMB ?? '?'}MB thermal=${thermal ?? '?'}';
}

abstract interface class DeviceStatus {
  /// Never throws: unknown values are null.
  Future<DeviceSnapshot> snapshot();
}

/// For tests and platforms without the native channel.
class NoDeviceStatus implements DeviceStatus {
  const NoDeviceStatus();

  @override
  Future<DeviceSnapshot> snapshot() async => const DeviceSnapshot();
}
