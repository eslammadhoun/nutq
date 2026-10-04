# Nutq

Arabic speech transcription client app, built with Flutter. Connects to the
`transcription_api` backend (FastAPI, hexagonal architecture).

## Status

Fully on-device: no backend. Jobs are stored locally (Drift/SQLite) and run
one at a time:

- **Pasted text** is summarized directly.
- **Audio and video files** (iOS only) have their audio extracted with FFmpeg
  and transcribed with [Moonshine](https://github.com/moonshine-ai/moonshine),
  then summarized.
- **Summaries** come from a Gemma 3 1B model fine-tuned on Arabic, through
  LiteRT-LM.

See `JOB_PROCESSING.md` (queue and sources), `current_summarization_architecture.md`
and `TRANSCRIPTION.md`.

## Getting started

The models are not in git. Fetch them once after cloning:

```bash
# Summarization model (579 MB): copy from gemma_playground
cp ../gemma_playground/assets/models/gemma3-1b-arabic-summarizer-v3_q4_block32_ekv2048.litertlm assets/models/

# Speech recognition (iOS): framework (~214 MB) and Arabic + English models (~74 MB)
third_party/moonshine/fetch-framework.sh
third_party/moonshine/fetch-model.sh

flutter pub get
cd ios && pod install && cd ..

flutter run                       # use --release (or --profile) to judge speed
flutter analyze --fatal-infos
flutter test                      # unit + widget tests
```

`integration_test/media_transcription_test.dart` runs the real FFmpeg and
Moonshine path on an iPhone or the Simulator; see its header.

## Branching

- `main` — always deployable/stable.
- `develop` — integration branch for in-progress work.
- `fix/*`, `feat/*` — short-lived branches merged into `develop` via PR.
