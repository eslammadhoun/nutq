---
name: flutter-feature
description: Scaffold a complete new Nutq feature (data → domain → presentation) wired to the transcription API. Use when the user says "create a feature", "scaffold a feature", "add a new feature", or invokes /flutter-feature.
---

# Skill: flutter-feature

Scaffold a complete new Flutter feature in the Nutq app following the project's clean-ish layering: models → Retrofit service + datasource → repository interface + impl → cubit/state → screen → DI → router. The **jobs feature (`lib/features/jobs/`) is the reference implementation** — when in doubt, mirror it.

## Step 0 — Gather requirements

Use `AskUserQuestion` to collect:

1. **Feature name** — PascalCase (e.g. `JobDetail`). All generated names derive from this.
2. **API endpoints** — relative paths + HTTP methods (e.g. `GET /jobs/{id}`). Check `docs/SRS.md` §5 (API mapping) first and propose from there.
3. **Does it need a Cubit + state?** — Yes for data-fetching screens, No for simple static screens.
4. **Request body?** — If POST/PUT, what fields?

Derived names (never ask, always compute):
- `FeatureName` = PascalCase input (e.g. `JobDetail`)
- `featureSnake` = snake_case (e.g. `job_detail`)
- `routeConst` = camelCase (e.g. `jobDetail`)
- `dirPath` = `lib/features/{featureSnake}/`

## Step 1 — Create directory structure

```
lib/features/{featureSnake}/
  data/
    datasources/     # Retrofit service + DataSource interface + impl (one file)
    models/          # Freezed + json_serializable request/response models
    repositories/    # {FeatureName}RepositoryImpl
  domain/
    repositories/    # {FeatureName}Repository interface
  presentation/
    cubit/           # Cubit + State
    models/          # (optional) UI-facing view models mapped from responses
    screens/
    widgets/
```

## Step 2 — Create models

Files: `data/models/{name}_response.dart` / `{name}_request.dart` — one Freezed class per file, following `lib/features/jobs/data/models/job_response.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{featureSnake}_response.freezed.dart';
part '{featureSnake}_response.g.dart';

@freezed
sealed class {FeatureName}Response with _${FeatureName}Response {
  const factory {FeatureName}Response({
    required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // snake_case API fields → @JsonKey(name: '...')
  }) = _{FeatureName}Response;

  factory {FeatureName}Response.fromJson(Map<String, dynamic> json) =>
      _${FeatureName}ResponseFromJson(json);
}
```

**Never hand-write `.g.dart` / `.freezed.dart`** — generated in Step 6.

## Step 3 — Create the Retrofit service + DataSource

File: `data/datasources/{featureSnake}_api_service.dart` — three parts in one file, exactly like `jobs_api_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:nutq/core/network/api_client.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/{featureSnake}/data/models/{featureSnake}_response.dart';

part '{featureSnake}_api_service.g.dart';

/// Retrofit HTTP interface — typed responses
@RestApi()
abstract class {FeatureName}ApiService {
  factory {FeatureName}ApiService(Dio dio, {String baseUrl}) = _{FeatureName}ApiService;

  @GET('/{endpoint}')
  Future<HttpResponse<{FeatureName}Response>> get{FeatureName}();
}

/// Datasource interface — all callers use this (ApiResult + typed models)
abstract interface class {FeatureName}DataSource {
  Future<ApiResult<{FeatureName}Response>> get{FeatureName}();
}

/// Implementation: wraps Retrofit + ApiClient for safe deserialization
class {FeatureName}DataSourceImpl implements {FeatureName}DataSource {
  {FeatureName}DataSourceImpl(this._apiClient, this._retrofit);

  final ApiClient _apiClient;
  final {FeatureName}ApiService _retrofit;

  @override
  Future<ApiResult<{FeatureName}Response>> get{FeatureName}() async {
    final res = await _apiClient.execute(() => _retrofit.get{FeatureName}());
    return res.mapSuccess((http) => http.data);
  }
}
```

Endpoint strings are inlined in `@GET()`/`@POST()` annotations. The base URL comes from Dio config (`--dart-define=API_BASE_URL`) — never hardcode it.

## Step 4 — Create the repository (interface + impl)

File: `domain/repositories/{featureSnake}_repository.dart`:

```dart
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/{featureSnake}/data/models/{featureSnake}_response.dart';

abstract interface class {FeatureName}Repository {
  Future<ApiResult<{FeatureName}Response>> get{FeatureName}();
}
```

File: `data/repositories/{featureSnake}_repository_impl.dart`:

```dart
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/{featureSnake}/data/datasources/{featureSnake}_api_service.dart';
import 'package:nutq/features/{featureSnake}/data/models/{featureSnake}_response.dart';
import 'package:nutq/features/{featureSnake}/domain/repositories/{featureSnake}_repository.dart';

class {FeatureName}RepositoryImpl implements {FeatureName}Repository {
  {FeatureName}RepositoryImpl(this._dataSource);

  final {FeatureName}DataSource _dataSource;

  @override
  Future<ApiResult<{FeatureName}Response>> get{FeatureName}() =>
      _dataSource.get{FeatureName}();
}
```

## Step 5 — Create the State + Cubit

Follow `jobs_state.dart` / `jobs_cubit.dart`: **plain immutable state class with an enum status + `copyWith`** (not Freezed) for list/detail screens; Freezed sealed unions (like `AuthState`) only when the states are truly disjoint.

File: `presentation/cubit/{featureSnake}_state.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/error/api_error.dart';

enum {FeatureName}Status { initial, loading, success, failure }

@immutable
class {FeatureName}State {
  const {FeatureName}State({
    this.status = {FeatureName}Status.initial,
    this.lastError,
  });

  final {FeatureName}Status status;

  /// Raw error from the last failed fetch — localized at display time via
  /// context.l10n (cubits have no BuildContext).
  final ApiError? lastError;

  {FeatureName}State copyWith({
    {FeatureName}Status? status,
    ApiError? lastError,
  }) {
    return {FeatureName}State(
      status: status ?? this.status,
      lastError: lastError,
    );
  }
}
```

File: `presentation/cubit/{featureSnake}_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nutq/features/{featureSnake}/domain/repositories/{featureSnake}_repository.dart';
import 'package:nutq/features/{featureSnake}/presentation/cubit/{featureSnake}_state.dart';

class {FeatureName}Cubit extends Cubit<{FeatureName}State> {
  {FeatureName}Cubit({required {FeatureName}Repository repo})
      : _repo = repo,
        super(const {FeatureName}State());

  final {FeatureName}Repository _repo;

  Future<void> fetch() async {
    emit(state.copyWith(status: {FeatureName}Status.loading));
    final result = await _repo.get{FeatureName}();
    result.when(
      success: (data) => emit(state.copyWith(status: {FeatureName}Status.success)),
      failure: (error) => emit(
        state.copyWith(status: {FeatureName}Status.failure, lastError: error),
      ),
    );
  }
}
```

**Error rule:** cubits store the raw `ApiError` — never pre-format English strings. The UI localizes via `context.l10n` + `lib/core/extensions/error_l10n_extension.dart`.

## Step 6 — Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

Wait for completion; fix annotated classes on failure and retry.

## Step 7 — Create the screen

File: `presentation/screens/{featureSnake}_screen.dart`. Sizing rules (flutter_screenutil_plus):
- widths / horizontal padding → `.w`; heights / vertical padding → `.h`; radii → `.r`; font sizes are inside `context.typography.*` — never inline.
- Gaps: `SizedBox(height: n.h)` / `SizedBox(width: n.w)`.
- Colors: `context.appColors.*` only (from `lib/core/theme/app_colors.dart`). Text styles: `context.typography.*` (from `lib/core/theme/app_typography.dart`). Both via `import 'package:nutq/core/extensions/theme_extension.dart';`.
- Every user-facing string: `context.l10n.<key>` — add keys to **both** `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, then run `flutter gen-l10n` (or hot-restart; `generate: true` regenerates on build).
- Reuse `GlobalButton` / `GlobalTextField` from `lib/core/widgets/`.
- Scoped `BlocBuilder`/`BlocConsumer` (wrap only the reacting subtree); `ListView.builder` for dynamic lists with `RepaintBoundary` around repeated items; `const` wherever possible.

## Step 8 — Register in DI

Edit `lib/core/di/dependency_injection.dart`, inside `setupDI()` at the end:

```dart
// {FeatureName} feature
sl.registerLazySingleton<{FeatureName}ApiService>(() => {FeatureName}ApiService(sl<Dio>()));
sl.registerLazySingleton<{FeatureName}DataSource>(
  () => {FeatureName}DataSourceImpl(sl<ApiClient>(), sl<{FeatureName}ApiService>()),
);
sl.registerLazySingleton<{FeatureName}Repository>(
  () => {FeatureName}RepositoryImpl(sl<{FeatureName}DataSource>()),
);
sl.registerFactory<{FeatureName}Cubit>(() => {FeatureName}Cubit(repo: sl<{FeatureName}Repository>()));
```

Lifetimes: ApiService/DataSource/Repository → `registerLazySingleton`; Cubit → `registerFactory`.

## Step 9 — Register route

`lib/core/routing/routes.dart`:
```dart
static const {routeConst} = '/{featureSnake with dashes}';
```

`lib/core/routing/app_router.dart` — new `case` using the project's `_buildRoute` fade transition:
```dart
case Routes.{routeConst}:
  return _buildRoute(
    settings,
    BlocProvider<{FeatureName}Cubit>(
      create: (context) => sl<{FeatureName}Cubit>(),
      child: const {FeatureName}Screen(),
    ),
  );
```

Note: screens hosted as tabs inside `HomeScreen` get their `BlocProvider` in `home_screen.dart` (like `JobsCubit`), not in the router.

## Step 10 — Test

Add at least one cubit test: `test/features/{featureSnake}/presentation/cubit/{featureSnake}_cubit_test.dart` using a fake `{FeatureName}Repository` returning canned `ApiResult.success` / `ApiResult.failure` values.

## Step 11 — Verify

1. `flutter analyze` — zero issues (CI runs `--fatal-infos`).
2. `flutter test` — all pass.
3. Confirm generated files exist for every `part` directive.
4. Navigate to the new screen and confirm it loads.

## Rules

- **Codegen**: never hand-edit `*.g.dart` / `*.freezed.dart`.
- **Theming**: `context.appColors.*` / `context.typography.*` only — no raw hex, no `Colors.*`, no inline `TextStyle`. Missing token → add it to `AppColors` (both light AND dark palettes, plus `copyWith`/`lerp`) and update `test/core/theme/app_colors_test.dart`'s token count.
- **Localization**: no hardcoded user-facing strings; every key goes into both ARB files (English + Arabic).
- **Errors**: `ApiError` travels raw through state; UI localizes. Error/empty/retry UI mirrors `jobs_list.dart`.
- **Networking**: all calls through `ApiClient.execute` → `ApiResult`; refresh/auth handled by interceptors — never manual token handling in features.
- **Simple screens (no API)**: skip Steps 2–6, 8 (data layers + DI beyond a factory Cubit if UI state is needed).
