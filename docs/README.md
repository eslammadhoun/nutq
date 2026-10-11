# Nutq

Arabic speech transcription client app, built with Flutter. Connects to the
`transcription_api` backend (FastAPI, hexagonal architecture).

## Status

Fully on-device: no backend. Jobs are stored locally (Drift/SQLite) and run
one at a time:

- **Pasted text** is summarized directly.
- **Audio and video files** (iOS and Android) have their audio extracted with FFmpeg
  and transcribed with [Moonshine](https://github.com/moonshine-ai/moonshine),
  then summarized.
- **Summaries** come from a Gemma 3 1B model fine-tuned on Arabic, through
  LiteRT-LM.

See `JOB_PROCESSING.md` (queue and sources), `current_summarization_architecture.md`
and `TRANSCRIPTION.md`.

## AI models

The app ships without its models (~96 MB on iOS) and downloads them after install, listed with
their sizes and SHA-256 in `assets/models/manifest.json`:

| Model | Size | Hosted at |
|---|---|---|
| Gemma 3 1B Arabic summarizer (`.litertlm`) | 553 MB | [huggingface.co/EslamMad3/gemma3-1b-arabic-summarizer-litertlm](https://huggingface.co/EslamMad3/gemma3-1b-arabic-summarizer-litertlm) |
| Moonshine tiny streaming, Arabic | 31 MB | download.moonshine.ai (official) |
| Moonshine tiny streaming, English | 43 MB | download.moonshine.ai (official) |

Onboarding offers the summarizer and Arabic speech; a job asks for whatever it still needs, and
Settings → AI models downloads or deletes each one. Downloads resume after an interruption, a file
is used only once its checksum matches, and the models live in a folder excluded from backups
(`lib/features/ai_models/`). To ship new weights, upload them, then update the manifest's `url`,
`bytes`, `sha256` and `version`: a new version goes to its own folder and the old one is removed.

## Getting started

The AI models are not part of the app: it downloads them on first use (see "AI models" below).
Only the Moonshine framework for iOS is fetched after cloning:

```bash
# Speech recognition (iOS): framework (~214 MB)
third_party/moonshine/fetch-framework.sh

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
