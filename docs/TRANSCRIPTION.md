# Transcription (audio and video jobs)

On-device speech recognition, ported from `whisper_playground` (October 2026), where Moonshine was
measured against whisper.cpp and came out about 3.8× faster on an iPhone XR. **iOS only:** the
Moonshine bridge is Swift. On other platforms `SpeechRecognizer.isAvailable` is false, no media
source is registered, and the New Job sheet keeps the audio and video tabs disabled.

## Flow

```
New Job sheet ── pick (file_picker) ──► MediaFiles.import ──► job_media/<uuid>.<ext>   (owned by the job)
                                                                    │
ProcessJob ──► MediaTranscriptSource.resolve                        ▼
                 1. AudioExtractor (FFmpeg) ── 16 kHz mono WAV in Caches/extracted_audio   10% of the source bar
                 2. SpeechRecognizer (Moonshine, model = job's source language)          90%
                 3. delete the WAV; return the text, one recognized line per row
              ──► summarize
```

- **Files.** The picker's temporary copy is moved, not copied again, into Application Support
  (`PlatformMediaFiles`), which iOS never purges, and is deleted with the job. `file_picker_darwin`
  is vendored in `third_party/` with one patch (`NUTQ PATCH`): upstream copied every picked file
  a second time on the main thread, which froze the UI for seconds on a large video.
- **Languages.** Moonshine publishes one model per language, and audio run through the wrong one
  comes out as fragments of the other script. The job's source language picks the model
  (`MoonshineModel.of`): `tiny-streaming-ar` (31 MB) or `tiny-streaming-en` (43 MB).
- **Memory.** The bridge reads the WAV in chunks and retires its stream every 5 minutes of audio, so
  memory stays flat however long the file is. The model is released after every run, including a
  failed or cancelled one, so it is never in memory with Gemma.
- **Cancel.** `CancellationToken.onCancel` stops the FFmpeg session or tells the bridge to stop
  after the 20 s chunk in flight.
- **Failures.** Unreadable media → `unsupportedMedia`; missing file → `sourceUnavailable`;
  recognition error → `transcriptionFailed`; disk error while extracting → `insufficientStorage`.

## Native setup

| Piece | Where |
|---|---|
| Bridge (method channel `nutq/moonshine`, events on `nutq/moonshine/progress`) | `ios/Runner/MoonshineBridge.swift`, registered in `AppDelegate.swift` |
| Framework (not committed) | `third_party/moonshine/Moonshine.xcframework`, from `fetch-framework.sh`, linked by the `MoonshineVoice` pod |
| Models (not committed) | `ios/Runner/moonshine_models/`, from `fetch-model.sh`, bundled as a folder reference |

The bridge logs one `[moonshine] …` line per run (load, inference, real-time factor, `covered`)
to the device console, in the same format as whisper_playground.

## Verified

- Unit tests: the source (progress, failures, cancel, cleanup), the recognizer against a mocked
  channel, WAV header parsing, the picker flow in `NewJobCubit`.
- `integration_test/media_transcription_test.dart` on the iOS Simulator (iPhone 17, iOS 26),
  October 2026: Arabic and English `say` samples transcribed almost word for word.

## Not ported yet

From whisper_playground, left out of this first cut:

- **Background running.** Lock-screen progress and keeping a run alive when the app is left
  (`JobBridge.swift`, `UIBackgroundModes`) and keeping the screen awake. Today iOS suspends a long
  transcription once the app is in the background or the phone locks.
- **Resume after a kill.** The playground checkpoints the stable lines and resumes from that frame.
  Here an interrupted job fails as `interrupted` and is started over.
- **Live transcript.** The bridge streams partial lines; Job Detail shows only progress.
- **Android.** No Moonshine bridge yet (the playground's Android work is still in progress).
