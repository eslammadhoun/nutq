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
        if call.method == "isSimulator" {
          #if targetEnvironment(simulator)
          result(true)
          #else
          result(false)
          #endif
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
