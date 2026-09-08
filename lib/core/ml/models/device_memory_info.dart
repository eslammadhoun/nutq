/// Best-effort device RAM reading, used to gate the opt-in Gemma 3 4B tier
/// behind a >=6GB threshold (plan Section 5).
///
/// There is no reliable, already-present cross-platform Flutter API for
/// *total device RAM* in this codebase: `dart:io.Platform` exposes nothing
/// about physical memory, and `device_info_plus` (not currently a
/// dependency) does not surface it either — Android's
/// `AndroidDeviceInfo`/iOS's `IosDeviceInfo` both omit total RAM, only a
/// native platform channel (`ActivityManager.MemoryInfo.totalMem` on
/// Android; there is no public iOS API for *physical* device RAM, only
/// `os_proc_available_memory` for the current process's headroom) would
/// give a real cross-platform figure, and implementing/validating that
/// platform channel without a simulator or device to test it against was
/// judged too risky to ship silently-wrong for this workstream.
///
/// So this returns `null` ("unknown") unconditionally today. Callers (see
/// `ModelsCubit`) must treat `null` as "can't verify" and fall back to a
/// storage-size warning rather than blocking the 4B download outright —
/// never silently allow-list a device the check couldn't actually confirm.
/// A real Android/iOS platform-channel implementation is a natural
/// follow-up once there's a device to validate it on.
abstract class DeviceMemoryInfo {
  /// Total physical device RAM in bytes, or `null` if it could not be
  /// determined on this platform/build.
  Future<int?> totalRamBytes();
}

class DeviceMemoryInfoImpl implements DeviceMemoryInfo {
  const DeviceMemoryInfoImpl();

  @override
  Future<int?> totalRamBytes() async => null;
}
