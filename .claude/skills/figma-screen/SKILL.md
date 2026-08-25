---
name: figma-screen
description: Implement a Flutter screen in the Nutq app from a Figma design URL — Figma inspection → optional Cubit scaffold → widget-separated screen → route registration. Use when the user shares a Figma URL and asks to implement/build a screen, or invokes /figma-screen.
---

# Skill: figma-screen

Implement a Flutter screen from a Figma design URL following Nutq's architecture: Figma inspection → optional Cubit/State scaffold → widget-separated screen → route registration. The **jobs feature (`lib/features/jobs/presentation/`) is the reference implementation.**

---

## Step 0 — Gather requirements

Use `AskUserQuestion` to collect **all four** before doing any work:

1. **Figma design URL** — full `figma.com/design/...` URL with `node-id`.
2. **Screen name** — PascalCase (e.g. `JobDetail`).
3. **Location** — `new` (new feature folder) or `existing:<featureName>` (e.g. `existing:jobs`).
4. **Does this screen need its own Cubit?** — `yes` scaffolds a UI-only Cubit (no API; the data layer is wired separately via `/flutter-feature`); `no` → Step 0b.

## Step 0b — Follow-up when "no" to a new Cubit

Use `AskUserQuestion` with two options:
- **Link to an existing Cubit** — ask which (e.g. `JobsCubit`); scan `lib/features/` for its import path and state type first. Record as `linkedCubit`.
- **Pure UI** — plain `StatelessWidget`, no BLoC anywhere.

Set `cubitsMode` ∈ `new` | `linked:<CubitClassName>` | `none`.

---

## Derived names (compute, never ask)
- `ScreenName` = PascalCase; `screenSnake` = snake_case; `routeConst` = camelCase.
- `featureDir` = `lib/features/{screenSnake}/` (new) or the existing feature root.
- Screen file → `{featureDir}/presentation/screens/{screenSnake}_screen.dart`.
- Widgets → `{featureDir}/presentation/widgets/` — for a multi-screen feature, group this screen's widgets in `presentation/widgets/{screenSnake}_widgets/` (pattern: `jobs/presentation/widgets/new_job_widgets/`).
- Cubit/state → `{featureDir}/presentation/cubit/`.

---

## Step 1 — Inspect the Figma design

Parse the URL: `figma.com/design/:fileKey/:title?node-id=1-6429` → `nodeId = "1:6429"`. Load the Figma MCP tool schema, then:

```
get_design_context(fileKey: "...", nodeId: "...", depth: 5)
```

Extract and document:
- Layout structure (Scaffold shape, scroll behavior, fixed header/footer).
- Every visual section and its children.
- **Colors** — map each to the nearest `context.appColors.*` token (`lib/core/theme/app_colors.dart`). Missing token → add it to `AppColors` in **both light and dark palettes**, plus `copyWith`/`lerp`/constructor, and bump the token count in `test/core/theme/app_colors_test.dart`.
- **Typography** — map to `context.typography.*` (`lib/core/theme/app_typography.dart`); extend `AppTypography` if missing.
- Spacing → `.w` / `.h` / `.r`.
- Assets — SVGs go in `assets/svgs/` (already declared in pubspec).
- Interactive elements (buttons, tabs, inputs).
- Compare against the screen's spec in `docs/SRS.md` §4 and `docs/DESIGN_SYSTEM.md` if applicable.

> **Enforced:** never hardcode `Color(0xff...)`, `Colors.*`, or inline `TextStyle(...)`. Tokens only; extend the token source first if one is missing.

---

## Step 2 — Plan the widget tree

```
{ScreenName}Screen              ← root, Scaffold + SafeArea
  ├─ {SectionA}                 ← one widget file per logical visual block
  │    └─ {ItemA}Card           ← one file per repeated list item
  └─ {SectionB}
```

- Every named visual section → its own widget file.
- Repeated list items → own file, `RepaintBoundary` at root when used in `ListView.builder`.
- Reuse `GlobalButton`, `GlobalTextField`, `NutqLogo`, `AppBottomNavBar`, `VersionPill` from `lib/core/widgets/` — don't recreate.
- Root screen file imports only section-level children.

---

## Step 3 — (Conditional) Scaffold or link Cubit

### cubitsMode = `new` — UI-only Cubit

`presentation/cubit/{screenSnake}_state.dart` — plain `@immutable` class + `copyWith` (NOT Freezed; Freezed sealed unions are for data/API states only):

```dart
import 'package:flutter/foundation.dart';

@immutable
class {ScreenName}State {
  const {ScreenName}State();

  {ScreenName}State copyWith() => const {ScreenName}State();
}
```

`presentation/cubit/{screenSnake}_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/{feature}/presentation/cubit/{screenSnake}_state.dart';

class {ScreenName}Cubit extends Cubit<{ScreenName}State> {
  {ScreenName}Cubit() : super(const {ScreenName}State());
}
```

Register in `lib/core/di/dependency_injection.dart`: `sl.registerFactory<{ScreenName}Cubit>(() => {ScreenName}Cubit());`

### cubitsMode = `linked:<Cubit>` — reuse existing
No new files. Import the existing Cubit/State; scoped `BlocBuilder`/`BlocConsumer` in the widgets that react. Provider goes where the feature already provides it (router case, or `home_screen.dart` for tab screens).

### cubitsMode = `none` — pure UI
Plain `StatelessWidget`; no BLoC imports anywhere.

---

## Step 4 — Create widget files

One file per Step 2 component under `presentation/widgets/` (or `widgets/{screenSnake}_widgets/`).

Rules:
- `StatelessWidget` by default; `StatefulWidget` only for owned controllers/animations.
- Sizing: `.w` widths, `.h` heights, `.r` radii; gaps via `SizedBox(height: n.h)` / `SizedBox(width: n.w)`; `double.infinity` exempt.
- Styles: `context.appColors.*` + `context.typography.*` via `import 'package:nutq/core/extensions/theme_extension.dart';` — supports light AND dark mode automatically; verify both.
- **Strings: `context.l10n.<key>` only** — add every key to both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. The app is bilingual (Arabic RTL + English LTR): use `EdgeInsetsDirectional` / `start`/`end` alignment where sides matter, and verify the layout mirrors correctly in Arabic.
- SVGs: `SvgPicture.asset('assets/svgs/{file}.svg')`.
- Search bars: real `TextFormField` with `InputDecoration` — never a fake `Container`+`Text`.
- Scoped BLoC: `BlocBuilder` wraps only the reacting subtree; use `buildWhen` to limit rebuilds (see `jobs_filter_chips.dart`).
- `const` everywhere possible. No comments explaining what code does.

---

## Step 5 — Create the screen file

`presentation/screens/{screenSnake}_screen.dart`. Follow `jobs_screen.dart` for structure. Key rules:
- `Scaffold` background via `context.appColors.*` (the app-level `DecoratedBox` in `main.dart` already paints the page gradient — check whether the screen needs its own background at all).
- `SafeArea` at root (`bottom: false` when a bottom nav/CTA handles the inset).
- Scrollable content in `SingleChildScrollView`/`ListView`; `RefreshIndicator` for refreshable lists.
- `BlocConsumer` wraps the body column, not the `Scaffold`.

---

## Step 6 — Register route

`lib/core/routing/routes.dart`: `static const {routeConst} = '/{route-path}';`

`lib/core/routing/app_router.dart` — new `case` using `_buildRoute` (project fade transition):

```dart
// none:
case Routes.{routeConst}:
  return _buildRoute(settings, const {ScreenName}Screen());

// new or linked:
case Routes.{routeConst}:
  return _buildRoute(
    settings,
    BlocProvider<{CubitClass}>(
      create: (context) => sl<{CubitClass}>(),
      child: const {ScreenName}Screen(),
    ),
  );
```

Tab screens hosted in `HomeScreen` get their provider in `home_screen.dart` instead.

---

## Step 7 — Verify

```bash
flutter analyze
```

Zero issues required (CI runs `--fatal-infos`). Also confirm:
- Only `context.appColors.*` / `context.typography.*` / `context.l10n.*` — no raw hex, `Colors.*`, inline `TextStyle`, or hardcoded strings.
- All dimensions use `.w` / `.h` / `.r`.
- Both ARB files updated for every new key.
- Screen renders correctly in light + dark mode and in Arabic (RTL) + English.

---

## Hard rules (violations break the skill)

| Rule | Detail |
|------|--------|
| Colors | `context.appColors.*` only — extend `AppColors` (light + dark + test count) if missing |
| Text styles | `context.typography.*` only — extend `AppTypography` if missing |
| Strings | `context.l10n.*` only — keys in both `app_en.arb` and `app_ar.arb` |
| RTL | `EdgeInsetsDirectional` / start-end where sides matter; verify Arabic layout |
| Sizing | `.w` widths, `.h` heights, `.r` radii — no raw numbers |
| Widget separation | One file per visual section, one per list item type |
| UI Cubit state | `@immutable` plain class + `copyWith`, NOT Freezed |
| Data Cubit state | status-enum state + raw `ApiError` (see jobs) — wired via /flutter-feature |
| Search bars | Always `TextFormField` — never a fake bar |
| Repeated list items | `RepaintBoundary` at item root in `ListView.builder` |
| Bloc scoping | Wrap only the reacting subtree; use `buildWhen` |
| Dark mode | Every screen must look right in both themes (tokens make this free — verify) |
| `flutter analyze` | Must exit clean before reporting done |
