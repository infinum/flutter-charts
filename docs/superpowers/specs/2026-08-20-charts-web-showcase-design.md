# charts_web — modern showcase site

Date: 2026-08-20
Status: approved design, not yet implemented
Scope: `charts_web/` only. The `charts_painter` library (`lib/`) and the `example/` package are not modified.

## Goal

`charts_web` is the public demo for `charts_painter`. Today it is a single playground screen with
unthemed Material defaults, so it demonstrates the library's flexibility without demonstrating that
the library can look good. This redesign turns it into a showcase site: a themed playground, a
curated gallery of live charts, a concepts explainer, and a code panel that emits the Dart source for
whatever the user has built.

## Decisions

| Decision | Choice |
|---|---|
| Scope | Full showcase site: playground + gallery + concepts + live code output |
| Navigation | Playground-first, left navigation rail switching panels in place. No routing. |
| Code panel | Full fidelity — emitted source compiles and reproduces the chart |
| Visual direction | Material 3, `ColorScheme.fromSeed(#D8262C)`, follows OS light/dark |
| Material source | `package:material_ui` (the standalone package), not `package:flutter/material.dart` |
| Gallery source | New curated gallery inside `charts_web` |
| Responsive | `Respo`'s `FittedBox` scaling removed, replaced by real breakpoints |
| Build approach | Design-system primitives first, then rebuild the UI layer on them. Presenters untouched. |

## Material now lives in a package

Material has been decoupled from flutter/flutter into `flutter/packages` and ships as [`material_ui`](https://pub.dev/packages/material_ui) 1.0.0. `package:flutter/material.dart` still resolves on Flutter 3.47.0, so nothing is broken today, but new work should target the package. Every UI file in `charts_web` therefore imports `package:material_ui/material_ui.dart`, which re-exports `package:flutter/widgets.dart` alongside the Material widgets and themes — the names are unchanged, so this is an import-level migration, handled by `dart fix --apply --code=migrate_design_widgets`.

One consequence is not cosmetic: `flex_color_picker` 3.8.0 still imports the legacy library across 23 files. `package:flutter/material.dart` keeps its own `src/material/*` in the SDK rather than re-exporting the package, so its `ThemeData` is a different class from `material_ui`'s. Measured consequences of leaving the two unbridged: legacy `Theme.of` does **not** throw — it silently falls back to Flutter's default purple palette, so the picker renders in the wrong colours — while legacy `MaterialLocalizations.of` does throw. The app is therefore wrapped in `MaterialUiCompatibilityBridge` via `MaterialApp.builder`, and a test asserts palette continuity across the boundary rather than merely the absence of an exception. That bridge is `@Deprecated` by design — it is a migration utility — so its single use site is annotated with the reason and removed when the picker migrates.

`charts_painter` also imports the legacy library (`lib/chart.dart:11`), but only to reach `Colors`, `TextStyle` and `BorderSide`; it never touches `Theme.of`, `Material` or `MaterialLocalizations`, so it needs no bridge. Migrating the library itself is out of scope here and worth its own spec.

## Current state

- `lib/main.dart` — `MaterialApp` with `ThemeData(fontFamily: 'InterTight', primarySwatch: Colors.red)`. No `ColorScheme`, no dark theme, no M3.
- `lib/ui/home/home_screen.dart` — `Row` of a fixed 600px options column and the chart; on small widths a `ListView` with options first and the chart 500px below.
- `lib/ui/common/respo/respo.dart` — wraps the whole app in a `FittedBox` scaled 0.95x (tablet) / 0.9x (desktop) and overrides `MediaQuery.size`. Used from `main.dart:28` and `home_screen.dart:20` only.
- Controls are a mix of `CupertinoButton`, `TextButton`, raw `Switch`, and bare `TextField`. Colors are hardcoded: `0xffefefef` (`home_screen.dart:19`), `Colors.white54` (`common_decoration_box.dart:35`), `Colors.black87` (`options_component_header.dart:26`).
- `lib/ui/home/chart_options/chart_options.dart:5` imports `package:example/main.dart` for a "Showcase" button into the example app's `ChartDemo`.
- `web/index.html` — stale `description="A new Flutter project."`, hand-rolled service-worker bootstrap predating the current Flutter template. `web/style.css` is a bare centering rule around an unstyled PNG.
- `test/widget_test.dart` is still the generated counter test.

### Defects found in the affected code

These are fixed as part of the work, not tracked separately:

1. `DecorationBuilder.buildDecorationCode()` (`lib/ui/home/presenter/chart_decorations_presenter.dart:130`) is implemented by all four decoration presenters and called from nowhere. It is dead code and has already rotted:
   - `decorations_sparkline_presenter.dart:83` emits `lineKey:`, but `SparkLineDecoration` (`lib/chart/render/decorations/spark_line_decoration.dart:8`) takes `listIndex`. The emitted source does not compile.
   - The same emitter hardcodes `gradient: null` while `buildDecoration()` passes the real gradient, so output does not match the rendered chart.
2. `colorToCode` (`lib/ui/common/dialog/color_picker_dialog.dart:66`) reads `color.alpha/.red/.green/.blue`, all deprecated on `Color` since Flutter 3.27. It also lives in a dialog file rather than with the other source emitters.
3. `BarValue` and `BubbleValue` are `@Deprecated` in `charts_painter` itself — "Use `ChartItem(x)`" and "Use `ChartItem(x, min: x)`". `ChartStatePresenter` still constructs `BarValue`, and the code panel must never emit a deprecated constructor, so both the presenter and the emitters use `ChartItem`.
4. `pubspec.yaml:57` declares `InterTight-Light` at `weight: 400` and `InterTight-Regular` with no weight (also 400), so Light silently wins wherever regular text is requested. `Medium` is tagged 600 and `SemiBold` 700; correct is 300/400/500/600.

## Architecture

```
lib/
  theme/
    app_theme.dart          light + dark ThemeData from the seed color
    theme_mode_provider.dart
  codegen/
    dart_literal.dart       Color/EdgeInsets/BorderRadius/BorderSide/LinearGradient literals, SourceWriter
    chart_state_source.dart buildChartStateSource(...) — the entry point
    data_source.dart
    item_options_source.dart
    decorations_source.dart
  ui/
    design/                 SectionCard, LabeledField, NumberField, ColorSwatchButton,
                            SegmentedChoice, CodeBlock
    shell/app_shell.dart    NavigationRail / NavigationBar + IndexedStack body
    playground/             (was ui/home/) three-pane responsive playground
    gallery/                entries metadata, grid, detail
    concepts/               four-section explainer
    common/                 breakpoints (replaces respo/), dialogs, widgets
```

Presenters (`ChartStatePresenter`, `ChartDecorationsPresenter`, the four decoration presenters) keep
their current riverpod `ChangeNotifierProvider` shape, their state, and their mutation methods. The UI
layer and the codegen layer are both rewritten against that unchanged surface.

One exception: the `buildDecorationCode()` method already declared on `DecorationBuilder` is rewritten
in place (see Codegen below). It is currently dead and broken, and it is the one presenter member the
codegen work necessarily owns.

### Why codegen reads presenters

`ChartState` erases user intent into closures — `barItemBuilder`, `widgetDecorationBuilder` — which
cannot be inspected. The presenters hold the intent (which painter, which radius, which gradient,
which decoration params), so the emitters read presenters and never the built `ChartState`.

## Components

### 1. Theme — `lib/theme/`

`appTheme(Brightness)` returns `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFD8262C), brightness: brightness), fontFamily: 'InterTight')`, plus component themes for card, input decoration, segmented button, and dialog.

`themeModeProvider` is a riverpod `StateProvider<ThemeMode>` defaulting to `ThemeMode.system`, toggled from the shell header. Not persisted — persistence needs a storage dependency this demo does not otherwise want.

Every hardcoded color is replaced by a `colorScheme` role: page background → `surface`, card fills → `surfaceContainerLow` / `surfaceContainer`, secondary text → `onSurfaceVariant`.

The font weight mapping in `pubspec.yaml` is corrected to 300/400/500/600. Code text uses `fontFamily: 'monospace'` (the platform default mono) rather than shipping another font binary.

### 2. Shell — `lib/ui/shell/app_shell.dart`

`NavigationRail` at >=800px, `NavigationBar` below it. Destinations: Playground, Gallery, Concepts. Header carries the wordmark, a version chip, pub.dev and GitHub links, and the theme toggle. The library version lives in one `const kChartsPainterVersion` so it has a single point of update.

The body is an `IndexedStack`, deliberately: switching to Gallery and back must not discard a playground configuration the user just built.

### 3. Playground — `lib/ui/playground/`

| Width | Layout |
|---|---|
| >=1400 | options (400, scrolls) │ chart (flexible, fills height) │ code panel (420, collapsible) |
| 800–1400 | options │ chart; code panel opens as a right-hand drawer |
| <800 | chart pinned on top (~320h), options scroll beneath, code panel as a full-screen sheet |

The <800 case inverts today's order. Currently options come first and the chart sits 500px below, so on a phone the user edits a chart they cannot see.

The chart card gains a small toolbar: reset to defaults, randomize data, toggle code panel.

Option groups become collapsible `SectionCard`s: Data, Item options, Decorations.

### 4. Design primitives — `lib/ui/design/`

- `SectionCard` — title, optional subtitle, optional collapse.
- `LabeledField` — label, helper text, child.
- `NumberField` — replaces the ad-hoc fields in `double_option_input.dart`; optional unit suffix, null-safe.
- `ColorSwatchButton` — replaces both the `Icons.format_paint` button and the raw 10x40 `Container` swatch in `options_data_component.dart`.
- `SegmentedChoice` — replaces the `_BarOptionButton` wrap and `SwitchWithImage`.
- `CodeBlock` — mono text, Dart keyword/string/number coloring, copy-to-clipboard.

The four dialogs (`border_dialog`, `border_radius_dialog`, `gradient_dialog`, `color_picker_dialog`) are restyled onto these primitives. `flex_color_picker` stays; it is already a dependency.

### 5. Gallery — `lib/ui/gallery/`

`GalleryEntry` is a const-constructible record of: id, title, blurb, tags, a `ChartState` builder, a snippet, and an `openableInPlayground` flag.

`gallery_screen.dart` renders a responsive card grid with **live** `Chart` previews — not screenshots — plus filter chips by tag. `gallery_detail.dart` shows a large live chart, its `CodeBlock`, and an "Open in playground" action for entries whose configuration maps onto playground state.

Around twelve entries, chosen to cover what the library does well: simple bar, stacked bar, sparkline/line, bubble, negative values, gradient bars, rounded bars, grid + axis decorations, target-line widget decoration, custom widget items, scrollable chart, iOS-style health chart.

Each entry is written fresh in `charts_web`. The `example` package's equivalents (`showcase_charts.dart`, `ios_charts.dart`, `complex_charts.dart`) are reference material for what to build, not code to import — the gallery entries must carry their own snippet and blurb, which the example screens do not have.

Consequence: the "Showcase" button into `example`'s `ChartDemo` is removed, and with it the `example:` path dependency in `charts_web/pubspec.yaml`. The `example` package itself is untouched and remains the canonical development playground.

### 6. Concepts — `lib/ui/concepts/`

Four sections — `ChartState`, `ChartData` + `DataStrategy`, `ItemOptions`, `Decorations` — each with a short explanation, a live mini-chart demonstrating it, and a snippet. Built entirely from `SectionCard` and `CodeBlock`.

### 7. Codegen — `lib/codegen/`

`String buildChartStateSource(ChartStatePresenter, ChartDecorationsPresenter)` composes output from the three area emitters.

`dart_literal.dart` holds pure functions — `colorLiteral`, `edgeInsetsLiteral`, `borderRadiusLiteral`, `borderSideLiteral`, `gradientLiteral` — and a `SourceWriter` that owns indentation and trailing commas. `colorLiteral` emits `Color(0xAARRGGBB)` from `color.toARGB32()`, replacing the deprecated channel getters in the current `colorToCode`. The old `colorToCode` is deleted from `color_picker_dialog.dart`.

Each decoration presenter's `buildDecorationCode()` is rewritten (fixing `lineKey` → `listIndex` and the dropped gradient) and kept **next to** its `buildDecoration()` method. Adjacency is the defence against the drift that full-fidelity codegen invites: whoever changes one sees the other. `decorations_source.dart` walks `ChartDecorationsPresenter` and delegates, preserving background/foreground grouping and ordering.

Values equal to the library default are omitted; every user-changed value is emitted. Output still reproduces the chart exactly — a `ChartState` spelling out every default is noise, not fidelity.

Closures that cannot serialize — `WidgetItemOptions`, widget decorations, click handlers — emit a self-contained inline substitute widget plus a comment pointing at the real source file. The snippet compiles; that one builder is illustrative rather than byte-for-byte.

### 8. Web shell — `web/`

`index.html`: real description, Open Graph and Twitter meta with a preview image, per-scheme `theme-color`, corrected title, and the current `flutter_bootstrap.js` loader (`{{flutter_bootstrap_js}}`) replacing the hand-rolled service-worker script. Flutter 3.47.0 is in use, so the modern template applies.

`style.css`: centered mark with an indeterminate progress bar, background respecting `prefers-color-scheme`, fading out when Flutter boots.

## Analyzer baseline

`fvm flutter analyze` on `charts_web` reports **68 infos** before any of this work: deprecated `MaterialStateProperty` and `SvgPicture.asset(color:)`, deprecated `BarValue`, `sort_child_properties_last`, `use_super_parameters`, leading-underscore locals, and `collection` imported without being declared. Most sit in files this work rewrites or deletes, so the count should fall throughout. "No new issues, count recorded per step" is the gate — not "no issues", which was never true here.

`collection` gets declared in `pubspec.yaml` (it is already present transitively), and `material_ui` is added. Those are the only two dependency additions; the `example` path dependency is removed.

## Testing

- Unit tests for each literal emitter, and for `buildChartStateSource` across the preset set below.
- **Compile-proof fixtures.** Generated output for eight presets is committed as real `.dart` files under `test/codegen/generated/`, each a function returning `ChartState<void>`:

  1. default single bar list
  2. multi-list, `StackDataStrategy`
  3. multi-list, `DefaultDataStrategy` with `stackMultipleValues`
  4. bubble painter with custom min/max width
  5. bar painter with border, border radius, and a gradient
  6. sparkline decoration, filled and smoothed, with a gradient
  7. both axis decorations across background and foreground layers
  8. widget decoration plus `WidgetItemOptions` (the closure-substitute path)

  `flutter analyze` proves the generated source compiles — `charts_web/analysis_options.yaml` excludes only `build/` and the platform directories, so `test/` is analyzed. A test regenerates each fixture and diffs it against the committed file, so drift fails CI. This is what makes "copy-paste runnable" a checked claim; it is also exactly the check that would have caught the existing `lineKey` defect.
- Widget tests: the shell switches destinations without losing playground state; the playground lays out correctly at all three breakpoints; every gallery entry builds without throwing (catches a broken `ChartState` builder).
- `test/widget_test.dart` (the generated counter test) is replaced.

## Risks

- Codegen is the largest single piece and the only part that grows with every future option. Emitters live beside presenters for this reason.
- Removing `Respo`'s scaling touches `main.dart`, `home_screen.dart`, and both `Respo.of` call sites. The breakpoint API is reintroduced under `ui/common/` so intent is preserved without the `FittedBox`.
- Dropping the `example` dependency is a `pubspec.yaml` change and needs a clean rebuild.

## Out of scope

- Changes to `charts_painter` itself, including its own migration off `package:flutter/material.dart`.
- Changes to the `example` package.
- Theme persistence across sessions.
- URL routing / deep links (the rail switches panels in place, by decision).
