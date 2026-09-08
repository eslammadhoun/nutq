// Deliberately no `AudioPreprocessor` class here.
//
// `whisper_ggml` (the chosen `WhisperEngine` backend — see
// `lib/core/ml/whisper/whisper_engine_impl.dart`) already decodes arbitrary
// input audio formats to 16 kHz mono PCM internally before handing off to
// whisper.cpp (it bundles `ffmpeg_kit_flutter_new_min` for exactly this,
// see its `WhisperAudioConvert`). Adding a second, app-owned decode step
// here would just re-run the same ffmpeg conversion twice for no benefit.
//
// `ffmpeg_kit_flutter_new_min` is still a direct dependency of this app
// (see `pubspec.yaml`) — not for format decoding, but for time-based
// slicing in `AudioChunker` (`lib/core/ml/whisper/audio_chunker.dart`),
// which `whisper_ggml` has no equivalent for.
