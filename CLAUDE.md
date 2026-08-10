# CLAUDE.md — Nutq Flutter App

Arabic Speech Transcription client app. Connects to the `transcription_api` backend (FastAPI, hexagonal arch).

## Commands

```bash
# Run app (iOS simulator or connected device)
flutter run

# Regenerate code after adding/editing models or API services
dart run build_runner build

# Analyze
flutter analyze

# Tests
flutter test
```

## Architecture

**BLoC/Cubit** for state, **Retrofit + Dio** for networking, **GetIt** for DI, **Freezed** for sealed unions, **json_serializable** for JSON models.

### Folder structure

```
lib/
  core/
    di/             # dependency_injection.dart — GetIt setup (sl)
    network/        # DioFactory, ApiResult<T>, ErrorHandler
    preferences/    # AppPreferences (SharedPreferences wrapper)
    routing/        # AppRouter + Routes constants
    theme/          # AppTheme
  features/
    auth/
      data/
        datasources/  # AuthApiService (Retrofit)
        models/       # AuthModels (json_serializable)
        repositories/ # AuthRepositoryImpl
      domain/
        repositories/ # AuthRepository interface
      presentation/
        cubit/        # AuthCubit + AuthState
        screens/      # LoginScreen, RegisterScreen
        widgets/      # AuthTextField
    jobs/
      presentation/
        screens/      # JobsScreen (placeholder — to be built)
```

### Adding a new feature

1. Create `lib/features/<name>/` with data/domain/presentation sub-folders.
2. Define Retrofit service → run `dart run build_runner build`.
3. Implement repository interface.
4. Register in `core/di/dependency_injection.dart`.
5. Add route in `core/routing/routes.dart` + `app_router.dart`.

### Backend API

Base URL configured via `--dart-define=API_BASE_URL=http://<LAN_IP>:8000/v1`.
Physical device **cannot** reach `localhost` — use Mac's LAN IP on the same WiFi.

Auth flow: `POST /auth/register` → `POST /auth/login` → JWT stored in `FlutterSecureStorage`.

### DI note

`sl` is the global `GetIt` instance from `core/di/dependency_injection.dart`.
Repos → `registerLazySingleton`, Cubits → `registerFactory`.
