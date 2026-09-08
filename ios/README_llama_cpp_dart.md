# iOS native setup for `llama_cpp_dart` (Gemma summarization)

`llama_cpp_dart` 0.9.x ships its iOS/macOS native code as a prebuilt
`llama.xcframework` distributed outside CocoaPods (there is no podspec to
`pod install`), unlike `whisper_ggml`. This step could **not** be performed
in this workstream's environment (no Xcode GUI, no simulator/device to
verify against) and must be done once, manually, before `flutter run`/
`flutter build ios` will work with the Gemma summarization pipeline:

1. Build or download `llama.xcframework` (3 slices: `ios-arm64`,
   `ios-arm64-simulator`, `macos-arm64`) — see the package's
   `tool/build_apple_xcframework.sh`, or a release artifact from
   https://github.com/netdur/llama_cpp_dart if the maintainer publishes one.
2. In Xcode, open `ios/Runner.xcworkspace`, select the `Runner` target →
   **General** → **Frameworks, Libraries, and Embedded Content**, and drag
   `llama.xcframework` in. Set it to **Embed & Sign**.
3. No `Podfile` changes are required — `llama_cpp_dart` is not a CocoaPods
   dependency on iOS. `LlmEngineImpl` calls `LlamaEngine.spawnFromProcess()`
   on iOS/macOS specifically because the framework's symbols become
   available in-process once embedded this way (see that class's doc
   comment).

Android needs no manual step: the package bundles its `libllama.so` via
Flutter's native-assets build hook automatically.
