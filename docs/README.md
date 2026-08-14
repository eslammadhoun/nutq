# Nutq

Arabic speech transcription client app, built with Flutter. Connects to the
`transcription_api` backend (FastAPI, hexagonal architecture).

## Status

Early stage: authentication (register/login/logout) is implemented end-to-end.
The jobs feature (list, create, detail) is scaffolded but not yet built out.
See `SRS.md` for the full product spec and `SYSTEM_DESIGN.md` for the client
architecture.

## Stack

- **State management:** flutter_bloc (Cubit)
- **Networking:** Dio + Retrofit
- **DI:** get_it
- **Models:** Freezed + json_serializable
- **Secure storage:** flutter_secure_storage (JWT), shared_preferences (app prefs)

## Getting started

```bash
# Install dependencies
flutter pub get

# Regenerate generated code (Retrofit services, Freezed unions, JSON models)
dart run build_runner build --delete-conflicting-outputs

# Run against a local backend (use your Mac's LAN IP for physical devices —
# localhost is not reachable from a real device)
flutter run --dart-define=API_BASE_URL=http://<LAN_IP>:8000/v1

# Static analysis
flutter analyze

# Tests
flutter test
```

## Project structure

```
lib/
  core/           # DI, networking, preferences, routing, theme — shared across features
  features/
    auth/         # data/domain/presentation slices for register/login/logout
    jobs/         # placeholder — job list/create/detail to be built
```

See `CLAUDE.md` for the full architectural conventions used in this repo.

## Branching

- `main` — always deployable/stable.
- `develop` — integration branch for in-progress work.
- `fix/*`, `feat/*` — short-lived branches merged into `develop` via PR.
