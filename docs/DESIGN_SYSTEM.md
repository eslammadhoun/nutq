# Nutq Design System — Extracted Tokens

Extracted from Figma (frame `63:2` "🎨 Design System" + screen designs) on
2026-08-11 via the Figma REST API. Source of truth for `lib/core/theme/`.

- **Typeface:** Inter (Latin UI) · Noto Sans Arabic (Arabic fallback)
- **Grid:** 4 px base
- **Icons:** Lucide / Material Symbols
- **Platform target:** Flutter Material 3
- **Frame size:** 390 × 844 (iPhone 14) — used as `ScreenUtilInit` designSize

## Colors

### Brand Blue
| Token | Hex |
|---|---|
| primary50 | `#EBF5FF` |
| primary100 | `#C3DDFD` |
| primary300 | `#76A9FA` |
| primary400 | `#3F83F8` |
| **primary500 ★** | `#1A56DB` |
| primary600 | `#1447BE` |
| primary700 | `#1339A0` |
| primary800 | `#0E2A82` |
| primary900 | `#091E63` |

### Neutral Grey
| Token | Hex |
|---|---|
| grey50 | `#F9FAFB` |
| grey100 | `#F3F4F6` |
| grey200 | `#E5E7EB` |
| grey300 | `#D1D5DB` |
| grey400 | `#9CA3AF` |
| grey500 | `#6B7280` |
| grey600 | `#4B5563` |
| grey700 | `#374151` |
| grey900 | `#111928` |

### Semantic Status (maps to job statuses)
| Token | Hex | Job status | Chip (light): bg / text |
|---|---|---|---|
| success | `#057A55` | done | `#DEF7EC` / `#057A55` |
| error | `#C81E1E` | failed | `#FDE8E8` / `#C81E1E` |
| warning | `#C27803` | queued | chip renders grey: `#F3F4F6` / `#6B7280` |
| info | `#1A56DB` | processing | `#EBF5FF` / `#1A56DB` |
| neutral | `#6B7280` | cancelled | `#F3F4F6` / `#6B7280` |
| premium | `#7E3AF2` | accent | — |

### Dark Mode Surfaces
| Token | Hex | Usage |
|---|---|---|
| darkBackground | `#111928` | main dark bg |
| darkSurface | `#1F2A37` | cards, panels |
| darkSurfaceRaised | `#374151` | modals, sheets |
| darkBorder | `#4B5563` | dividers |
| darkTextPrimary | `#F9FAFB` | headings |
| darkTextSecondary | `#9CA3AF` | labels, hints |
| darkTextDisabled | `#6B7280` | placeholders |

## Typography (Inter; Arabic falls back to Noto Sans Arabic)

Line heights verified against the actual Figma **variables** via the Dev Mode
MCP (`get_variable_defs`), which supersede the DS frame's text labels.

The table below lists the core semantic styles exposed by `AppTypography`. All
of the design's variable tokens carry **0 letter-spacing/tracking**, so no
`letterSpacing` is set in the code.

| Getter | Figma variable | Weight | Size / Line height | Usage |
|---|---|---|---|---|
| `display` | `Nutq/Display/ExtraBold` | 800 | 32/40 | Hero / splash headlines |
| `heading1` | `Nutq/Heading/2` | 700 | 28/36 | Screen titles |
| `heading2` | `Nutq/Heading/3b` | 700 | 24/30 | Section headers |
| `heading3` | `Nutq/Label/2XL` | 600 | 20/26 | Card & modal titles |
| `heading4` | `Nutq/Label/3XL` | 600 | 18/24 | Sub-section labels |
| `bodyLarge` | `Nutq/Body/MD` | 400 | 16/22 | Primary body text |
| `bodyMedium` | `Nutq/Body Medium/SM` | 500 | 14/20 | Descriptions, secondary text |
| `bodySmall` | `Nutq/Body/XS` | 400 | 13/18 | Helper text, card meta |
| `caption` | `Nutq/Body/2XS` | 400 | 12/16 | Timestamps, footnotes |
| `label` | `Nutq/Label/3XS` | 600 | 11/14 | Chips, overlines |

Additional granular styles (extracted from the Figma file and included in
`AppTypography` for direct use, token names in parentheses):

- **Display (800):** `displaySmall` (`Nutq/Display/ExtraBold2`) 24/30
- **Headings (700):** `headingLarge` (`Nutq/Heading/3`) 26/34 ·
  `heading5` (`Nutq/Heading/6`) 18/24 · `heading6` (`Nutq/Heading/9`) 15/20 ·
  `heading7` (`Nutq/Heading/10`) 14/20 · `heading8` (`Nutq/Heading/11`) 13/18 ·
  `heading9` (`Nutq/Heading/12`) 12/16
- **Body (400):** `bodyXL` (`Nutq/Body/XL`) 19/26 · `bodyBase` (`Nutq/Body/Base`)
  15/22 · `captionSmall` (`Nutq/Body/3XS`) 11/14 · `micro` (`Nutq/Body/4XS`)
  10/14 · `nano` (`Nutq/Body/5XS`) 8/11
- **Body Medium (500):** `bodyMediumLarge` (`Nutq/Body Medium/MD`) 15/22 ·
  `bodyMediumSmall` (`Nutq/Body Medium/XS`) 13/18 ·
  `bodyMediumTiny` (`Nutq/Body Medium/3XS`) 11/14
- **Labels (600):** `labelLarge` (`Nutq/Label/LG`) 16/20 ·
  `labelMedium` (`Nutq/Label/MD`) 15/20 · `labelSmall` (`Nutq/Label/SM`) 14/20 ·
  `labelXS` (`Nutq/Label/XS`) 13/18 · `label2XS` (`Nutq/Label/2XS`) 12/16 ·
  `labelTiny` (`Nutq/Label/4XS`) 10/14 · `labelMicro` (`Nutq/Label/5XS`) 9/12
- **Tag (500):** `tag` (`Nutq/Tag`) 12/16

The design also defines sizes with no rendered instances in screens
(`Nutq/Heading/1,4,5,7,8,13,14`, `Nutq/Body/LG`, `Nutq/Body Medium/2XS`,
`Nutq/Label/XL`, `Nutq/Subtitle`, `Nutq/Button`) and `Nutq/Icon/*` sizes for
icon glyphs (icons come from Lucide / Material Symbols, not text styles) — add
only if a screen actually needs them.


## Spacing — 4 px base grid
`2 · 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64 · 80 · 96`

## Border Radius
| Token | Value | Usage |
|---|---|---|
| badge | 4 | badges, tags |
| button | 8 | compact buttons, inputs (DS token table) |
| card / input | 12 | cards, chips · text fields (screen designs) |
| cta | 14 | primary CTA button (screen designs) |
| dialog | 16 | large cards, dialogs |
| sheetHandle | 20 | bottom sheet handle |
| sheet | 24 | bottom sheets, panels |
| pill | full | pills, avatars, FAB |

## Elevation
| Level | Shadow |
|---|---|
| 1 — subtle cards | (0,2) blur 8, black 4% |
| 2 — cards, list items | (0,4) blur 16, black 7% |
| 3 — FAB, menus | (0,8) blur 24, black 10% |
| 4 — modals, bottom sheets | (0,12) blur 32, black 14% |
| 5 — drawers, overlays | (0,20) blur 48, black 18% |

## Component Tokens (DS table)
- **Buttons** (compact variant): height 40, radius 8, text 13/600
  - Primary: fill `#1A56DB`, white text · Secondary: white fill, `#1A56DB` stroke+text
  - Danger: `#C81E1E` fill · Ghost: white, `#E5E7EB` stroke, `#6B7280` text
  - Disabled: `#F3F4F6` fill, `#9CA3AF` text
- **Status chips**: height 28, pill radius, text 11/600 (color pairs above)
- **Icon set** (from DS): Home, Mic, File, Bell, User, Settings, Key, Moon,
  List, Upload, Link, YouTube, Check, X, Clock

## Screen-level observations (Login light/dark)
- Light: headings `#111827`*, secondary text `#6B7280`, labels 14/600,
  inputs white fill + `#E5E7EB` border + radius 12, placeholder `#9CA3AF`,
  links `#1A56DB`, CTA fill `#1A56DB` radius 14 text 16/600
- Dark: input fill `#1F2937`* + `#374151` border, placeholder `#6B7280`,
  links/accents lighten to `#76A9FA`, **CTA stays `#1A56DB`**

\* Design deviations from DS tokens (Tailwind greys `#111827` / `#1F2937` vs
DS `#111928` / `#1F2A37`). Flutter theme standardizes on the DS token values.

## Known inconsistencies in the Figma file
- DS button token says radius 8 / height 40 / 13 px text, but screen designs
  use radius 14 / 16 px text (auth CTA). Theme follows screens; compact
  variant to be a dedicated widget.
- Type-sample rendered line heights differ from their own labels for some
  styles (e.g. Heading 2 renders 30, label says 32). We follow the labels
  (4 px grid).
