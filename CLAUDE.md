# CLAUDE.md — Nutq Flutter App

Arabic Speech Transcription client app. Connects to the `transcription_api` backend (FastAPI, hexagonal arch, lives at `/Users/mac/Desktop/transcription_api`).

## Commands

```bash
# Run app (iOS simulator or connected device)
flutter run --dart-define=API_BASE_URL=http://<LAN_IP>:8000/v1

# Regenerate code after adding/editing models or API services
dart run build_runner build --delete-conflicting-outputs

# Regenerate localizations after editing lib/l10n/*.arb
flutter gen-l10n

# Analyze (CI runs with --fatal-infos — infos fail the build)
flutter analyze --fatal-infos

# Tests
flutter test
```

## Docs — read before building features

- `docs/SRS.md` — 21 user stories (Auth U1–U4, Jobs J1–J10, Settings S1–S4, Notifications N1–N3), 9 screen specs, and the API-to-screen mapping. **The source of truth for what to build.**
- `docs/DESIGN_SYSTEM.md` — colors, typography, spacing tokens.
- `docs/SYSTEM_DESIGN.md` — client architecture decisions.

## Architecture

**BLoC/Cubit** for state, **Retrofit + Dio** for networking, **GetIt** for DI, **Freezed** for data models/sealed unions, **json_serializable** for JSON, **flutter_screenutil_plus** for responsive sizing, **gen-l10n** for Arabic/English localization.

### Folder structure

```
lib/
  core/
    di/             # dependency_injection.dart — GetIt setup (sl)
    extensions/     # theme_extension (context.appColors/.typography/.l10n), error_l10n_extension
    locale/         # LocaleCubit — persisted language choice (ar/en)
    network/        # DioFactory + interceptors, ApiClient, ApiResult<T>, ApiError, TokenRefresher
    preferences/    # AppPreferences (SharedPreferences wrapper)
    routing/        # AppRouter (+ navigatorKey) + Routes constants
    session/        # SessionManager — broadcasts session-expiry → redirect to login
    theme/          # AppTheme, AppColors (light+dark palettes), AppTypography
    utils/          # Validators, helpers
    widgets/        # GlobalButton, GlobalTextField, AppBottomNavBar, NutqLogo, VersionPill
  l10n/             # app_en.arb + app_ar.arb (+ generated AppLocalizations)
  features/
    auth/           # ✅ full data/domain/presentation — login + register
    jobs/           # ✅ full — list, filters, pagination, new-job sheet. REFERENCE FEATURE.
    home/           # tab shell hosting Jobs/Alerts/Profile behind the bottom nav
    onBoarding/     # splash + onboarding screens
    alerts/         # placeholder (SRS 4.8 Notifications — not started)
    profile/        # placeholder (SRS 4.9 Profile/Settings — not started)
```

Feature layering (mirror `jobs/`, the most complete reference):
`data/{datasources,models,repositories}` → `domain/repositories` (interface) → `presentation/{cubit,models,screens,widgets}`.

### Key conventions

- **Theming**: `context.appColors.*` and `context.typography.*` (via `core/extensions/theme_extension.dart`). Never raw hex, `Colors.*`, or inline `TextStyle`. New color tokens go into both light AND dark `AppColors` palettes + the token-count check in `test/core/theme/app_colors_test.dart`.
- **Localization**: every user-facing string is `context.l10n.<key>`, with the key in both `lib/l10n/app_en.arb` and `app_ar.arb`. The app is bilingual (Arabic RTL / English LTR) — use `EdgeInsetsDirectional`/start-end where sides matter.
- **Errors**: cubits carry the raw `ApiError` in state (`lastError` / `AuthState.failure(error)`); the UI localizes it at display time via `error_l10n_extension.dart`. Never pre-format English messages in a cubit.
- **Sizing**: `.w` / `.h` / `.r` everywhere (screenutil); gaps via `SizedBox(height: n.h)`.
- **DI** (`sl` = global GetIt): ApiService/DataSource/Repository → `registerLazySingleton`; Cubits → `registerFactory`. Tab screens (Jobs/Alerts/Profile) get their `BlocProvider` in `home_screen.dart`, routed screens in `app_router.dart`.
- **Auth/session**: JWT in `FlutterSecureStorage`; refresh token sent in request **body**; token refresh is single-flight in `TokenRefresherImpl`; `SessionManager` broadcasts expiry and `main.dart` redirects to login. Features never touch tokens directly — interceptors handle it.

## Workflow

- Branch `feature/<name>` off `develop` → grouped conventional commits (`feat(jobs): ...`, `fix(core/network): ...`) → PR into `develop` → CI (`flutter analyze --fatal-infos` + `flutter test`) → merge. **Group commits by concern, never one big commit.**
- Definition of done: `flutter analyze` clean, `flutter test` green, both ARB files updated, screen verified in light+dark and Arabic+English.
- New features should ship with at least a cubit test (fake the repository interface, return canned `ApiResult` values).

## Orchestration — use the skills

- **`/flutter-feature`** — scaffold a new API-backed feature end-to-end (models → datasource → repo → cubit → screen → DI → route). Checks `docs/SRS.md` for endpoints.
- **`/figma-screen`** — implement a screen from a Figma URL with token mapping and widget separation.
- **`/code-review`** — run before opening a PR.

## Backend API

Base URL via `--dart-define=API_BASE_URL=http://<LAN_IP>:8000/v1`. Physical device **cannot** reach `localhost` — use the Mac's LAN IP on the same WiFi.

Auth flow: `POST /auth/register` → `POST /auth/login` → JWT stored in `FlutterSecureStorage`. Jobs: cursor-paginated `GET /jobs`, `POST /jobs` (source types: text, upload, url, youtube), `GET /jobs/{id}`, cancel/confirm endpoints.
