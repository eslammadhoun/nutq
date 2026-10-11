import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // On-device speech recognition for audio and video jobs. Not a pub package,
    // so it is registered by hand rather than by the generated registrant.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MoonshineBridge") {
      MoonshineBridge.register(with: registrar)
    }

    // Keeps a transcription going when the user leaves the app, and shows its
    // progress on the lock screen.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "JobBridge") {
      JobBridge.register(with: registrar)
    }

    // The summarizer runs on the CPU in the Simulator, whose emulated Metal
    // makes the GPU backend produce garbage (FlutterGemmaRuntime).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NutqDevice") {
      let channel = FlutterMethodChannel(
        name: "nutq/device", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "isSimulator":
          #if targetEnvironment(simulator)
          result(true)
          #else
          result(false)
          #endif
        case "status":
          // For logs: the memory iOS counts against the app (what decides a
          // memory kill) and the phone's thermal state.
          result([
            "footprintMB": AppDelegate.footprintMegabytes(),
            "thermal": AppDelegate.thermalState(),
          ])
        case "modelStorage":
          do {
            result(try AppDelegate.modelStorage())
          } catch {
            result(
              FlutterError(
                code: "model_storage", message: error.localizedDescription, details: nil))
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  /// The folder for downloaded AI models (ModelStorage in Dart) and the room
  /// left on its volume. Application Support is backed up to iCloud by
  /// default; models that can be downloaded again must not be.
  static func modelStorage() throws -> [String: Any] {
    var url = try FileManager.default.url(
      for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
    ).appendingPathComponent("models", isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try url.setResourceValues(values)
    let free = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
      .volumeAvailableCapacityForImportantUsage
    var info: [String: Any] = ["path": url.path]
    if let free { info["freeBytes"] = free }
    return info
  }

  /// Physical footprint in MB: the figure iOS compares against the app's
  /// memory limit. -1 if unavailable.
  static func footprintMegabytes() -> Int {
    var info = task_vm_info_data_t()
    var count = mach_msg_type_number_t(
      MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
    let status = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
      }
    }
    return status == KERN_SUCCESS ? Int(info.phys_footprint / 1_048_576) : -1
  }

  static func thermalState() -> String {
    switch ProcessInfo.processInfo.thermalState {
    case .nominal: return "nominal"
    case .fair: return "fair"
    case .serious: return "serious"
    case .critical: return "critical"
    @unknown default: return "unknown"
    }
  }
}
