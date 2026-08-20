# charts_web Showcase Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `charts_web` from an unthemed single-screen playground into a Material 3 showcase site with a playground, a curated live gallery, a concepts explainer, and a code panel that emits compiling Dart for whatever the user built.

**Architecture:** A theme layer and a set of design primitives are built first, then the UI layer is rebuilt on them behind a navigation-rail shell holding three panels in an `IndexedStack`. The riverpod presenters keep their state and mutation methods; a new `lib/codegen/` layer reads those presenters to emit Dart source, and the emitted source is proven to compile by committed fixture files that `flutter analyze` checks.

**Tech Stack:** Flutter 3.47.0 (via fvm), Dart 3.13.0, `material_ui` ^1.0.0 (Material 3 as a standalone package), `flutter_riverpod` / `hooks_riverpod` / `flutter_hooks`, `charts_painter` (path dep), `flex_color_picker`, `flutter_svg`.

**Spec:** `docs/superpowers/specs/2026-08-20-charts-web-showcase-design.md`

## Global Constraints

- Flutter `3.47.0` pinned by `.fvmrc`. All commands run as `fvm flutter ...` from the `charts_web/` directory.
- **Material comes from `material_ui`, not the framework.** Material was decoupled from flutter/flutter into `flutter/packages` and now ships as `material_ui`. Every UI file in `charts_web` imports `package:material_ui/material_ui.dart`; `package:flutter/material.dart` must not appear anywhere in `charts_web/lib` or `charts_web/test`. `material_ui` re-exports `package:flutter/widgets.dart`, so a single import covers both layers. `package:flutter/services.dart` (for `Clipboard`) and `package:flutter/widgets.dart` (where only the widgets layer is needed) remain valid.
- `flex_color_picker` 2.6.1 still imports `package:flutter/material.dart`, so the app is wrapped in `MaterialUiCompatibilityBridge` via `MaterialApp.builder`. Without it, the colour and gradient dialogs cannot resolve a legacy `ThemeData` and will throw. The bridge is itself `@Deprecated` by design — it is a temporary migration utility — so its single use site carries `// ignore: deprecated_member_use` with a comment naming `flex_color_picker` as the reason, and that ignore is removed when the picker migrates.
- **New dependencies are limited to these two:** `material_ui: ^1.0.0` (required by the point above) and `collection: ^1.18.0` (already used across the UI, already present transitively, currently tripping `depend_on_referenced_packages`). Nothing else is added. The `example:` path dependency is removed in Task 14.
- Material 3 only: `useMaterial3: true`. Seed color is exactly `Color(0xFFD8262C)`.
- Never use these deprecated APIs; the replacement is mandatory:
  - `MaterialStateProperty` / `MaterialStatePropertyAll` → `WidgetStateProperty` / `WidgetStatePropertyAll`
  - `SvgPicture.asset(color: x)` → `SvgPicture.asset(colorFilter: ColorFilter.mode(x, BlendMode.srcIn))`
  - `Color.value` / `.alpha` / `.red` / `.green` / `.blue` → `Color.toARGB32()`
  - `CardTheme` → `CardThemeData`, `DialogTheme` → `DialogThemeData`, `InputDecorationTheme` → `InputDecorationThemeData` (these are the field types on `ThemeData` in 3.47.0)
  - `BarValue(x)` → `ChartItem(x)`, `BubbleValue(x)` → `ChartItem(x, min: x)` — both are `@Deprecated` in `charts_painter` itself. This applies to emitted code as well as UI code: the code panel must never generate a deprecated constructor.
- No hardcoded colors in UI code. Every color comes from `Theme.of(context).colorScheme` or from user data held in a presenter.
- Presenters (`ChartStatePresenter`, `ChartDecorationsPresenter`, the four decoration presenters) keep their existing state fields and mutation methods. The only member the codegen work may change is `DecorationBuilder.buildDecorationCode()`, which becomes `writeDecorationSource(SourceWriter)`.
- **Never run `git push`.** Commit locally only.
- Every task ends with `fvm flutter test` passing and **no new** analyzer issues. `fvm flutter analyze` currently reports **68 infos** on `master` (deprecated `MaterialStateProperty`, `SvgPicture.asset(color:)`, `BarValue`, `sort_child_properties_last`, `use_super_parameters`, leading-underscore locals, the undeclared `collection` import). Most sit in files this plan rewrites or deletes, so the count should fall task by task. Record the count at the start of each task and confirm it did not rise.

---

## File Structure

**Created**

| Path | Responsibility |
|---|---|
| `lib/theme/app_theme.dart` | `appTheme(Brightness)` — the single source of `ThemeData` |
| `lib/theme/theme_mode_provider.dart` | `themeModeProvider` |
| `lib/ui/common/layout/breakpoints.dart` | `AppBreakpoint`, `breakpointForWidth`, `context.breakpoint` |
| `lib/ui/common/platform/open_external.dart` | conditional export for opening a URL |
| `lib/ui/common/platform/open_external_stub.dart` | non-web fallback (no-op) |
| `lib/ui/common/platform/open_external_web.dart` | `dart:js_interop` window.open |
| `lib/ui/design/section_card.dart` | `SectionCard` — titled, collapsible container |
| `lib/ui/design/labeled_field.dart` | `LabeledField` — label + helper + child |
| `lib/ui/design/number_field.dart` | `NumberField` — double input with steppers |
| `lib/ui/design/color_swatch_button.dart` | `ColorSwatchButton` |
| `lib/ui/design/segmented_choice.dart` | `SegmentedChoice<T>`, `SegmentedChoiceOption<T>` |
| `lib/ui/design/dart_highlighter.dart` | `highlightDart(source, scheme)` → `List<TextSpan>` |
| `lib/ui/design/code_block.dart` | `CodeBlock` — mono, highlighted, copyable |
| `lib/ui/shell/app_shell.dart` | rail / bar + `IndexedStack` + header |
| `lib/ui/shell/shell_header.dart` | wordmark, version chip, links, theme toggle |
| `lib/ui/shell/app_version.dart` | `kChartsPainterVersion` |
| `lib/ui/playground/playground_screen.dart` | three-pane responsive playground |
| `lib/ui/playground/chart_stage.dart` | chart card + toolbar |
| `lib/ui/playground/code_panel.dart` | code panel / drawer / sheet |
| `lib/ui/playground/playground_providers.dart` | `codePanelVisibleProvider` |
| `lib/codegen/source_writer.dart` | `SourceWriter` |
| `lib/codegen/dart_literal.dart` | literal emitters |
| `lib/codegen/data_source.dart` | `writeChartData` |
| `lib/codegen/item_options_source.dart` | `writeItemOptions` |
| `lib/codegen/decorations_source.dart` | `writeDecorations` |
| `lib/codegen/chart_state_source.dart` | `buildChartStateSource` |
| `lib/ui/gallery/gallery_entry.dart` | `GalleryEntry` + `galleryEntries` |
| `lib/ui/gallery/gallery_screen.dart` | filterable grid of live previews |
| `lib/ui/gallery/gallery_detail.dart` | large chart + snippet |
| `lib/ui/concepts/concepts_screen.dart` | four-section explainer |

**Modified**

| Path | Change |
|---|---|
| `pubspec.yaml` | `material_ui` + `collection` added; font weights corrected; `example` dep removed |
| `lib/main.dart` | light+dark theme, `themeMode`, `AppShell`, no `Respo` builder |
| `lib/ui/home/**` | moved to `lib/ui/playground/**`, rebuilt on the design kit |
| `lib/ui/common/dialog/*.dart` | restyled; `colorToCode` deleted |
| `lib/ui/home/decorations/presenters/*.dart` | `buildDecorationCode()` → `writeDecorationSource()` |
| `lib/ui/home/presenter/chart_decorations_presenter.dart` | `DecorationBuilder` interface updated |
| `web/index.html`, `web/style.css` | modern bootstrap, meta tags, themed loader |
| `test/widget_test.dart` | replaced with a real smoke test |

**Deleted**

`lib/ui/common/respo/respo.dart`, `lib/ui/common/widget/double_option_input.dart`, `lib/ui/common/widget/switch_with_image.dart`, `lib/ui/home/chart_options/widget/options_component_header.dart`.

---

### Task 0: Migrate to `material_ui`

Material no longer ships inside the framework; it lives in the standalone `material_ui` package. Every later task writes `import 'package:material_ui/material_ui.dart'`, so the migration comes first.

**Files:**
- Modify: `charts_web/pubspec.yaml` (dependencies)
- Modify: every file in `charts_web/lib` and `charts_web/test` importing `package:flutter/material.dart` (26 files) — mechanically, via `dart fix`
- Modify: `charts_web/lib/ui/home/decorations/presenters/decorations_sparkline_presenter.dart:5` (cupertino import)
- Modify: `charts_web/lib/main.dart` (compatibility bridge)

**Interfaces:**
- Consumes: nothing.
- Produces: the `material_ui` import surface for every later task. `material_ui` re-exports `package:flutter/widgets.dart`, so one import covers widgets and Material both.

- [ ] **Step 1: Record the starting analyzer count**

Run: `cd charts_web && fvm flutter analyze | tail -1`
Expected: `68 issues found.` — write this number down; it is the baseline every later task compares against.

- [ ] **Step 2: Add the dependencies**

In `charts_web/pubspec.yaml`, under `dependencies:`, add:

```yaml
  material_ui: ^1.0.0
  collection: ^1.18.0
```

`collection` is already imported by the UI and already present transitively; declaring it clears the existing `depend_on_referenced_packages` info.

Run: `cd charts_web && fvm flutter pub get`
Expected: resolves, pulling `material_ui 1.0.0`.

- [ ] **Step 3: Run the data-driven import migration**

Run: `cd charts_web && fvm dart fix --apply --code=migrate_design_widgets`
Expected: import lines rewritten from `package:flutter/material.dart` to `package:material_ui/material_ui.dart` across `lib/` and `test/`.

- [ ] **Step 4: Verify no legacy Material import survives**

Run: `cd charts_web && grep -rn "package:flutter/material.dart" lib test`
Expected: no output.

If any remain, rewrite them by hand — the whole point of this task is that none survive.

- [ ] **Step 5: Handle the three Cupertino imports**

`dart fix` migrates Material, not Cupertino. Two of the three files (`chart_options.dart`, `options_data_component.dart`) are deleted in Task 7, so leave them; the third is a presenter that survives:

In `charts_web/lib/ui/home/decorations/presenters/decorations_sparkline_presenter.dart`, replace

```dart
import 'package:flutter/cupertino.dart';
```

with

```dart
import 'package:material_ui/material_ui.dart';
```

It imports Cupertino only to reach `Color`. No `cupertino_ui` dependency is needed: every other Cupertino use site is a widget Tasks 7 and 8 replace with a Material control.

- [ ] **Step 6: Bridge the legacy dependency**

`flex_color_picker` 2.6.1 imports `package:flutter/material.dart` throughout, so the colour and gradient dialogs need a legacy `ThemeData` in scope. `charts_web/lib/main.dart` currently ends with:

```dart
Widget _builder(BuildContext context, Widget? child) {
  return Respo(child: child ?? const SizedBox.shrink());
}
```

Wrap the bridge around it:

```dart
Widget _builder(BuildContext context, Widget? child) {
  // MaterialUiCompatibilityBridge is deprecated on purpose: it is a migration
  // utility. Needed until flex_color_picker moves to package:material_ui.
  // Remove this wrapper and the ignore below when it does.
  // ignore: deprecated_member_use
  return MaterialUiCompatibilityBridge(
    child: Respo(child: child ?? const SizedBox.shrink()),
  );
}
```

- [ ] **Step 7: Verify the dialogs still work**

Run: `cd charts_web && fvm flutter analyze | tail -1 && fvm flutter test`
Expected: the analyzer count is at or below 68 (the `collection` infos are gone; one `deprecated_member_use` is added for the bridge and is expected), and tests pass.

Then confirm by hand that a colour dialog opens without throwing:

Run: `cd charts_web && fvm flutter run -d chrome`
Click a colour swatch in the Data options. Expected: the `flex_color_picker` dialog renders. If it throws a "No MaterialLocalizations found" or missing-`Theme` error, the bridge is not wrapping the dialog's route — move it inside `MaterialApp.builder` rather than around `MaterialApp`.

- [ ] **Step 8: Commit**

```bash
git add charts_web/pubspec.yaml charts_web/pubspec.lock charts_web/lib charts_web/test
git commit -m "refactor(charts_web): migrate from package:flutter/material to material_ui

Material is now the standalone material_ui package. flex_color_picker still
imports the legacy library, so its dialogs are bridged with
MaterialUiCompatibilityBridge until it migrates."
```

---

### Task 1: Theme foundation

**Files:**
- Create: `charts_web/lib/theme/app_theme.dart`
- Create: `charts_web/lib/theme/theme_mode_provider.dart`
- Modify: `charts_web/lib/main.dart` (whole file)
- Modify: `charts_web/pubspec.yaml:53-62` (fonts block)
- Test: `charts_web/test/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `ThemeData appTheme(Brightness brightness)`; `const Color kSeedColor`; `const String kMonoFontFamily`; `final StateProvider<ThemeMode> themeModeProvider`.

- [ ] **Step 1: Write the failing test**

`charts_web/test/theme/app_theme_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appTheme is Material 3 and derives from the brand seed', () {
    final light = appTheme(Brightness.light);
    final expected =
        ColorScheme.fromSeed(seedColor: kSeedColor, brightness: Brightness.light);

    expect(light.useMaterial3, isTrue);
    expect(light.colorScheme.primary, expected.primary);
    expect(light.colorScheme.brightness, Brightness.light);
  });

  test('appTheme builds a dark variant from the same seed', () {
    final dark = appTheme(Brightness.dark);

    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(dark.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: kSeedColor, brightness: Brightness.dark).primary);
  });

  test('appTheme uses InterTight and styles cards without elevation', () {
    final theme = appTheme(Brightness.light);

    expect(theme.textTheme.bodyMedium!.fontFamily, 'InterTight');
    expect(theme.cardTheme.elevation, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/theme/app_theme_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:charts_web/theme/app_theme.dart'`

- [ ] **Step 3: Write the theme**

`charts_web/lib/theme/app_theme.dart`:

```dart
import 'package:material_ui/material_ui.dart';

/// Brand red, also the seed for the whole Material 3 palette.
const Color kSeedColor = Color(0xFFD8262C);

/// Platform default monospace, used for every code surface.
const String kMonoFontFamily = 'monospace';

ThemeData appTheme(Brightness brightness) {
  final colorScheme =
      ColorScheme.fromSeed(seedColor: kSeedColor, brightness: brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'InterTight',
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      isDense: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.secondaryContainer,
      labelType: NavigationRailLabelType.all,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, space: 24),
    chipTheme: ChipThemeData(
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
```

`charts_web/lib/theme/theme_mode_provider.dart`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-only theme mode. Not persisted: persistence would need a storage
/// dependency this demo does not otherwise want.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd charts_web && fvm flutter test test/theme/app_theme_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Fix the font weight declarations**

`InterTight-Light` is currently declared at `weight: 400` and `InterTight-Regular` with no weight (also 400), so Light silently wins for all body text. Replace the `fonts:` block at the end of `charts_web/pubspec.yaml` with:

```yaml
  fonts:
    - family: InterTight
      fonts:
        - asset: assets/font/InterTight-Light.ttf
          weight: 300
        - asset: assets/font/InterTight-Regular.ttf
          weight: 400
        - asset: assets/font/InterTight-Medium.ttf
          weight: 500
        - asset: assets/font/InterTight-SemiBold.ttf
          weight: 600
```

- [ ] **Step 6: Wire both themes into the app**

`charts_web/lib/main.dart` (whole file — the `Respo` builder goes away in Task 2, so `HomeScreen` is still the home for now):

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/theme/theme_mode_provider.dart';
import 'package:charts_web/ui/common/respo/respo.dart';
import 'package:charts_web/ui/home/home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ChartsWebApp()));
}

class ChartsWebApp extends ConsumerWidget {
  const ChartsWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'charts_painter',
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      // flex_color_picker still imports package:flutter/material.dart, so its
      // dialogs need a legacy ThemeData bridged into the tree. The bridge is
      // deprecated by design; it goes when the picker migrates.
      // ignore: deprecated_member_use
      builder: (context, child) => MaterialUiCompatibilityBridge(
        child: Respo(child: child ?? const SizedBox.shrink()),
      ),
      home: HomeScreen(),
    );
  }
}
```

- [ ] **Step 7: Verify the app still analyzes and runs**

Run: `cd charts_web && fvm flutter analyze && fvm flutter test`
Expected: the analyzer issue count is at or below the 68-issue baseline, and all tests pass. The default `test/widget_test.dart` counter test is deleted here if it fails on the renamed root widget — it is replaced properly in Task 15; delete it now with `rm test/widget_test.dart` if it references `MyApp`.

- [ ] **Step 8: Commit**

```bash
git add charts_web/lib/theme charts_web/lib/main.dart charts_web/pubspec.yaml charts_web/test/theme
git commit -m "feat(charts_web): add Material 3 theme layer seeded from brand red

Also fixes the InterTight weight declarations, where Light and Regular were
both registered at weight 400 so Light won for all body text."
```

---

### Task 2: Real breakpoints, delete the FittedBox scaling

`Respo` wraps the entire app in a `FittedBox` scaled to 0.9x on desktop and overrides `MediaQuery.size`. That makes all text soft, throws off Material 3 sizing, and misreports the viewport. It is replaced by a plain width-to-enum mapping.

**Files:**
- Create: `charts_web/lib/ui/common/layout/breakpoints.dart`
- Delete: `charts_web/lib/ui/common/respo/respo.dart`
- Modify: `charts_web/lib/main.dart` (remove the `builder`)
- Modify: `charts_web/lib/ui/home/home_screen.dart:20-36`
- Test: `charts_web/test/ui/common/layout/breakpoints_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum AppBreakpoint { compact, medium, expanded }`; `AppBreakpoint breakpointForWidth(double width)`; `extension BreakpointContext on BuildContext { AppBreakpoint get breakpoint; }`.

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/common/layout/breakpoints_test.dart`:

```dart
import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('breakpointForWidth maps widths to buckets', () {
    expect(breakpointForWidth(360), AppBreakpoint.compact);
    expect(breakpointForWidth(799), AppBreakpoint.compact);
    expect(breakpointForWidth(800), AppBreakpoint.medium);
    expect(breakpointForWidth(1399), AppBreakpoint.medium);
    expect(breakpointForWidth(1400), AppBreakpoint.expanded);
    expect(breakpointForWidth(2560), AppBreakpoint.expanded);
  });

  testWidgets('context.breakpoint reads the real viewport width', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late AppBreakpoint seen;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        seen = context.breakpoint;
        return const SizedBox.shrink();
      }),
    ));

    expect(seen, AppBreakpoint.medium);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/common/layout/breakpoints_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the breakpoints**

`charts_web/lib/ui/common/layout/breakpoints.dart`:

```dart
import 'package:flutter/widgets.dart';

/// Layout buckets for the site. Replaces the old `Respo` wrapper, which scaled
/// the whole app inside a `FittedBox` instead of adapting to the viewport.
enum AppBreakpoint {
  /// Phones. Chart pinned on top, options scroll beneath.
  compact,

  /// Tablets and small windows. Options plus chart; code panel in a drawer.
  medium,

  /// Wide desktop. Options, chart and code panel side by side.
  expanded,
}

const double kMediumBreakpoint = 800;
const double kExpandedBreakpoint = 1400;

AppBreakpoint breakpointForWidth(double width) {
  if (width < kMediumBreakpoint) return AppBreakpoint.compact;
  if (width < kExpandedBreakpoint) return AppBreakpoint.medium;
  return AppBreakpoint.expanded;
}

extension BreakpointContext on BuildContext {
  AppBreakpoint get breakpoint =>
      breakpointForWidth(MediaQuery.sizeOf(this).width);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd charts_web && fvm flutter test test/ui/common/layout/breakpoints_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Remove Respo from the app**

Delete the file and its two call sites.

```bash
cd charts_web && rm -r lib/ui/common/respo
```

In `lib/main.dart`, delete the `Respo` import and unwrap it from the `builder`, keeping the bridge:

```dart
      // ignore: deprecated_member_use
      builder: (context, child) =>
          MaterialUiCompatibilityBridge(child: child ?? const SizedBox.shrink()),
```

In `lib/ui/home/home_screen.dart`, replace the `Respo` import with the breakpoints import and change the switch subject:

```dart
      body: switch (context.breakpoint) {
        AppBreakpoint.compact => ListView(
            shrinkWrap: true,
            children: [
              ChartOptions(),
              const SizedBox(height: 500, child: _Chart()),
            ],
          ),
        AppBreakpoint.medium || AppBreakpoint.expanded => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 600.0,
                  child: SingleChildScrollView(child: ChartOptions())),
              const Expanded(child: _Chart()),
            ],
          ),
      },
```

The compact branch keeps its bad ordering for one more task; Task 5 replaces this whole screen.

- [ ] **Step 6: Verify no FittedBox remains and everything analyzes**

Run: `cd charts_web && grep -rn "Respo\|FittedBox" lib ; fvm flutter analyze && fvm flutter test`
Expected: grep prints nothing; analyzer count at or below baseline; tests pass.

- [ ] **Step 7: Commit**

```bash
git add -A charts_web/lib charts_web/test
git commit -m "refactor(charts_web): replace Respo FittedBox scaling with real breakpoints

Respo scaled the entire app to 0.9x on desktop and overrode MediaQuery.size,
which softened all text and skewed Material 3 sizing. Layout now adapts from
the real viewport width."
```

---

### Task 3: Design primitives

Five widgets that every option control is rebuilt on. They exist so the panel stops being a mix of `CupertinoButton`, `TextButton`, raw `Switch` and bare `TextField`.

**Files:**
- Create: `charts_web/lib/ui/design/section_card.dart`
- Create: `charts_web/lib/ui/design/labeled_field.dart`
- Create: `charts_web/lib/ui/design/number_field.dart`
- Create: `charts_web/lib/ui/design/color_swatch_button.dart`
- Create: `charts_web/lib/ui/design/segmented_choice.dart`
- Test: `charts_web/test/ui/design/number_field_test.dart`
- Test: `charts_web/test/ui/design/section_card_test.dart`
- Test: `charts_web/test/ui/design/segmented_choice_test.dart`

**Interfaces:**
- Consumes: `appTheme` (Task 1) for the widget tests' wrapper.
- Produces:
  - `SectionCard({required String title, String? subtitle, required List<Widget> children, bool initiallyExpanded = true, bool collapsible = true})`
  - `LabeledField({required String label, String? helper, required Widget child})`
  - `NumberField({required String label, required double? value, required ValueChanged<double> onChanged, double step = 1, double fallback = 0, String? suffix, bool showInput = true})`
  - `ColorSwatchButton({required Color color, required VoidCallback onPressed, String? tooltip})`
  - `SegmentedChoice<T>({required T value, required List<SegmentedChoiceOption<T>> options, required ValueChanged<T> onChanged, String? label})`
  - `SegmentedChoiceOption<T>({required T value, required String label, IconData? icon})`

- [ ] **Step 1: Write the failing tests**

`charts_web/test/ui/design/number_field_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: appTheme(Brightness.light),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('steppers move the value by step', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_wrap(NumberField(
      label: 'Max bar width',
      value: 10,
      step: 2,
      onChanged: changes.add,
    )));

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));

    expect(changes, [12.0, 8.0]);
  });

  testWidgets('a null value steps from the fallback', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_wrap(NumberField(
      label: 'Min bar width',
      value: null,
      step: 2,
      fallback: 20,
      onChanged: changes.add,
    )));

    await tester.tap(find.byIcon(Icons.add));

    expect(changes, [20.0]);
  });

  testWidgets('unparseable text does not throw and does not report', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_wrap(NumberField(
      label: 'Padding',
      value: 4,
      onChanged: changes.add,
    )));

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(changes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
```

`charts_web/test/ui/design/section_card_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('collapsing hides the children', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(
        body: SectionCard(
          title: 'Data',
          subtitle: 'Each data point is an item.',
          children: [Text('body')],
        ),
      ),
    ));

    expect(find.text('body'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsNothing);
    expect(find.text('Data'), findsOneWidget);
  });
}
```

`charts_web/test/ui/design/segmented_choice_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Painter { bar, bubble }

void main() {
  testWidgets('tapping a segment reports its value', (tester) async {
    final picked = <_Painter>[];
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(Brightness.light),
      home: Scaffold(
        body: SegmentedChoice<_Painter>(
          label: 'Painter',
          value: _Painter.bar,
          options: const [
            SegmentedChoiceOption(value: _Painter.bar, label: 'Bar'),
            SegmentedChoiceOption(value: _Painter.bubble, label: 'Bubble'),
          ],
          onChanged: picked.add,
        ),
      ),
    ));

    await tester.tap(find.text('Bubble'));

    expect(picked, [_Painter.bubble]);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd charts_web && fvm flutter test test/ui/design/`
Expected: FAIL — URIs do not exist.

- [ ] **Step 3: Write `SectionCard`**

`charts_web/lib/ui/design/section_card.dart`:

```dart
import 'package:material_ui/material_ui.dart';

/// A titled container for one group of options. Collapsible so a long option
/// panel stays navigable.
class SectionCard extends StatefulWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.initiallyExpanded = true,
    this.collapsible = true,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool collapsible;
  final Widget? trailing;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: theme.textTheme.titleMedium),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
                if (widget.collapsible)
                  IconButton(
                    tooltip: _expanded ? 'Collapse' : 'Expand',
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              ...widget.children,
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Write `LabeledField`**

`charts_web/lib/ui/design/labeled_field.dart`:

```dart
import 'package:material_ui/material_ui.dart';

/// Label, control, and optional helper text in a consistent vertical rhythm.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.helper,
    required this.child,
  });

  final String label;
  final String? helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          child,
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Write `NumberField`**

Replaces `double_option_input.dart`. Note the old widget called `double.parse` on every keystroke, which threw on an empty field; this one uses `double.tryParse` and ignores unparseable input.

`charts_web/lib/ui/design/number_field.dart`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Numeric input with decrement / increment steppers, used for every double
/// option (widths, paddings, line widths, axis steps).
class NumberField extends HookWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.fallback = 0,
    this.suffix,
    this.showInput = true,
  });

  final String label;
  final double? value;
  final ValueChanged<double> onChanged;
  final double step;

  /// Used when [value] is null and the user presses a stepper.
  final double fallback;
  final String? suffix;

  /// When false only the current value is shown, without a text field. Used for
  /// options where free typing is not useful.
  final bool showInput;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: _format(value));
    final lastValue = useRef(value);

    // Keep the field in sync when the value changes from elsewhere (a preset
    // being applied, a reset) without fighting the user mid-edit.
    useEffect(() {
      if (lastValue.value != value) {
        lastValue.value = value;
        controller.text = _format(value);
      }
      return null;
    }, [value]);

    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          if (showInput)
            SizedBox(
              width: 76,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.end,
                decoration: InputDecoration(suffixText: suffix),
                onChanged: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null) {
                    lastValue.value = parsed;
                    onChanged(parsed);
                  }
                },
              ),
            )
          else
            Text(_format(value), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () => _step(-step),
          ),
          IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => _step(step),
          ),
        ],
      );
    });
  }

  void _step(double delta) {
    final current = value;
    onChanged(current == null ? fallback : _round(current + delta));
  }

  static double _round(double value) => (value * 10).round() / 10;

  static String _format(double? value) =>
      value == null ? '' : (value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString());
}
```

- [ ] **Step 6: Write `ColorSwatchButton`**

`charts_web/lib/ui/design/color_swatch_button.dart`:

```dart
import 'package:material_ui/material_ui.dart';

/// A tappable colour swatch. Replaces the old paint-roller icon button and the
/// bare `Container` swatches.
class ColorSwatchButton extends StatelessWidget {
  const ColorSwatchButton({
    super.key,
    required this.color,
    required this.onPressed,
    this.tooltip,
    this.size = 28,
  });

  final Color color;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
```

- [ ] **Step 7: Write `SegmentedChoice`**

`charts_web/lib/ui/design/segmented_choice.dart`:

```dart
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:material_ui/material_ui.dart';

class SegmentedChoiceOption<T> {
  const SegmentedChoiceOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Single-select control for enum-ish options. Replaces the hand-rolled
/// selected-border buttons and the image switch.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.helper,
  });

  final T value;
  final List<SegmentedChoiceOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final control = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: options
            .map((option) => ButtonSegment<T>(
                  value: option.value,
                  label: Text(option.label),
                  icon: option.icon == null ? null : Icon(option.icon),
                ))
            .toList(),
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );

    if (label == null) return control;

    return LabeledField(label: label!, helper: helper, child: control);
  }
}
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `cd charts_web && fvm flutter test test/ui/design/`
Expected: PASS (5 tests)

- [ ] **Step 9: Commit**

```bash
git add charts_web/lib/ui/design charts_web/test/ui/design
git commit -m "feat(charts_web): add design primitives for the option panel"
```

---

### Task 4: Dart syntax highlighting and CodeBlock

**Files:**
- Create: `charts_web/lib/ui/design/dart_highlighter.dart`
- Create: `charts_web/lib/ui/design/code_block.dart`
- Test: `charts_web/test/ui/design/dart_highlighter_test.dart`

**Interfaces:**
- Consumes: `kMonoFontFamily` (Task 1).
- Produces:
  - `class DartCodeScheme { const DartCodeScheme({required Color base, required Color keyword, required Color type, required Color number, required Color string, required Color comment}); factory DartCodeScheme.of(ColorScheme scheme); }`
  - `List<TextSpan> highlightDart(String source, DartCodeScheme scheme)`
  - `CodeBlock({required String source, double? maxHeight, String copyLabel = 'Copy'})`

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/design/dart_highlighter_test.dart`:

```dart
import 'package:charts_web/ui/design/dart_highlighter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final scheme = DartCodeScheme.of(
      ColorScheme.fromSeed(seedColor: const Color(0xFFD8262C)));

  TextSpan spanFor(List<TextSpan> spans, String text) =>
      spans.firstWhere((span) => span.text == text);

  test('classifies keywords, types, numbers and hex literals', () {
    final spans = highlightDart(
        'const BarItem(radius: 2.5, color: Color(0xFFD8262C))', scheme);

    expect(spanFor(spans, 'const').style!.color, scheme.keyword);
    expect(spanFor(spans, 'BarItem').style!.color, scheme.type);
    expect(spanFor(spans, '2.5').style!.color, scheme.number);
    expect(spanFor(spans, '0xFFD8262C').style!.color, scheme.number);
    expect(spanFor(spans, 'radius').style!.color, scheme.base);
  });

  test('classifies strings and line comments', () {
    final spans = highlightDart("// note\nid: 'main'", scheme);

    expect(spanFor(spans, '// note').style!.color, scheme.comment);
    expect(spanFor(spans, "'main'").style!.color, scheme.string);
  });

  test('reassembling the spans reproduces the source exactly', () {
    const source = 'ChartState<void>(\n  data: ChartData([[1.0, 2.0]]),\n)';

    final rebuilt =
        highlightDart(source, scheme).map((span) => span.text).join();

    expect(rebuilt, source);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/design/dart_highlighter_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the highlighter**

`charts_web/lib/ui/design/dart_highlighter.dart`:

```dart
import 'package:material_ui/material_ui.dart';

/// Colours for the code surfaces, derived from the active Material scheme so
/// code reads correctly in both light and dark.
class DartCodeScheme {
  const DartCodeScheme({
    required this.base,
    required this.keyword,
    required this.type,
    required this.number,
    required this.string,
    required this.comment,
  });

  factory DartCodeScheme.of(ColorScheme scheme) => DartCodeScheme(
        base: scheme.onSurface,
        keyword: scheme.primary,
        type: scheme.tertiary,
        number: scheme.secondary,
        string: scheme.tertiary,
        comment: scheme.onSurfaceVariant,
      );

  final Color base;
  final Color keyword;
  final Color type;
  final Color number;
  final Color string;
  final Color comment;
}

const Set<String> _keywords = {
  'as', 'await', 'class', 'const', 'else', 'enum', 'extends', 'false', 'final',
  'for', 'if', 'import', 'in', 'is', 'new', 'null', 'return', 'super', 'switch',
  'this', 'true', 'var', 'void', 'while',
};

final RegExp _tokenPattern = RegExp(
  r"(?<comment>//[^\n]*)"
  r"|(?<string>'(?:[^'\\\n]|\\.)*')"
  r'|(?<hex>\b0[xX][0-9a-fA-F]+\b)'
  r'|(?<number>\b\d+(?:\.\d+)?\b)'
  r'|(?<type>\b[A-Z][A-Za-z0-9_]*\b)'
  r'|(?<word>\b[a-z_][A-Za-z0-9_]*\b)',
);

/// Splits [source] into styled spans. Concatenating the spans always
/// reproduces [source] byte for byte.
List<TextSpan> highlightDart(String source, DartCodeScheme scheme) {
  final spans = <TextSpan>[];
  var cursor = 0;

  void plain(String text) {
    if (text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: TextStyle(color: scheme.base)));
    }
  }

  for (final match in _tokenPattern.allMatches(source)) {
    plain(source.substring(cursor, match.start));
    cursor = match.end;

    final text = match[0]!;
    final color = switch (match) {
      _ when match.namedGroup('comment') != null => scheme.comment,
      _ when match.namedGroup('string') != null => scheme.string,
      _ when match.namedGroup('hex') != null => scheme.number,
      _ when match.namedGroup('number') != null => scheme.number,
      _ when match.namedGroup('type') != null => scheme.type,
      _ => _keywords.contains(text) ? scheme.keyword : scheme.base,
    };

    spans.add(TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: color == scheme.keyword ? FontWeight.w600 : null,
      ),
    ));
  }

  plain(source.substring(cursor));

  return spans;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd charts_web && fvm flutter test test/ui/design/dart_highlighter_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Write `CodeBlock`**

`charts_web/lib/ui/design/code_block.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/dart_highlighter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Monospaced, syntax-highlighted, copyable Dart source.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.source,
    this.maxHeight,
    this.title,
  });

  final String source;
  final double? maxHeight;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codeScheme = DartCodeScheme.of(theme.colorScheme);

    final code = SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: kMonoFontFamily,
              fontSize: 13,
              height: 1.5,
            ),
            children: highlightDart(source, codeScheme),
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? 'Dart',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: source));
                  if (context.mounted) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (maxHeight == null)
            code
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: code,
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Verify**

Run: `cd charts_web && fvm flutter analyze && fvm flutter test`
Expected: analyzer count at or below baseline; all tests pass.

- [ ] **Step 7: Commit**

```bash
git add charts_web/lib/ui/design charts_web/test/ui/design
git commit -m "feat(charts_web): add Dart syntax highlighting and CodeBlock"
```

---

### Task 5: Application shell

The rail switches three panels in place. The body is an `IndexedStack` on purpose: switching to Gallery and back must not discard a playground configuration the user just built.

External links are opened without adding a dependency, via a conditional export around `dart:js_interop`. On the VM (tests, desktop) it is a no-op, which keeps the header widget-testable.

**Files:**
- Create: `charts_web/lib/ui/common/platform/open_external.dart`
- Create: `charts_web/lib/ui/common/platform/open_external_stub.dart`
- Create: `charts_web/lib/ui/common/platform/open_external_web.dart`
- Create: `charts_web/lib/ui/shell/app_version.dart`
- Create: `charts_web/lib/ui/shell/shell_header.dart`
- Create: `charts_web/lib/ui/shell/app_shell.dart`
- Modify: `charts_web/lib/main.dart` (home becomes `AppShell`)
- Test: `charts_web/test/ui/shell/app_shell_test.dart`

**Interfaces:**
- Consumes: `AppBreakpoint` / `context.breakpoint` (Task 2), `themeModeProvider` (Task 1).
- Produces:
  - `void openExternal(String url)`
  - `const String kChartsPainterVersion`, `const String kPubDevUrl`, `const String kGitHubUrl`
  - `class AppShell extends ConsumerStatefulWidget`
  - `class ShellHeader extends ConsumerWidget`
  - `enum ShellDestination { playground, gallery, concepts }` with `label` and `icon` getters

For this task the gallery and concepts panels are placeholders so the shell can be tested and committed on its own; Tasks 14 and 15 replace them.

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/shell/app_shell_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/shell/app_shell.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpShell(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const AppShell(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('wide layout shows a navigation rail with three destinations',
      (tester) async {
    await _pumpShell(tester, const Size(1600, 1000));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Concepts'), findsOneWidget);
  });

  testWidgets('compact layout shows a bottom navigation bar', (tester) async {
    await _pumpShell(tester, const Size(500, 900));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('switching destinations keeps every panel alive', (tester) async {
    await _pumpShell(tester, const Size(1600, 1000));

    expect(find.byType(IndexedStack), findsOneWidget);
    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack.children.length, 3);
    expect(stack.index, 0);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/shell/app_shell_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the external-link helper**

`charts_web/lib/ui/common/platform/open_external.dart`:

```dart
export 'open_external_stub.dart'
    if (dart.library.js_interop) 'open_external_web.dart';
```

`charts_web/lib/ui/common/platform/open_external_stub.dart`:

```dart
/// Non-web fallback. Tests and desktop builds have nowhere to open a tab, so
/// this is deliberately a no-op rather than a throw.
void openExternal(String url) {}
```

`charts_web/lib/ui/common/platform/open_external_web.dart`:

```dart
import 'dart:js_interop';

@JS('window.open')
external void _windowOpen(String url, String target);

/// Opens [url] in a new browser tab.
void openExternal(String url) => _windowOpen(url, '_blank');
```

- [ ] **Step 4: Write the version and link constants**

`charts_web/lib/ui/shell/app_version.dart`:

```dart
/// Kept in one place so the header chip and any copy referencing the version
/// have a single point of update. Matches `charts_painter`'s pubspec version.
const String kChartsPainterVersion = '3.1.0';

const String kPubDevUrl = 'https://pub.dev/packages/charts_painter';
const String kGitHubUrl = 'https://github.com/infinum/flutter-charts';
```

- [ ] **Step 5: Write the header**

`charts_web/lib/ui/shell/shell_header.dart`:

```dart
import 'package:charts_web/theme/theme_mode_provider.dart';
import 'package:charts_web/ui/common/platform/open_external.dart';
import 'package:charts_web/ui/shell/app_version.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShellHeader extends ConsumerWidget {
  const ShellHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text('charts_painter', style: theme.textTheme.titleMedium),
          const SizedBox(width: 10),
          Chip(
            label: Text('v$kChartsPainterVersion'),
            visualDensity: VisualDensity.compact,
            labelStyle: theme.textTheme.labelSmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'pub.dev',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => openExternal(kPubDevUrl),
          ),
          IconButton(
            tooltip: 'GitHub',
            icon: const Icon(Icons.code),
            onPressed: () => openExternal(kGitHubUrl),
          ),
          IconButton(
            tooltip: switch (mode) {
              ThemeMode.system => 'Theme: follow system',
              ThemeMode.light => 'Theme: light',
              ThemeMode.dark => 'Theme: dark',
            },
            icon: Icon(switch (mode) {
              ThemeMode.system => Icons.brightness_auto,
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
            }),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = switch (mode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Write the shell**

`charts_web/lib/ui/shell/app_shell.dart`:

```dart
import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/home/home_screen.dart';
import 'package:charts_web/ui/shell/shell_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ShellDestination {
  playground('Playground', Icons.tune),
  gallery('Gallery', Icons.grid_view),
  concepts('Concepts', Icons.school_outlined);

  const ShellDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.breakpoint == AppBreakpoint.compact;

    // IndexedStack, not a swap: a playground configuration must survive a trip
    // to the gallery and back.
    final body = IndexedStack(
      index: _index,
      children: [
        HomeScreen(),
        const _Placeholder(label: 'Gallery'),
        const _Placeholder(label: 'Concepts'),
      ],
    );

    return Scaffold(
      body: Column(
        children: [
          const ShellHeader(),
          Expanded(
            child: isCompact
                ? body
                : Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: _select,
                        destinations: ShellDestination.values
                            .map((destination) => NavigationRailDestination(
                                  icon: Icon(destination.icon),
                                  label: Text(destination.label),
                                ))
                            .toList(),
                      ),
                      Expanded(child: body),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isCompact
          ? NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: ShellDestination.values
                  .map((destination) => NavigationDestination(
                        icon: Icon(destination.icon),
                        label: destination.label,
                      ))
                  .toList(),
            )
          : null,
    );
  }

  void _select(int index) => setState(() => _index = index);
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}
```

- [ ] **Step 7: Point the app at the shell**

In `charts_web/lib/main.dart`, replace the `HomeScreen` import with `package:charts_web/ui/shell/app_shell.dart` and change `home: HomeScreen()` to `home: const AppShell()`.

- [ ] **Step 8: Run test to verify it passes**

Run: `cd charts_web && fvm flutter test test/ui/shell/app_shell_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 9: Commit**

```bash
git add charts_web/lib/ui/shell charts_web/lib/ui/common/platform charts_web/lib/main.dart charts_web/test/ui/shell
git commit -m "feat(charts_web): add navigation rail shell with three destinations"
```

---

### Task 6: Playground layout

Moves `ui/home` to `ui/playground`, splits the chart into its own widget with a toolbar, and lays the three panes out per breakpoint. The compact branch is inverted from today's, where options came first and the chart sat 500px below — unusable on a phone.

The code panel is stubbed here (an empty placeholder honouring `codePanelVisibleProvider`) and filled in by Task 13, once codegen exists.

**Files:**
- Create: `charts_web/lib/ui/playground/playground_providers.dart`
- Create: `charts_web/lib/ui/playground/chart_stage.dart`
- Create: `charts_web/lib/ui/playground/playground_screen.dart`
- Create: `charts_web/lib/ui/playground/code_panel.dart`
- Delete: `charts_web/lib/ui/home/home_screen.dart`
- Modify: `charts_web/lib/ui/shell/app_shell.dart` (use `PlaygroundScreen`)
- Test: `charts_web/test/ui/playground/playground_screen_test.dart`

**Interfaces:**
- Consumes: `AppBreakpoint` (Task 2), `SectionCard` (Task 3), `chartStatePresenter` and `chartDecorationsPresenter` (existing).
- Produces:
  - `final StateProvider<bool> codePanelVisibleProvider`
  - `class ChartStage extends ConsumerWidget`
  - `class PlaygroundScreen extends ConsumerWidget`
  - `class CodePanel extends ConsumerWidget`

The `lib/ui/home/chart_options/` and `lib/ui/home/decorations/` directories stay where they are for this task and move in Tasks 7 and 8. Only the screen itself is replaced.

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/playground/playground_screen_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/chart_stage.dart';
import 'package:charts_web/ui/playground/playground_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(body: PlaygroundScreen()),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('expanded shows options, chart and code panel side by side',
      (tester) async {
    await _pump(tester, const Size(1800, 1200));

    expect(find.byType(ChartStage), findsOneWidget);
    expect(find.byKey(PlaygroundScreen.optionsPaneKey), findsOneWidget);
    expect(find.byKey(PlaygroundScreen.codePaneKey), findsOneWidget);
  });

  testWidgets('medium hides the inline code pane', (tester) async {
    await _pump(tester, const Size(1000, 900));

    expect(find.byKey(PlaygroundScreen.optionsPaneKey), findsOneWidget);
    expect(find.byKey(PlaygroundScreen.codePaneKey), findsNothing);
  });

  testWidgets('compact puts the chart above the options', (tester) async {
    await _pump(tester, const Size(420, 900));

    final chart = tester.getTopLeft(find.byType(AnimatedChart<void>));
    final options = tester.getTopLeft(find.byKey(PlaygroundScreen.optionsPaneKey));

    expect(chart.dy, lessThan(options.dy));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/playground/playground_screen_test.dart`
Expected: FAIL — URIs do not exist.

- [ ] **Step 3: Write the providers**

`charts_web/lib/ui/playground/playground_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the generated-source panel is showing. On expanded layouts this
/// controls the third pane; on smaller ones, the drawer or sheet.
final codePanelVisibleProvider = StateProvider<bool>((ref) => true);
```

- [ ] **Step 4: Write the chart stage**

`charts_web/lib/ui/playground/chart_stage.dart`:

```dart
import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:charts_web/ui/playground/playground_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The chart itself plus its toolbar. Kept separate from the layout so all
/// three breakpoints render the same stage.
class ChartStage extends ConsumerWidget {
  const ChartStage({super.key, this.onToggleCode});

  final VoidCallback? onToggleCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('Live chart', style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.casino_outlined, size: 18),
                label: const Text('Randomize'),
                onPressed: () => _randomize(presenter),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Reset'),
                onPressed: () {
                  // Recreating the providers is the reset: it restores every
                  // default without the presenters needing a reset method.
                  ref.invalidate(chartDecorationsPresenter);
                  ref.invalidate(chartStatePresenter);
                },
              ),
              if (onToggleCode != null) ...[
                const SizedBox(width: 4),
                TextButton.icon(
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('Dart source'),
                  onPressed: onToggleCode,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              padding: const EdgeInsets.all(20),
              child: AnimatedChart<void>(
                duration: const Duration(milliseconds: 450),
                state: presenter.state,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _randomize(ChartStatePresenter presenter) {
    final random = Random();

    presenter.updateData(presenter.data
        .map((list) => List<ChartItem<void>>.generate(
            list.length, (_) => ChartItem<void>(random.nextDouble() * 10)))
        .toList());
  }
}
```

- [ ] **Step 5: Write the code panel placeholder**

`charts_web/lib/ui/playground/code_panel.dart` — Task 13 replaces the body with a `CodeBlock` fed by `buildChartStateSource`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generated Dart source for the current playground configuration.
class CodePanel extends ConsumerWidget {
  const CodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(16),
      child: Text('Dart source', style: theme.textTheme.titleSmall),
    );
  }
}
```

- [ ] **Step 6: Write the playground screen**

`charts_web/lib/ui/playground/playground_screen.dart`:

```dart
import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/home/chart_options/chart_options.dart';
import 'package:charts_web/ui/playground/chart_stage.dart';
import 'package:charts_web/ui/playground/code_panel.dart';
import 'package:charts_web/ui/playground/playground_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaygroundScreen extends ConsumerWidget {
  const PlaygroundScreen({super.key});

  static const Key optionsPaneKey = Key('playground.options');
  static const Key codePaneKey = Key('playground.code');

  static const double _optionsWidth = 400;
  static const double _codeWidth = 420;
  static const double _compactChartHeight = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCode = ref.watch(codePanelVisibleProvider);

    final options = SingleChildScrollView(
      key: optionsPaneKey,
      padding: const EdgeInsets.all(16),
      child: ChartOptions(),
    );

    return switch (context.breakpoint) {
      AppBreakpoint.expanded => Row(
          children: [
            SizedBox(width: _optionsWidth, child: options),
            const Expanded(child: ChartStage()),
            if (showCode)
              const SizedBox(
                key: codePaneKey,
                width: _codeWidth,
                child: CodePanel(),
              ),
          ],
        ),
      AppBreakpoint.medium => Row(
          children: [
            SizedBox(width: _optionsWidth, child: options),
            Expanded(
              child: ChartStage(
                onToggleCode: () => _showCodeSheet(context),
              ),
            ),
          ],
        ),
      AppBreakpoint.compact => Column(
          children: [
            SizedBox(
              height: _compactChartHeight,
              child: ChartStage(onToggleCode: () => _showCodeSheet(context)),
            ),
            Expanded(child: options),
          ],
        ),
    };
  }

  void _showCodeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: CodePanel(),
      ),
    );
  }
}
```

- [ ] **Step 7: Point the shell at the playground and delete the old screen**

In `charts_web/lib/ui/shell/app_shell.dart`, replace the `HomeScreen` import with `package:charts_web/ui/playground/playground_screen.dart` and the first `IndexedStack` child with `const PlaygroundScreen()`.

```bash
cd charts_web && rm lib/ui/home/home_screen.dart
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `cd charts_web && fvm flutter test test/ui/playground/playground_screen_test.dart test/ui/shell/app_shell_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 9: Commit**

```bash
git add -A charts_web/lib charts_web/test
git commit -m "feat(charts_web): responsive three-pane playground

The compact layout now pins the chart above the options; previously the
options came first and the chart sat 500px below, so on a phone you edited a
chart you could not see."
```

---

### Task 7: Rebuild the Data and Item options sections

Also completes the `ui/home` → `ui/playground` move, since these are the last widgets living under the old path.

**Files:**
- Move: `charts_web/lib/ui/home/presenter/` → `charts_web/lib/ui/playground/presenter/`
- Move: `charts_web/lib/ui/home/decorations/` → `charts_web/lib/ui/playground/decorations/`
- Move: `charts_web/lib/ui/home/chart_options/widget/futurama_bar_widget.dart` → `charts_web/lib/ui/playground/options/futurama_bar_widget.dart`
- Create: `charts_web/lib/ui/playground/options/options_panel.dart`
- Create: `charts_web/lib/ui/playground/options/data_section.dart`
- Create: `charts_web/lib/ui/playground/options/item_options_section.dart`
- Delete: `charts_web/lib/ui/home/chart_options/` (the three replaced widgets; the remaining `lib/ui/home/` shell goes in Task 8)
- Delete: `charts_web/lib/ui/common/widget/double_option_input.dart`
- Delete: `charts_web/lib/ui/common/widget/switch_with_image.dart`
- Modify: `charts_web/lib/ui/playground/playground_screen.dart` (import `OptionsPanel`)
- Test: `charts_web/test/ui/playground/options/data_section_test.dart`
- Test: `charts_web/test/ui/playground/options/item_options_section_test.dart`

**Interfaces:**
- Consumes: `SectionCard`, `LabeledField`, `NumberField`, `ColorSwatchButton`, `SegmentedChoice`, `SegmentedChoiceOption` (Task 3); `chartStatePresenter` with its existing members (`data`, `isMultiItem`, `listColors`, `selectedPainter`, `minBarWidth`, `maxBarWidth`, `chartItemPadding`, `multiValuePadding`, `stackMultipleValues`, `showMaxDataListMessage`, `itemBorderSides`, `barBorderRadius`, `gradient`, and their `update*` methods).
- Produces: `class OptionsPanel extends ConsumerWidget`, `class DataSection extends HookConsumerWidget`, `class ItemOptionsSection extends ConsumerWidget`.

- [ ] **Step 1: Do the mechanical move**

```bash
cd charts_web
mkdir -p lib/ui/playground/options
git mv lib/ui/home/presenter lib/ui/playground/presenter
git mv lib/ui/home/decorations lib/ui/playground/decorations
git mv lib/ui/home/chart_options/widget/futurama_bar_widget.dart lib/ui/playground/options/futurama_bar_widget.dart
grep -rl "ui/home/" lib test | xargs sed -i '' \
  -e 's#ui/home/presenter#ui/playground/presenter#g' \
  -e 's#ui/home/decorations#ui/playground/decorations#g' \
  -e 's#ui/home/chart_options/widget/futurama_bar_widget#ui/playground/options/futurama_bar_widget#g'
```

`lib/ui/home/chart_options/` still holds the three widgets being replaced. They are deleted in Step 7 once the replacements exist.

- [ ] **Step 2: Write the failing tests**

`charts_web/test/ui/playground/options/data_section_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/data_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(
        body: SingleChildScrollView(child: DataSection()),
      ),
    ),
  ));
  await tester.pumpAndSettle();

  return container;
}

void main() {
  testWidgets('typing values updates the presenter data', (tester) async {
    final container = await _pump(tester);

    await tester.enterText(find.byType(TextField).first, '1, 2, 3');
    await tester.pump();

    final values = container.read(chartStatePresenter).data.first;
    expect(values.map((item) => item.max).toList(), [1.0, 2.0, 3.0]);
  });

  testWidgets('adding a list grows the data and the colour list',
      (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Add another list'));
    await tester.pumpAndSettle();

    final presenter = container.read(chartStatePresenter);
    expect(presenter.data.length, 2);
    expect(presenter.listColors.length, 2);
  });

  testWidgets('the strategy choice only appears with multiple lists',
      (tester) async {
    final container = await _pump(tester);

    expect(find.text('Stacked'), findsNothing);

    container.read(chartStatePresenter).addDataList(
        [1, 2, 3].map((e) => ChartItem<void>(e.toDouble())).toList());
    await tester.pumpAndSettle();

    expect(find.text('Stacked'), findsOneWidget);
  });
}
```

`charts_web/test/ui/playground/options/item_options_section_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/item_options_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('choosing a painter updates the presenter', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: ItemOptionsSection()),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(container.read(chartStatePresenter).selectedPainter,
        SelectedPainter.bar);

    await tester.tap(find.text('Bubble'));
    await tester.pumpAndSettle();

    expect(container.read(chartStatePresenter).selectedPainter,
        SelectedPainter.bubble);
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd charts_web && fvm flutter test test/ui/playground/options/`
Expected: FAIL — URIs do not exist.

- [ ] **Step 4: Write the Data section**

`charts_web/lib/ui/playground/options/data_section.dart`:

```dart
import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum _StrategyKind { grouped, stacked }

class DataSection extends HookConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final isGrouped =
        presenter.state.data.dataStrategy is DefaultDataStrategy;

    return SectionCard(
      title: 'Data',
      subtitle: 'Every data point is an item. Lists become series.',
      children: [
        if (presenter.isMultiItem)
          SegmentedChoice<_StrategyKind>(
            label: 'Data strategy',
            helper: 'How multiple lists share the same slot.',
            value: isGrouped ? _StrategyKind.grouped : _StrategyKind.stacked,
            options: const [
              SegmentedChoiceOption(
                  value: _StrategyKind.grouped, label: 'Grouped'),
              SegmentedChoiceOption(
                  value: _StrategyKind.stacked, label: 'Stacked'),
            ],
            onChanged: (kind) => presenter.updateDataStrategy(
              kind == _StrategyKind.stacked
                  ? const StackDataStrategy()
                  : const DefaultDataStrategy(stackMultipleValues: true),
            ),
          ),
        if (presenter.isMultiItem && isGrouped)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Stack multiple values'),
            subtitle: const Text('Stack values inside one group.'),
            value: presenter.stackMultipleValues,
            onChanged: presenter.updateStackMultipleValues,
          ),
        const SizedBox(height: 4),
        ...presenter.data.mapIndexed(
          (index, _) => _DataRow(listIndex: index, key: Key('data$index')),
        ),
        const SizedBox(height: 8),
        if (presenter.showMaxDataListMessage)
          Text(
            'Five lists is the demo limit. In code there is no limit.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add another list'),
              onPressed: () {
                final random = Random();
                presenter.addDataList(List<ChartItem<void>>.generate(
                  presenter.data.first.length,
                  (_) => ChartItem<void>(random.nextDouble() * 10),
                ));
              },
            ),
          ),
      ],
    );
  }
}

class _DataRow extends HookConsumerWidget {
  const _DataRow({super.key, required this.listIndex});

  final int listIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final controller = useTextEditingController(text: _valuesText(presenter));

    return LabeledField(
      label: 'Series ${listIndex + 1}',
      child: Row(
        children: [
          ColorSwatchButton(
            color: presenter.listColors[listIndex],
            tooltip: 'Series colour',
            onPressed: () async {
              final color = await ColorPickerDialog.show(
                context,
                presenter.listColors[listIndex],
                additionalText:
                    'In code, colorForValue can give every value its own colour.',
              );
              if (color != null) {
                presenter.updateListColor(color, listIndex);
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '4, 6, 3, 6'),
              onChanged: (text) {
                final data = presenter.data;
                data[listIndex] = text
                    .split(',')
                    .map((value) =>
                        ChartItem<void>(double.tryParse(value.trim()) ?? 0))
                    .toList();
                presenter.updateData(data);
              },
            ),
          ),
          IconButton(
            tooltip: 'Remove series',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => presenter.removeDataList(listIndex),
          ),
        ],
      ),
    );
  }

  String _valuesText(ChartStatePresenter presenter) => presenter.data[listIndex]
      .map((item) => (item.max ?? item.min)?.toStringAsFixed(0) ?? '')
      .join(', ');
}
```

- [ ] **Step 5: Write the Item options section**

`charts_web/lib/ui/playground/options/item_options_section.dart`:

```dart
import 'package:charts_web/ui/common/dialog/border_dialog.dart';
import 'package:charts_web/ui/common/dialog/border_radius_dialog.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemOptionsSection extends ConsumerWidget {
  const ItemOptionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final painter = presenter.selectedPainter;
    final isGeometry =
        painter == SelectedPainter.bar || painter == SelectedPainter.bubble;

    return SectionCard(
      title: 'Item options',
      subtitle: 'How each item is drawn. Presets for bar and bubble; '
          'WidgetItemOptions for anything else.',
      children: [
        SegmentedChoice<SelectedPainter>(
          value: painter,
          options: const [
            SegmentedChoiceOption(
                value: SelectedPainter.bar,
                label: 'Bar',
                icon: Icons.bar_chart),
            SegmentedChoiceOption(
                value: SelectedPainter.bubble,
                label: 'Bubble',
                icon: Icons.bubble_chart_outlined),
            SegmentedChoiceOption(
                value: SelectedPainter.none,
                label: 'Empty',
                icon: Icons.hide_source),
            SegmentedChoiceOption(
                value: SelectedPainter.widget,
                label: 'Widget',
                icon: Icons.widgets_outlined),
          ],
          onChanged: presenter.updateItemPainter,
        ),
        const SizedBox(height: 8),
        if (painter == SelectedPainter.widget)
          Text(
            'WidgetItemOptions draws any widget you hand it. This demo uses an image.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (painter == SelectedPainter.none)
          Text(
            'BarItemOptions with zero width. Pair it with a SparkLine decoration below.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (isGeometry) ...[
          NumberField(
            label: 'Min item width',
            value: presenter.minBarWidth,
            step: 2,
            fallback: 20,
            onChanged: presenter.updateMinBarWidth,
          ),
          NumberField(
            label: 'Max item width',
            value: presenter.maxBarWidth,
            step: 2,
            fallback: 30,
            onChanged: presenter.updateMaxBarWidth,
          ),
          NumberField(
            label: 'Item padding left',
            value: presenter.chartItemPadding.left,
            step: 2,
            onChanged: (value) => presenter.updateChartItemPadding(
                presenter.chartItemPadding.copyWith(left: value)),
          ),
          NumberField(
            label: 'Item padding right',
            value: presenter.chartItemPadding.right,
            step: 2,
            onChanged: (value) => presenter.updateChartItemPadding(
                presenter.chartItemPadding.copyWith(right: value)),
          ),
        ],
        if (presenter.isMultiItem && painter != SelectedPainter.none) ...[
          const Divider(),
          if (!presenter.stackMultipleValues) ...[
            NumberField(
              label: 'Group padding left',
              value: presenter.multiValuePadding.left,
              step: 2,
              onChanged: (value) => presenter.updateMultiValuePadding(
                  presenter.multiValuePadding.copyWith(left: value)),
            ),
            NumberField(
              label: 'Group padding right',
              value: presenter.multiValuePadding.right,
              step: 2,
              onChanged: (value) => presenter.updateMultiValuePadding(
                  presenter.multiValuePadding.copyWith(right: value)),
            ),
          ],
          if (painter == SelectedPainter.bar)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                child: const Text('Border radius for all series'),
                onPressed: () async {
                  final radius = await BorderRadiusDialog.show(
                      context, presenter.barBorderRadius[0]);
                  if (radius != null) {
                    presenter.updateBarBorderRadius(radius, 0, forAll: true);
                  }
                },
              ),
            ),
        ],
        if (isGeometry) ...[
          const Divider(),
          ...presenter.data.mapIndexed(
            (index, _) => _PerSeriesOptions(index: index),
          ),
        ],
      ],
    );
  }
}

class _PerSeriesOptions extends ConsumerWidget {
  const _PerSeriesOptions({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);

    return LabeledField(
      label: 'Series ${index + 1} style',
      child: Row(
        children: [
          ColorSwatchButton(
            color: presenter.listColors[index],
            tooltip: 'Series colour',
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  child: const Text('Border'),
                  onPressed: () async {
                    final border = await BorderSideDialog.show(
                      context,
                      presenter.itemBorderSides[index],
                      presenter.itemBorderSides[index].color,
                    );
                    if (border != null) {
                      presenter.updateItemBorderSide(border, index);
                    }
                  },
                ),
                OutlinedButton(
                  child: const Text('Gradient'),
                  onPressed: () async {
                    final current = presenter.gradient[index] ??
                        LinearGradient(colors: [
                          presenter.listColors[index],
                          Colors.black,
                        ]);
                    final gradient = await LinearGradientPickerDialog.show(
                      context,
                      current,
                      onResetGradient: () =>
                          presenter.updateGradient(null, index),
                    );
                    if (gradient != null) {
                      presenter.updateGradient(gradient, index);
                    }
                  },
                ),
                if (presenter.selectedPainter == SelectedPainter.bar)
                  OutlinedButton(
                    child: const Text('Radius'),
                    onPressed: () async {
                      final radius = await BorderRadiusDialog.show(
                          context, presenter.barBorderRadius[index]);
                      if (radius != null) {
                        presenter.updateBarBorderRadius(radius, index);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

The swatch in `_PerSeriesOptions` is an identity marker rather than a control, so its `onPressed` is intentionally empty — colour is edited from the Data section.

- [ ] **Step 6: Write the options panel**

`charts_web/lib/ui/playground/options/options_panel.dart` — the `DecorationsSection` import lands in Task 8; for this task keep the old `DecorationsComponent`:

```dart
import 'package:charts_web/ui/home/chart_options/widget/options_decoration_component.dart';
import 'package:charts_web/ui/playground/options/data_section.dart';
import 'package:charts_web/ui/playground/options/item_options_section.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionsPanel extends ConsumerWidget {
  const OptionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataSection(),
        SizedBox(height: 12),
        ItemOptionsSection(),
        SizedBox(height: 12),
        DecorationsComponent(),
      ],
    );
  }
}
```

- [ ] **Step 7: Swap the playground over and delete the replaced widgets**

In `charts_web/lib/ui/playground/playground_screen.dart`, replace the `ChartOptions` import with `package:charts_web/ui/playground/options/options_panel.dart` and `child: ChartOptions()` with `child: const OptionsPanel()`.

```bash
cd charts_web
rm lib/ui/home/chart_options/chart_options.dart \
   lib/ui/home/chart_options/widget/options_data_component.dart \
   lib/ui/home/chart_options/widget/options_items_component.dart \
   lib/ui/home/chart_options/widget/options_component_header.dart \
   lib/ui/common/widget/double_option_input.dart \
   lib/ui/common/widget/switch_with_image.dart
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `cd charts_web && fvm flutter analyze && fvm flutter test`
Expected: analyzer count well below baseline (the rewritten option widgets carried most of the deprecations); all tests pass, including the four new option tests.

- [ ] **Step 9: Commit**

```bash
git add -A charts_web/lib charts_web/test
git commit -m "feat(charts_web): rebuild Data and Item options on the design kit

Moves ui/home to ui/playground and drops DoubleOptionInput, which called
double.parse on every keystroke and threw on an empty field."
```

---

### Task 8: Rebuild the Decorations section and dialogs

**Files:**
- Create: `charts_web/lib/ui/playground/options/decorations_section.dart`
- Create: `charts_web/lib/ui/playground/decorations/decoration_card.dart`
- Modify: `charts_web/lib/ui/playground/decorations/decorations_sparkline.dart`
- Modify: `charts_web/lib/ui/playground/decorations/decorations_horizontal_axis.dart`
- Modify: `charts_web/lib/ui/playground/decorations/decorations_vertical_axis.dart`
- Modify: `charts_web/lib/ui/playground/decorations/decorations_widget.dart`
- Delete: `charts_web/lib/ui/playground/decorations/common_decoration_box.dart`
- Delete: `charts_web/lib/ui/home/` (now empty)
- Modify: `charts_web/lib/ui/common/dialog/border_dialog.dart`, `border_radius_dialog.dart`, `gradient_dialog.dart`, `color_picker_dialog.dart` — replace ad-hoc inputs with `NumberField` / `LabeledField`, remove hardcoded colors
- Modify: `charts_web/lib/ui/playground/options/options_panel.dart`
- Test: `charts_web/test/ui/playground/options/decorations_section_test.dart`

**Interfaces:**
- Consumes: design primitives (Task 3); `chartDecorationsPresenter` with `addDecoration`, `removeDecoration`, `moveDecorationToLayer`, `getLayerOfDecoration`, `foregroundDecorations`, `backgroundDecorations`; `DecorationLayer`.
- Produces: `class DecorationsSection extends ConsumerWidget`; `class DecorationCard extends ConsumerWidget` with signature `DecorationCard({required int decorationIndex, required String name, required Widget child, ValueChanged<int>? onDataListSelected})`.

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/playground/options/decorations_section_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/decorations_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adding a sparkline shows its editor and can move layers',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: DecorationsSection()),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SparkLine'));
    await tester.pumpAndSettle();

    final presenter = container.read(chartDecorationsPresenter);
    expect(presenter.foregroundDecorations.values.whereType<SparkLineDecoration>(),
        hasLength(1));
    expect(find.text('SparkLine decoration'), findsOneWidget);

    await tester.tap(find.text('Background'));
    await tester.pumpAndSettle();

    expect(presenter.backgroundDecorations, hasLength(1));
    expect(presenter.foregroundDecorations, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/playground/options/decorations_section_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the decoration card**

`charts_web/lib/ui/playground/decorations/decoration_card.dart`:

```dart
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared frame for one decoration's editor: layer choice, optional series
/// picker, delete, and the decoration-specific controls.
class DecorationCard extends ConsumerWidget {
  const DecorationCard({
    super.key,
    required this.decorationIndex,
    required this.name,
    required this.child,
    this.onDataListSelected,
  });

  final int decorationIndex;
  final String name;
  final Widget child;
  final ValueChanged<int>? onDataListSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decorations = ref.watch(chartDecorationsPresenter);
    final chartState = ref.watch(chartStatePresenter);
    final layer = decorations.getLayerOfDecoration(decorationIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: name,
        initiallyExpanded: true,
        trailing: IconButton(
          tooltip: 'Remove decoration',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => decorations.removeDecoration(decorationIndex),
        ),
        children: [
          SegmentedChoice<DecorationLayer>(
            label: 'Layer',
            helper: 'Background draws under the items, foreground over them.',
            value: layer,
            options: const [
              SegmentedChoiceOption(
                  value: DecorationLayer.background, label: 'Background'),
              SegmentedChoiceOption(
                  value: DecorationLayer.foreground, label: 'Foreground'),
            ],
            onChanged: (value) =>
                decorations.moveDecorationToLayer(decorationIndex, value),
          ),
          if (onDataListSelected != null && chartState.isMultiItem)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text('Series', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 12),
                  ...chartState.listColors.mapIndexed(
                    (index, color) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ColorSwatchButton(
                        color: color,
                        tooltip: 'Use series ${index + 1}',
                        onPressed: () => onDataListSelected!(index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Write the decorations section**

`charts_web/lib/ui/playground/options/decorations_section.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/playground/decorations/decorations_horizontal_axis.dart';
import 'package:charts_web/ui/playground/decorations/decorations_sparkline.dart';
import 'package:charts_web/ui/playground/decorations/decorations_vertical_axis.dart';
import 'package:charts_web/ui/playground/decorations/decorations_widget.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecorationsSection extends ConsumerWidget {
  const DecorationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartDecorationsPresenter);
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Decorations',
      subtitle: 'Everything drawn around the items, in a background or a '
          'foreground layer.',
      children: [
        Text('Add a decoration', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _AddDecorationTile(
              name: 'SparkLine',
              image: Assets.png.generalSparklineDecorationGolden.path,
              onPressed: () => presenter.addDecoration(SparkLineDecoration()),
            ),
            _AddDecorationTile(
              name: 'Horizontal axis',
              image: Assets.png.generalHorizontalDecorationGolden.path,
              onPressed: () =>
                  presenter.addDecoration(HorizontalAxisDecoration()),
            ),
            _AddDecorationTile(
              name: 'Vertical axis',
              image: Assets.png.generalVerticalDecorationGolden.path,
              onPressed: () =>
                  presenter.addDecoration(VerticalAxisDecoration()),
            ),
            _AddDecorationTile(
              name: 'Widget',
              image: Assets.png.futuramaSmall.path,
              onPressed: () => presenter.addDecoration(
                WidgetDecoration(
                  widgetDecorationBuilder: (_, __, ___, ____) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        Text('Foreground', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (presenter.foregroundDecorations.isEmpty)
          _EmptyLayerHint(text: 'No foreground decorations yet.')
        else
          ..._editorsFor(presenter.foregroundDecorations),
        const SizedBox(height: 12),
        Text('Background', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (presenter.backgroundDecorations.isEmpty)
          _EmptyLayerHint(text: 'No background decorations yet.')
        else
          ..._editorsFor(presenter.backgroundDecorations),
      ],
    );
  }

  List<Widget> _editorsFor(Map<int, DecorationPainter> decorations) {
    final widgets = <Widget>[];

    decorations.forEach((index, decoration) {
      widgets.add(switch (decoration) {
        SparkLineDecoration() => DecorationsSparkline(decorationIndex: index),
        VerticalAxisDecoration() =>
          DecorationsVerticalAxis(decorationIndex: index),
        HorizontalAxisDecoration() =>
          DecorationsHorizontalAxis(decorationIndex: index),
        WidgetDecoration() => DecorationsWidget(decorationIndex: index),
        _ => const SizedBox.shrink(),
      });
    });

    return widgets;
  }
}

class _EmptyLayerHint extends StatelessWidget {
  const _EmptyLayerHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _AddDecorationTile extends StatelessWidget {
  const _AddDecorationTile({
    required this.name,
    required this.image,
    required this.onPressed,
  });

  final String name;
  final String image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(image, width: 84, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Convert the four decoration editors**

Each editor keeps its presenter wiring and swaps `CommonDecorationBox` for `DecorationCard` plus design primitives. `charts_web/lib/ui/playground/decorations/decorations_sparkline.dart` in full:

```dart
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DecorationsSparkline extends HookConsumerWidget {
  const DecorationsSparkline({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(decorationSparkLinePresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'SparkLine decoration',
      onDataListSelected: presenter.updateId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fill'),
            subtitle: const Text('Fill under the line instead of stroking it.'),
            value: presenter.filled,
            onChanged: presenter.updateFilled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Smooth points'),
            value: presenter.smoothPoints,
            onChanged: presenter.updateSmoothPoints,
          ),
          NumberField(
            label: 'Line width',
            value: presenter.lineWidth,
            step: 0.5,
            fallback: 1,
            onChanged: presenter.updateLineWidth,
          ),
          NumberField(
            label: 'Start position',
            value: presenter.startPosition,
            step: 0.1,
            fallback: 0.5,
            onChanged: presenter.updateStartPosition,
          ),
          LabeledField(
            label: 'Line colour',
            child: Row(
              children: [
                ColorSwatchButton(
                  color: presenter.color,
                  onPressed: () async {
                    final color =
                        await ColorPickerDialog.show(context, presenter.color);
                    if (color != null) presenter.updateColor(color);
                  },
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  child: Text(
                      presenter.gradient == null ? 'Add gradient' : 'Gradient'),
                  onPressed: () async {
                    final gradient = await LinearGradientPickerDialog.show(
                      context,
                      presenter.gradient ??
                          LinearGradient(
                              colors: [presenter.color, Colors.transparent]),
                      onResetGradient: () => presenter.updateGradient(null),
                    );
                    if (gradient != null) presenter.updateGradient(gradient);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Write `decorations_horizontal_axis.dart` from the code below, then write `decorations_vertical_axis.dart` as the same file with exactly three substitutions:

| Horizontal | Vertical |
|---|---|
| `decorations_horizontal_axis_presenter.dart` | `decorations_vertical_axis_presenter.dart` |
| `decorationHorizontalAxisPresenter` | `decorationVerticalAxisPresenter` |
| `DecorationsHorizontalAxis` / `'Horizontal axis decoration'` | `DecorationsVerticalAxis` / `'Vertical axis decoration'` |

Nothing else differs — both presenters expose the same fields and the same `update*` methods.


```dart
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DecorationsHorizontalAxis extends HookConsumerWidget {
  const DecorationsHorizontalAxis({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter =
        ref.watch(decorationHorizontalAxisPresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'Horizontal axis decoration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show lines'),
            value: presenter.showLines,
            onChanged: presenter.updateShowLines,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show values'),
            value: presenter.showValues,
            onChanged: presenter.updateShowValues,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End with chart'),
            subtitle: const Text('Stop the axis at the last item.'),
            value: presenter.endWithChart,
            onChanged: presenter.updateEndWithChart,
          ),
          NumberField(
            label: 'Line width',
            value: presenter.lineWidth,
            step: 0.5,
            fallback: 1,
            onChanged: presenter.updateLineWidth,
          ),
          NumberField(
            label: 'Axis step',
            value: presenter.axisStep,
            step: 1,
            fallback: 1,
            onChanged: presenter.updateAxisStep,
          ),
          LabeledField(
            label: 'Line colour',
            child: ColorSwatchButton(
              color: presenter.lineColor,
              onPressed: () async {
                final color =
                    await ColorPickerDialog.show(context, presenter.lineColor);
                if (color != null) presenter.updateColor(color);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

`decorations_widget.dart` swaps its `TextButton` row for a `SegmentedChoice<int>` over the five demo types and wraps in `DecorationCard` with name `'Widget decoration'`:

```dart
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_widget_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DecorationsWidget extends HookConsumerWidget {
  const DecorationsWidget({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(decorationWidgetPresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'Widget decoration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A widget decoration draws any widget you give it, so anything you '
            'can build in Flutter can sit on the chart.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SegmentedChoice<int>(
            label: 'Example',
            value: presenter.type,
            options: const [
              SegmentedChoiceOption(value: 0, label: 'Target line'),
              SegmentedChoiceOption(value: 1, label: 'Labelled target'),
              SegmentedChoiceOption(value: 2, label: 'Target area'),
              SegmentedChoiceOption(value: 3, label: 'Border'),
              SegmentedChoiceOption(value: 4, label: 'Clickable'),
            ],
            onChanged: presenter.updateType,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Restyle the four dialogs**

`DoubleOptionInput` was deleted in Task 7, so every dialog referencing it is currently broken. In each of `border_dialog.dart`, `border_radius_dialog.dart`, `gradient_dialog.dart` and `color_picker_dialog.dart`, apply these four substitutions.

Replace each `DoubleOptionInput` — its `name` becomes `label` and its `defaultValue` becomes `fallback`:

```dart
// before
DoubleOptionInput(
  name: 'Width',
  value: width,
  step: 1,
  onChanged: (value) => setState(() => width = value),
  defaultValue: 1,
),

// after
NumberField(
  label: 'Width',
  value: width,
  step: 1,
  onChanged: (value) => setState(() => width = value),
  fallback: 1,
),
```

Wrap any label-plus-control pair in `LabeledField`:

```dart
// before
Row(children: [const Text('Corner radius'), _radiusSlider()]),

// after
LabeledField(label: 'Corner radius', child: _radiusSlider()),
```

Replace hardcoded colours with scheme roles — `Colors.white54` becomes `Theme.of(context).colorScheme.surfaceContainerLow`, `Colors.black87` becomes `onSurface`, `Colors.grey` becomes `onSurfaceVariant`, `const Color(0xffdedede)` becomes `surfaceContainerHighest`.

Replace `MaterialStateProperty.all(x)` with `WidgetStatePropertyAll(x)` wherever it appears.

Leave `colorToCode` in `color_picker_dialog.dart` alone; Task 9 deletes it.

- [ ] **Step 7: Finish the panel and remove the old tree**

In `charts_web/lib/ui/playground/options/options_panel.dart`, replace the `DecorationsComponent` import and usage with `DecorationsSection`.

```bash
cd charts_web
rm -r lib/ui/home
rm lib/ui/playground/decorations/common_decoration_box.dart
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `cd charts_web && fvm flutter analyze && fvm flutter test`
Expected: analyzer count at or below baseline; all tests pass.

- [ ] **Step 9: Commit**

```bash
git add -A charts_web/lib charts_web/test
git commit -m "feat(charts_web): rebuild decorations UI and dialogs on the design kit"
```

---

### Task 9: Source writer and Dart literals

The foundation of the code panel. Pure functions with no Flutter widget dependency, so they are cheap to test exhaustively.

This task also retires `colorToCode` from `color_picker_dialog.dart`, which used `Color.alpha/.red/.green/.blue` — all deprecated since Flutter 3.27.

**Files:**
- Create: `charts_web/lib/codegen/source_writer.dart`
- Create: `charts_web/lib/codegen/dart_literal.dart`
- Modify: `charts_web/lib/ui/common/dialog/color_picker_dialog.dart` (delete `colorToCode`)
- Modify: `charts_web/lib/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart`, `decorations_horizontal_axis_presenter.dart`, `decorations_vertical_axis_presenter.dart` (call `colorLiteral` instead)
- Test: `charts_web/test/codegen/source_writer_test.dart`
- Test: `charts_web/test/codegen/dart_literal_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `class SourceWriter { SourceWriter({int indentWidth = 2}); void line(String text); void open(String text); void close(String text); String build(); }`
  - `String colorLiteral(Color color)`
  - `String doubleLiteral(double value)`
  - `String edgeInsetsLiteral(EdgeInsets insets)`
  - `String borderRadiusLiteral(BorderRadius radius)`
  - `String radiusLiteral(Radius radius)`
  - `String borderSideLiteral(BorderSide side)`
  - `String alignmentLiteral(AlignmentGeometry alignment)`
  - `String gradientLiteral(LinearGradient gradient)`

- [ ] **Step 1: Write the failing tests**

`charts_web/test/codegen/source_writer_test.dart`:

```dart
import 'package:charts_web/codegen/source_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('open and close manage indentation', () {
    final writer = SourceWriter();

    writer.open('ChartState<void>(');
    writer.open('data: ChartData(');
    writer.line('valueAxisMaxOver: 2.0,');
    writer.close('),');
    writer.close(')');

    expect(writer.build(), '''
ChartState<void>(
  data: ChartData(
    valueAxisMaxOver: 2.0,
  ),
)''');
  });

  test('indentWidth is configurable', () {
    final writer = SourceWriter(indentWidth: 4);

    writer.open('a(');
    writer.line('b,');
    writer.close(')');

    expect(writer.build(), 'a(\n    b,\n)');
  });
}
```

`charts_web/test/codegen/dart_literal_test.dart`:

```dart
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('colorLiteral emits an opaque 32-bit ARGB literal', () {
    expect(colorLiteral(const Color(0xFFD8262C)), 'Color(0xFFD8262C)');
    expect(colorLiteral(const Color(0x0A000000)), 'Color(0x0A000000)');
  });

  test('doubleLiteral always reads as a double', () {
    expect(doubleLiteral(2), '2.0');
    expect(doubleLiteral(2.5), '2.5');
    expect(doubleLiteral(-3), '-3.0');
  });

  test('edgeInsetsLiteral picks the shortest accurate form', () {
    expect(edgeInsetsLiteral(EdgeInsets.zero), 'EdgeInsets.zero');
    expect(edgeInsetsLiteral(const EdgeInsets.all(4)), 'EdgeInsets.all(4.0)');
    expect(
      edgeInsetsLiteral(const EdgeInsets.symmetric(horizontal: 2)),
      'EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0)',
    );
    expect(
      edgeInsetsLiteral(const EdgeInsets.only(left: 1, bottom: 3)),
      'EdgeInsets.only(left: 1.0, top: 0.0, right: 0.0, bottom: 3.0)',
    );
  });

  test('borderRadiusLiteral picks the shortest accurate form', () {
    expect(borderRadiusLiteral(BorderRadius.zero), 'BorderRadius.zero');
    expect(
      borderRadiusLiteral(BorderRadius.circular(8)),
      'BorderRadius.all(Radius.circular(8.0))',
    );
    expect(
      borderRadiusLiteral(
          const BorderRadius.vertical(top: Radius.circular(6))),
      'BorderRadius.vertical(top: Radius.circular(6.0), bottom: Radius.circular(0.0))',
    );
  });

  test('borderSideLiteral collapses the none case', () {
    expect(borderSideLiteral(BorderSide.none), 'BorderSide.none');
    expect(
      borderSideLiteral(const BorderSide(color: Color(0xFF112233), width: 2)),
      'BorderSide(color: Color(0xFF112233), width: 2.0)',
    );
  });

  test('alignmentLiteral prefers the named constants', () {
    expect(alignmentLiteral(Alignment.centerLeft), 'Alignment.centerLeft');
    expect(alignmentLiteral(const Alignment(0.25, -0.5)),
        'Alignment(0.25, -0.5)');
  });

  test('gradientLiteral emits colors, begin and end', () {
    expect(
      gradientLiteral(const LinearGradient(
        colors: [Color(0xFFD8262C), Color(0xFF000000)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      )),
      'LinearGradient(colors: [Color(0xFFD8262C), Color(0xFF000000)], '
      'begin: Alignment.centerLeft, end: Alignment.centerRight)',
    );
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd charts_web && fvm flutter test test/codegen/`
Expected: FAIL — URIs do not exist.

- [ ] **Step 3: Write `SourceWriter`**

`charts_web/lib/codegen/source_writer.dart`:

```dart
/// Accumulates generated Dart source, owning indentation so emitters never
/// hand-manage whitespace.
class SourceWriter {
  SourceWriter({this.indentWidth = 2});

  final int indentWidth;

  final StringBuffer _buffer = StringBuffer();
  int _depth = 0;

  /// Writes one line at the current depth.
  void line(String text) {
    _buffer.writeln('${' ' * (_depth * indentWidth)}$text');
  }

  /// Writes [text] then indents everything after it.
  void open(String text) {
    line(text);
    _depth++;
  }

  /// Dedents, then writes [text].
  void close(String text) {
    assert(_depth > 0, 'close() without a matching open()');
    _depth--;
    line(text);
  }

  String build() => _buffer.toString().trimRight();
}
```

- [ ] **Step 4: Write the literal emitters**

`charts_web/lib/codegen/dart_literal.dart`:

```dart
import 'package:flutter/painting.dart';

/// Emits `Color(0xAARRGGBB)`. Uses `toARGB32()`; the per-channel getters
/// (`.alpha`, `.red`, ...) have been deprecated since Flutter 3.27.
String colorLiteral(Color color) {
  final argb =
      color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');

  return 'Color(0x$argb)';
}

/// Always renders as a Dart double, so `2` never lands in an `int` parameter.
String doubleLiteral(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(1) : '$value';

String edgeInsetsLiteral(EdgeInsets insets) {
  if (insets == EdgeInsets.zero) return 'EdgeInsets.zero';

  if (insets.left == insets.right && insets.top == insets.bottom) {
    if (insets.left == insets.top) {
      return 'EdgeInsets.all(${doubleLiteral(insets.left)})';
    }

    return 'EdgeInsets.symmetric(horizontal: ${doubleLiteral(insets.left)}, '
        'vertical: ${doubleLiteral(insets.top)})';
  }

  return 'EdgeInsets.only(left: ${doubleLiteral(insets.left)}, '
      'top: ${doubleLiteral(insets.top)}, '
      'right: ${doubleLiteral(insets.right)}, '
      'bottom: ${doubleLiteral(insets.bottom)})';
}

String radiusLiteral(Radius radius) => radius.x == radius.y
    ? 'Radius.circular(${doubleLiteral(radius.x)})'
    : 'Radius.elliptical(${doubleLiteral(radius.x)}, ${doubleLiteral(radius.y)})';

String borderRadiusLiteral(BorderRadius radius) {
  if (radius == BorderRadius.zero) return 'BorderRadius.zero';

  final topLeft = radius.topLeft;
  final topRight = radius.topRight;
  final bottomLeft = radius.bottomLeft;
  final bottomRight = radius.bottomRight;

  if (topLeft == topRight && topRight == bottomLeft && bottomLeft == bottomRight) {
    return 'BorderRadius.all(${radiusLiteral(topLeft)})';
  }

  if (topLeft == topRight && bottomLeft == bottomRight) {
    return 'BorderRadius.vertical(top: ${radiusLiteral(topLeft)}, '
        'bottom: ${radiusLiteral(bottomLeft)})';
  }

  if (topLeft == bottomLeft && topRight == bottomRight) {
    return 'BorderRadius.horizontal(left: ${radiusLiteral(topLeft)}, '
        'right: ${radiusLiteral(topRight)})';
  }

  return 'BorderRadius.only(topLeft: ${radiusLiteral(topLeft)}, '
      'topRight: ${radiusLiteral(topRight)}, '
      'bottomLeft: ${radiusLiteral(bottomLeft)}, '
      'bottomRight: ${radiusLiteral(bottomRight)})';
}

String borderSideLiteral(BorderSide side) => side == BorderSide.none
    ? 'BorderSide.none'
    : 'BorderSide(color: ${colorLiteral(side.color)}, '
        'width: ${doubleLiteral(side.width)})';

const Map<Alignment, String> _namedAlignments = {
  Alignment.topLeft: 'Alignment.topLeft',
  Alignment.topCenter: 'Alignment.topCenter',
  Alignment.topRight: 'Alignment.topRight',
  Alignment.centerLeft: 'Alignment.centerLeft',
  Alignment.center: 'Alignment.center',
  Alignment.centerRight: 'Alignment.centerRight',
  Alignment.bottomLeft: 'Alignment.bottomLeft',
  Alignment.bottomCenter: 'Alignment.bottomCenter',
  Alignment.bottomRight: 'Alignment.bottomRight',
};

String alignmentLiteral(AlignmentGeometry alignment) {
  if (alignment is! Alignment) return 'Alignment.center';

  return _namedAlignments[alignment] ??
      'Alignment(${doubleLiteral(alignment.x)}, ${doubleLiteral(alignment.y)})';
}

String gradientLiteral(LinearGradient gradient) {
  final parts = <String>[
    'colors: [${gradient.colors.map(colorLiteral).join(', ')}]',
    'begin: ${alignmentLiteral(gradient.begin)}',
    'end: ${alignmentLiteral(gradient.end)}',
  ];

  final stops = gradient.stops;
  if (stops != null) {
    parts.add('stops: [${stops.map(doubleLiteral).join(', ')}]');
  }

  return 'LinearGradient(${parts.join(', ')})';
}
```

`doubleLiteral(0.25)` returns `0.25` and `doubleLiteral(-0.5)` returns `-0.5`, which is what the `alignmentLiteral` test expects.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd charts_web && fvm flutter test test/codegen/`
Expected: PASS (9 tests)

- [ ] **Step 6: Retire `colorToCode`**

Delete this function from the bottom of `charts_web/lib/ui/common/dialog/color_picker_dialog.dart`:

```dart
String colorToCode(Color color) {
  return 'Color.fromARGB(${color.alpha}, ${color.red}, ${color.green}, ${color.blue})';
}
```

In each of `decorations_sparkline_presenter.dart`, `decorations_horizontal_axis_presenter.dart` and `decorations_vertical_axis_presenter.dart`: drop the `color_picker_dialog.dart` import, add `import 'package:charts_web/codegen/dart_literal.dart';`, and change `colorToCode(x)` to `colorLiteral(x)` inside `buildDecorationCode()`. That method is rewritten wholesale in Task 11; this keeps the tree compiling in the meantime.

- [ ] **Step 7: Verify**

Run: `cd charts_web && grep -rn "colorToCode" lib ; fvm flutter analyze | tail -1 && fvm flutter test`
Expected: grep prints nothing; analyzer count at or below baseline; tests pass.

- [ ] **Step 8: Commit**

```bash
git add charts_web/lib/codegen charts_web/lib/ui charts_web/test/codegen
git commit -m "feat(charts_web): add SourceWriter and Dart literal emitters

Replaces colorToCode, which used the Color channel getters deprecated in
Flutter 3.27."
```

---

### Task 10: Emit data and item options

**Files:**
- Create: `charts_web/lib/codegen/data_source.dart`
- Create: `charts_web/lib/codegen/item_options_source.dart`
- Test: `charts_web/test/codegen/data_source_test.dart`
- Test: `charts_web/test/codegen/item_options_source_test.dart`

**Interfaces:**
- Consumes: `SourceWriter`, all literal emitters (Task 9); `ChartStatePresenter` (existing: `data`, `state`, `stackMultipleValues`, `selectedPainter`, `listColors`, `chartItemPadding`, `multiValuePadding`, `maxBarWidth`, `minBarWidth`, `itemBorderSides`, `barBorderRadius`, `gradient`).
- Produces:
  - `void writeChartData(SourceWriter writer, ChartStatePresenter presenter)`
  - `void writeItemOptions(SourceWriter writer, ChartStatePresenter presenter)`

Emitted code uses `ChartItem<void>(x)`, never the deprecated `BarValue`. Per-series values are emitted as an inline indexed list so the snippet stays a single self-contained expression.

The playground exposes no control over `ChartBehaviour`, so nothing is emitted for it; adding behaviour controls later means adding a `behaviour_source.dart` alongside these.

- [ ] **Step 1: Write the failing tests**

`charts_web/test/codegen/data_source_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/data_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

String render(void Function(ChartStatePresenter) configure) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final presenter = container.read(chartStatePresenter);
  configure(presenter);

  final writer = SourceWriter();
  writeChartData(writer, presenter);

  return writer.build();
}

void main() {
  test('single list emits one ChartItem list and no strategy', () {
    final source = render((presenter) => presenter.updateData([
          [4, 6, 3].map((e) => ChartItem<void>(e.toDouble())).toList(),
        ]));

    expect(source, '''
data: ChartData(
  [
    [4.0, 6.0, 3.0].map((e) => ChartItem<void>(e)).toList(),
  ],
  valueAxisMaxOver: 2.0,
),''');
  });

  test('stack strategy is emitted when selected', () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter.updateDataStrategy(const StackDataStrategy());
    });

    expect(source, contains('dataStrategy: const StackDataStrategy(),'));
  });

  test('grouped strategy emits stackMultipleValues when turned off', () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter
          .updateDataStrategy(const DefaultDataStrategy(stackMultipleValues: true));
      presenter.updateStackMultipleValues(false);
    });

    expect(
      source,
      contains(
          'dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),'),
    );
  });

  test('never emits the deprecated BarValue constructor', () {
    expect(render((_) {}), isNot(contains('BarValue')));
  });
}
```

`charts_web/test/codegen/item_options_source_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/item_options_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String render(void Function(ChartStatePresenter) configure) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final presenter = container.read(chartStatePresenter);
  configure(presenter);

  final writer = SourceWriter();
  writeItemOptions(writer, presenter);

  return writer.build();
}

void main() {
  test('bar painter emits BarItemOptions with the series colour', () {
    final source = render((presenter) {
      presenter.updateItemPainter(SelectedPainter.bar);
      presenter.updateListColor(const Color(0xFFD8262C), 0);
    });

    expect(source, startsWith('itemOptions: BarItemOptions('));
    expect(source, contains('barItemBuilder: (data) => BarItem('));
    expect(source, contains('color: Color(0xFFD8262C),'));
  });

  test('bar painter omits radius, border and gradient when unset', () {
    final source = render(
        (presenter) => presenter.updateItemPainter(SelectedPainter.bar));

    expect(source, isNot(contains('radius:')));
    expect(source, isNot(contains('border:')));
    expect(source, isNot(contains('gradient:')));
  });

  test('multiple series emit an indexed lookup', () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter.updateListColor(const Color(0xFF111111), 0);
      presenter.updateListColor(const Color(0xFF222222), 1);
    });

    expect(
      source,
      contains(
          'color: [Color(0xFF111111), Color(0xFF222222)][data.listIndex % 2],'),
    );
  });

  test('per-series radius is emitted when any series sets one', () {
    final source = render((presenter) {
      presenter.updateItemPainter(SelectedPainter.bar);
      presenter.updateBarBorderRadius(BorderRadius.circular(8), 0);
    });

    expect(source, contains('radius: BorderRadius.all(Radius.circular(8.0)),'));
  });

  test('empty painter emits a zero-width transparent bubble', () {
    final source = render(
        (presenter) => presenter.updateItemPainter(SelectedPainter.none));

    expect(source, contains('BubbleItemOptions('));
    expect(source, contains('maxBarWidth: 0.0,'));
    expect(source, contains('Color(0x00000000)'));
  });

  test('widget painter emits a compiling substitute and points at the source',
      () {
    final source = render(
        (presenter) => presenter.updateItemPainter(SelectedPainter.widget));

    expect(source, contains('WidgetItemOptions('));
    expect(source, contains('widgetItemBuilder:'));
    expect(source, contains('futurama_bar_widget.dart'));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd charts_web && fvm flutter test test/codegen/data_source_test.dart test/codegen/item_options_source_test.dart`
Expected: FAIL — URIs do not exist.

- [ ] **Step 3: Write the data emitter**

`charts_web/lib/codegen/data_source.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';

/// Emits the `data:` argument of `ChartState`.
void writeChartData(SourceWriter writer, ChartStatePresenter presenter) {
  writer.open('data: ChartData(');
  writer.open('[');

  for (final list in presenter.data) {
    final values =
        list.map((item) => doubleLiteral(item.max ?? 0)).join(', ');
    writer.line('[$values].map((e) => ChartItem<void>(e)).toList(),');
  }

  writer.close('],');

  final strategy = presenter.state.data.dataStrategy;
  if (strategy is StackDataStrategy) {
    writer.line('dataStrategy: const StackDataStrategy(),');
  } else if (!presenter.stackMultipleValues) {
    // The library default is DefaultDataStrategy(stackMultipleValues: true),
    // so it only needs emitting when the user turned stacking off.
    writer.line(
        'dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),');
  }

  // The presenter always sets this, so it is always part of the output.
  writer.line('valueAxisMaxOver: 2.0,');
  writer.close('),');
}
```

- [ ] **Step 4: Write the item options emitter**

`charts_web/lib/codegen/item_options_source.dart`:

```dart
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter/painting.dart';

/// Emits the `itemOptions:` argument of `ChartState`.
void writeItemOptions(SourceWriter writer, ChartStatePresenter presenter) {
  switch (presenter.selectedPainter) {
    case SelectedPainter.bar:
      _writeGeometry(writer, presenter, isBar: true);
    case SelectedPainter.bubble:
      _writeGeometry(writer, presenter, isBar: false);
    case SelectedPainter.none:
      _writeEmpty(writer);
    case SelectedPainter.widget:
      _writeWidget(writer);
  }
}

void _writeGeometry(
  SourceWriter writer,
  ChartStatePresenter presenter, {
  required bool isBar,
}) {
  final seriesCount = presenter.data.length;

  writer.open('itemOptions: ${isBar ? 'BarItemOptions' : 'BubbleItemOptions'}(');

  if (presenter.chartItemPadding != EdgeInsets.zero) {
    writer.line('padding: ${edgeInsetsLiteral(presenter.chartItemPadding)},');
  }
  if (presenter.multiValuePadding != EdgeInsets.zero) {
    writer.line(
        'multiValuePadding: ${edgeInsetsLiteral(presenter.multiValuePadding)},');
  }
  if (presenter.maxBarWidth != null) {
    writer.line('maxBarWidth: ${doubleLiteral(presenter.maxBarWidth!)},');
  }
  if (presenter.minBarWidth != null) {
    writer.line('minBarWidth: ${doubleLiteral(presenter.minBarWidth!)},');
  }

  final builder = isBar ? 'barItemBuilder' : 'bubbleItemBuilder';
  final item = isBar ? 'BarItem' : 'BubbleItem';

  writer.open('$builder: (data) => $item(');
  writer.line('color: ${_perSeries(
    seriesCount,
    (index) => colorLiteral(presenter.listColors[index % presenter.listColors.length]),
  )},');

  if (presenter.gradient.isNotEmpty) {
    writer.line('gradient: ${_perSeries(
      seriesCount,
      (index) {
        final gradient = presenter.gradient[index];

        return gradient == null ? 'null' : gradientLiteral(gradient);
      },
    )},');
  }

  if (presenter.itemBorderSides.any((side) => side != BorderSide.none)) {
    writer.line('border: ${_perSeries(
      seriesCount,
      (index) => borderSideLiteral(presenter.itemBorderSides[index]),
    )},');
  }

  if (isBar &&
      presenter.barBorderRadius.any((radius) => radius != BorderRadius.zero)) {
    writer.line('radius: ${_perSeries(
      seriesCount,
      (index) => borderRadiusLiteral(presenter.barBorderRadius[index]),
    )},');
  }

  writer.close('),');
  writer.close('),');
}

void _writeEmpty(SourceWriter writer) {
  writer.open('itemOptions: BubbleItemOptions(');
  writer.line(
      'bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),');
  writer.line('maxBarWidth: 0.0,');
  writer.line('minBarWidth: 0.0,');
  writer.close('),');
}

void _writeWidget(SourceWriter writer) {
  writer.open('itemOptions: WidgetItemOptions(');
  writer.line('// Any widget works here. This demo draws an image; see');
  writer.line('// charts_web/lib/ui/playground/options/futurama_bar_widget.dart');
  writer.open('widgetItemBuilder: (data) => DecoratedBox(');
  writer.open('decoration: BoxDecoration(');
  writer.line('color: Color(0xFFD8262C),');
  writer.line('borderRadius: BorderRadius.all(Radius.circular(4.0)),');
  writer.close('),');
  writer.line('child: const SizedBox.expand(),');
  writer.close('),');
  writer.close('),');
}

/// One value for a single series, or an inline indexed lookup for several, so
/// the emitted builder stays a self-contained expression.
String _perSeries(int count, String Function(int index) literalFor) {
  if (count <= 1) return literalFor(0);

  final literals = List.generate(count, literalFor).join(', ');

  return '[$literals][data.listIndex % $count]';
}
```

`EdgeInsets`, `BorderSide` and `BorderRadius` would also arrive transitively through `chart_state_presenter.dart`'s `material_ui` import; the explicit `package:flutter/painting.dart` above keeps this a pure-logic file with no Material dependency.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd charts_web && fvm flutter test test/codegen/`
Expected: PASS (20 tests)

- [ ] **Step 6: Commit**

```bash
git add charts_web/lib/codegen charts_web/test/codegen
git commit -m "feat(charts_web): emit ChartData and item options as Dart source"
```

---

### Task 11: Emit decorations

Rewrites the dead-and-rotted `buildDecorationCode()` into a `SourceWriter`-based `writeDecorationSource()`, kept next to each presenter's `buildDecoration()` so a change to one is visible from the other. This fixes both live defects: the sparkline emitter's `lineKey:` (not a `SparkLineDecoration` parameter — the correct name is `listIndex`) and its hardcoded `gradient: null`.

**Files:**
- Create: `charts_web/lib/codegen/decorations_source.dart`
- Modify: `charts_web/lib/ui/playground/presenter/chart_decorations_presenter.dart` (the `DecorationBuilder` abstract class at the bottom of the file)
- Modify: `charts_web/lib/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart`
- Modify: `charts_web/lib/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart`
- Modify: `charts_web/lib/ui/playground/decorations/presenters/decorations_vertical_axis_presenter.dart`
- Modify: `charts_web/lib/ui/playground/decorations/presenters/decorations_widget_presenter.dart`
- Test: `charts_web/test/codegen/decorations_source_test.dart`

**Interfaces:**
- Consumes: `SourceWriter`, literal emitters (Task 9); `ChartDecorationsPresenter` (existing: `ref`, `foregroundDecorations`, `backgroundDecorations`, `addDecoration`).
- Produces:
  - `abstract class DecorationBuilder { DecorationPainter buildDecoration(); void writeDecorationSource(SourceWriter writer); }` — replaces `String buildDecorationCode()`
  - `void writeDecorations(SourceWriter writer, ChartDecorationsPresenter presenter)`

- [ ] **Step 1: Write the failing test**

`charts_web/test/codegen/decorations_source_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/decorations_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String render(void Function(ProviderContainer) configure) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  configure(container);

  final writer = SourceWriter();
  writeDecorations(writer, container.read(chartDecorationsPresenter));

  return writer.build();
}

void main() {
  test('nothing is emitted when there are no decorations', () {
    expect(render((_) {}), isEmpty);
  });

  test('a sparkline emits listIndex, not the non-existent lineKey', () {
    final source = render((container) => container
        .read(chartDecorationsPresenter)
        .addDecoration(SparkLineDecoration()));

    expect(source, contains('SparkLineDecoration('));
    expect(source, isNot(contains('lineKey')));
  });

  test('a sparkline gradient reaches the output', () {
    final source = render((container) {
      container
          .read(chartDecorationsPresenter)
          .addDecoration(SparkLineDecoration());
      container.read(decorationSparkLinePresenter(0)).updateGradient(
            const LinearGradient(
              colors: [Color(0xFFD8262C), Color(0x00000000)],
            ),
          );
    });

    expect(source, contains('gradient: LinearGradient(colors: ['));
  });

  test('decorations are grouped by layer', () {
    final source = render((container) {
      final presenter = container.read(chartDecorationsPresenter);
      presenter.addDecoration(HorizontalAxisDecoration(),
          layer: DecorationLayer.background);
      presenter.addDecoration(SparkLineDecoration(),
          layer: DecorationLayer.foreground);
    });

    expect(source, contains('backgroundDecorations: ['));
    expect(source, contains('foregroundDecorations: ['));
    expect(
      source.indexOf('backgroundDecorations'),
      lessThan(source.indexOf('foregroundDecorations')),
    );
  });

  test('axis defaults are omitted but the explicit textScale is kept', () {
    final source = render((container) => container
        .read(chartDecorationsPresenter)
        .addDecoration(VerticalAxisDecoration()));

    expect(source, contains('VerticalAxisDecoration('));
    expect(source, contains('textScale: 1.2,'));
    expect(source, isNot(contains('showLines: true,')));
    expect(source, isNot(contains('showValues: false,')));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/codegen/decorations_source_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Change the `DecorationBuilder` interface**

In `charts_web/lib/ui/playground/presenter/chart_decorations_presenter.dart`, add `import 'package:charts_web/codegen/source_writer.dart';` and replace:

```dart
abstract class DecorationBuilder {
  DecorationPainter buildDecoration();
  String buildDecorationCode();
}
```

with:

```dart
abstract class DecorationBuilder {
  DecorationPainter buildDecoration();

  /// Emits the Dart source for this decoration. Kept next to
  /// [buildDecoration] on purpose: whoever changes one sees the other.
  void writeDecorationSource(SourceWriter writer);
}
```

- [ ] **Step 4: Rewrite the sparkline emitter**

In `decorations_sparkline_presenter.dart`, replace the whole `buildDecorationCode()` method with:

```dart
  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('SparkLineDecoration(');
    if (lineId != 0) writer.line('listIndex: $lineId,');
    if (filled) writer.line('fill: true,');
    if (smoothPoints) writer.line('smoothPoints: true,');
    writer.line('lineColor: ${colorLiteral(color)},');
    if (lineWidth != 1.0) {
      writer.line('lineWidth: ${doubleLiteral(lineWidth)},');
    }
    if (startPosition != 0.5) {
      writer.line('startPosition: ${doubleLiteral(startPosition)},');
    }
    final currentGradient = gradient;
    if (currentGradient != null) {
      writer.line('gradient: ${gradientLiteral(currentGradient)},');
    }
    writer.close('),');
  }
```

Add `import 'package:charts_web/codegen/source_writer.dart';` alongside the `dart_literal.dart` import added in Task 9.

- [ ] **Step 5: Rewrite both axis emitters**

In `decorations_horizontal_axis_presenter.dart` (and the same shape in `decorations_vertical_axis_presenter.dart`, swapping the class name), replace `buildDecorationCode()` with:

```dart
  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('HorizontalAxisDecoration(');
    // The presenter always sets a non-default text scale.
    writer.line('textScale: 1.2,');
    if (!showLines) writer.line('showLines: false,');
    if (showValues) writer.line('showValues: true,');
    if (endWithChart) writer.line('endWithChart: true,');
    if (lineWidth != 1.0) {
      writer.line('lineWidth: ${doubleLiteral(lineWidth)},');
    }
    if (axisStep != 1.0) {
      writer.line('axisStep: ${doubleLiteral(axisStep)},');
    }
    writer.line('lineColor: ${colorLiteral(lineColor)},');
    writer.close('),');
  }
```

Library defaults being skipped here are `showLines: true`, `showValues: false`, `endWithChart: false`, `lineWidth: 1.0`, `axisStep: 1.0` — confirmed against `HorizontalAxisDecoration` and `VerticalAxisDecoration` in `lib/chart/render/decorations/`.

- [ ] **Step 6: Rewrite the widget decoration emitter**

In `decorations_widget_presenter.dart`, replace `buildDecorationCode()` with:

```dart
  static const Map<int, String> _exampleNames = {
    0: 'target line',
    1: 'target line with a label',
    2: 'target area',
    3: 'border',
    4: 'clickable widget',
  };

  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('WidgetDecoration(');
    writer.line('// This playground draws a ${_exampleNames[type]} here.');
    writer.line('// A widget decoration can return any widget; the demo builds');
    writer.line('// are in charts_web/lib/ui/playground/decorations/presenters/');
    writer.line('// decorations_widget_presenter.dart');
    writer.open(
        'widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {');
    writer.open('return DecoratedBox(');
    writer.open('decoration: BoxDecoration(');
    writer.line('border: Border.all(color: Color(0xFF2196F3), width: 3.0),');
    writer.close('),');
    writer.line('child: const SizedBox.expand(),');
    writer.close(');');
    writer.close('},');
    writer.line('margin: EdgeInsets.all(3.0),');
    writer.close('),');
  }
```

This is the documented limitation of full-fidelity output: a closure cannot be serialised, so the emitted builder is a compiling stand-in and a comment points at the real one.

- [ ] **Step 7: Write the decorations emitter**

`charts_web/lib/codegen/decorations_source.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_vertical_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_widget_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';

/// Emits the `backgroundDecorations:` and `foregroundDecorations:` arguments.
/// Background comes first, matching paint order.
void writeDecorations(
    SourceWriter writer, ChartDecorationsPresenter presenter) {
  _writeLayer(
      writer, presenter, 'backgroundDecorations', presenter.backgroundDecorations);
  _writeLayer(
      writer, presenter, 'foregroundDecorations', presenter.foregroundDecorations);
}

void _writeLayer(
  SourceWriter writer,
  ChartDecorationsPresenter presenter,
  String parameterName,
  Map<int, DecorationPainter> decorations,
) {
  if (decorations.isEmpty) return;

  writer.open('$parameterName: [');

  decorations.forEach((index, decoration) {
    _builderFor(presenter, index, decoration)?.writeDecorationSource(writer);
  });

  writer.close('],');
}

/// Maps a live decoration back to the presenter that owns its settings, the
/// same dispatch `ChartDecorationsPresenter.addDecoration` uses.
DecorationBuilder? _builderFor(
  ChartDecorationsPresenter presenter,
  int index,
  DecorationPainter decoration,
) =>
    switch (decoration) {
      SparkLineDecoration() =>
        presenter.ref.read(decorationSparkLinePresenter(index)),
      VerticalAxisDecoration() =>
        presenter.ref.read(decorationVerticalAxisPresenter(index)),
      HorizontalAxisDecoration() =>
        presenter.ref.read(decorationHorizontalAxisPresenter(index)),
      WidgetDecoration() =>
        presenter.ref.read(decorationWidgetPresenter(index)),
      _ => null,
    };
```

Note `HorizontalAxisDecoration` must be matched after `VerticalAxisDecoration` only if one subclasses the other — they do not, so order is free; keeping it identical to `addDecoration`'s order avoids a future divergence.

- [ ] **Step 8: Run tests to verify they pass**

Run: `cd charts_web && fvm flutter analyze | tail -1 && fvm flutter test`
Expected: analyzer count at or below baseline; all tests pass, including 5 new decoration tests.

- [ ] **Step 9: Commit**

```bash
git add charts_web/lib charts_web/test/codegen
git commit -m "fix(charts_web): rewrite decoration codegen onto SourceWriter

buildDecorationCode was dead code and had rotted: the sparkline emitter wrote
lineKey, which is not a SparkLineDecoration parameter (it is listIndex), and
hardcoded gradient: null while the live decoration used the real gradient."
```

---

### Task 12: Assemble `ChartState` source and prove it compiles

**Files:**
- Create: `charts_web/lib/codegen/chart_state_source.dart`
- Create: `charts_web/test/codegen/chart_state_source_test.dart`
- Create: `charts_web/test/codegen/generated/` (8 committed fixtures)

**Interfaces:**
- Consumes: `writeChartData` (Task 10), `writeItemOptions` (Task 10), `writeDecorations` (Task 11), `SourceWriter` (Task 9).
- Produces: `String buildChartStateSource(ChartStatePresenter state, ChartDecorationsPresenter decorations)`

- [ ] **Step 1: Write the entry point**

`charts_web/lib/codegen/chart_state_source.dart`:

```dart
import 'package:charts_web/codegen/data_source.dart';
import 'package:charts_web/codegen/decorations_source.dart';
import 'package:charts_web/codegen/item_options_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';

/// Builds the Dart source for the current playground configuration.
///
/// Reads the presenters rather than the built `ChartState`, because a
/// `ChartState` has already erased the user's intent into closures.
///
/// Values equal to a library default are omitted; everything the user changed
/// is emitted. The result therefore reproduces the chart exactly without
/// spelling out defaults.
String buildChartStateSource(
  ChartStatePresenter state,
  ChartDecorationsPresenter decorations,
) {
  final writer = SourceWriter();

  writer.open('ChartState<void>(');
  writeChartData(writer, state);
  writeItemOptions(writer, state);
  writeDecorations(writer, decorations);
  writer.close(')');

  return writer.build();
}
```

The playground has no `ChartBehaviour` controls, so nothing is emitted for `behaviour:`. Adding such controls later means adding a `behaviour_source.dart` and one call here.

- [ ] **Step 2: Write the fixture test**

`charts_web/test/codegen/chart_state_source_test.dart`:

```dart
import 'dart:io';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/chart_state_source.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class Preset {
  const Preset(this.functionName, this.fileName, this.configure);

  final String functionName;
  final String fileName;
  final void Function(ProviderContainer container) configure;
}

final presets = <Preset>[
  Preset('fixture01DefaultBar', 'fixture_01_default_bar.dart', (_) {}),
  Preset('fixture02StackedSeries', 'fixture_02_stacked_series.dart', (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.addDataList(
        [3, 5, 1, 4].map((e) => ChartItem<void>(e.toDouble())).toList());
    presenter.updateDataStrategy(const StackDataStrategy());
  }),
  Preset('fixture03GroupedSeries', 'fixture_03_grouped_series.dart', (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.addDataList(
        [3, 5, 1, 4].map((e) => ChartItem<void>(e.toDouble())).toList());
    presenter.updateDataStrategy(
        const DefaultDataStrategy(stackMultipleValues: true));
    presenter.updateStackMultipleValues(false);
    presenter.updateMultiValuePadding(const EdgeInsets.symmetric(horizontal: 2));
  }),
  Preset('fixture04Bubble', 'fixture_04_bubble.dart', (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.updateItemPainter(SelectedPainter.bubble);
    presenter.updateMinBarWidth(6);
    presenter.updateMaxBarWidth(10);
  }),
  Preset('fixture05BarStyled', 'fixture_05_bar_styled.dart', (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.updateBarBorderRadius(
        const BorderRadius.vertical(top: Radius.circular(8)), 0);
    presenter.updateItemBorderSide(
        const BorderSide(color: Color(0xFF202020), width: 2), 0);
    presenter.updateGradient(
        const LinearGradient(
          colors: [Color(0xFFD8262C), Color(0xFF6479C3)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        0);
  }),
  Preset('fixture06Sparkline', 'fixture_06_sparkline.dart', (container) {
    container.read(chartStatePresenter).updateItemPainter(SelectedPainter.none);
    container
        .read(chartDecorationsPresenter)
        .addDecoration(SparkLineDecoration());
    final sparkline = container.read(decorationSparkLinePresenter(0));
    sparkline.updateFilled(true);
    sparkline.updateSmoothPoints(true);
    sparkline.updateLineWidth(2);
    sparkline.updateGradient(const LinearGradient(
      colors: [Color(0x66D8262C), Color(0x00D8262C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ));
  }),
  Preset('fixture07BothAxes', 'fixture_07_both_axes.dart', (container) {
    final decorations = container.read(chartDecorationsPresenter);
    decorations.addDecoration(HorizontalAxisDecoration(),
        layer: DecorationLayer.background);
    decorations.addDecoration(VerticalAxisDecoration(),
        layer: DecorationLayer.background);
  }),
  Preset('fixture08WidgetEverything', 'fixture_08_widget_everything.dart',
      (container) {
    container
        .read(chartStatePresenter)
        .updateItemPainter(SelectedPainter.widget);
    container.read(chartDecorationsPresenter).addDecoration(
          WidgetDecoration(
            widgetDecorationBuilder: (_, __, ___, ____) =>
                const SizedBox.shrink(),
          ),
        );
  }),
];

String wrap(String functionName, String expression) => '''
// GENERATED — do not edit by hand.
// Regenerate with:
//   UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
// Committed so `fvm flutter analyze` proves the generated source compiles.

import 'package:charts_painter/chart.dart';
import 'package:material_ui/material_ui.dart';

ChartState<void> $functionName() => $expression;
''';

void main() {
  for (final preset in presets) {
    test('${preset.functionName} matches its committed fixture', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      preset.configure(container);

      final source = buildChartStateSource(
        container.read(chartStatePresenter),
        container.read(chartDecorationsPresenter),
      );
      final rendered = wrap(preset.functionName, source);
      final file = File('test/codegen/generated/${preset.fileName}');

      if (Platform.environment['UPDATE_FIXTURES'] == '1') {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(rendered);
      }

      expect(
        file.readAsStringSync(),
        rendered,
        reason: 'Generated source drifted. Regenerate with '
            'UPDATE_FIXTURES=1 fvm flutter test '
            'test/codegen/chart_state_source_test.dart',
      );
    });
  }

  test('generated source never contains a deprecated constructor', () {
    for (final preset in presets) {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      preset.configure(container);

      final source = buildChartStateSource(
        container.read(chartStatePresenter),
        container.read(chartDecorationsPresenter),
      );

      expect(source, isNot(contains('BarValue')), reason: preset.functionName);
      expect(source, isNot(contains('BubbleValue')),
          reason: preset.functionName);
      expect(source, isNot(contains('lineKey')), reason: preset.functionName);
    }
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `cd charts_web && fvm flutter test test/codegen/chart_state_source_test.dart`
Expected: FAIL — the fixture files do not exist yet (`FileSystemException` on read).

- [ ] **Step 4: Generate the fixtures**

Run: `cd charts_web && UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart`
Expected: PASS (9 tests), and `test/codegen/generated/` now holds 8 `.dart` files.

- [ ] **Step 5: Read the generated output**

Run: `cd charts_web && cat test/codegen/generated/fixture_05_bar_styled.dart`
Expected: something of this shape — a single expression, no defaults, no deprecated constructors:

```dart
ChartState<void> fixture05BarStyled() => ChartState<void>(
  data: ChartData(
    [
      [4.0, 6.0, 3.0, 6.0, 7.0, 9.0, 3.0, 2.0].map((e) => ChartItem<void>(e)).toList(),
    ],
    valueAxisMaxOver: 2.0,
  ),
  itemOptions: BarItemOptions(
    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
    barItemBuilder: (data) => BarItem(
      color: Color(0xFFD8555F),
      gradient: LinearGradient(colors: [Color(0xFFD8262C), Color(0xFF6479C3)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
      border: BorderSide(color: Color(0xFF202020), width: 2.0),
      radius: BorderRadius.vertical(top: Radius.circular(8.0), bottom: Radius.circular(0.0)),
    ),
  ),
);
```

Read each of the eight by eye once. Anything that looks wrong is a codegen bug to fix now, before the fixtures are trusted as the baseline.

- [ ] **Step 6: Prove the generated source compiles**

Run: `cd charts_web && fvm flutter analyze test/codegen/generated`
Expected: no errors. Warnings about an unused import in a fixture are acceptable; **any error means the emitted code does not compile** and the emitter is wrong.

- [ ] **Step 7: Verify the drift guard works**

Temporarily change one emitted string (for example the `valueAxisMaxOver` value in `data_source.dart`), then:

Run: `cd charts_web && fvm flutter test test/codegen/chart_state_source_test.dart`
Expected: FAIL, naming the drifted fixture. Revert the change and confirm it passes again. This is the check that keeps "copy-paste runnable" honest.

- [ ] **Step 8: Commit**

```bash
git add charts_web/lib/codegen charts_web/test/codegen
git commit -m "feat(charts_web): assemble ChartState source with compile-proof fixtures

Generated output for eight presets is committed as real Dart, so flutter
analyze proves the code panel emits something that compiles."
```

---

### Task 13: Wire the code panel

**Files:**
- Modify: `charts_web/lib/ui/playground/code_panel.dart` (whole file)
- Test: `charts_web/test/ui/playground/code_panel_test.dart`

**Interfaces:**
- Consumes: `buildChartStateSource` (Task 12), `CodeBlock` (Task 4), the two presenters.
- Produces: `CodePanel` rendering live generated source.

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/playground/code_panel_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/code_panel.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows generated source and follows presenter changes',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(body: CodePanel()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('BarItemOptions'), findsOneWidget);

    container
        .read(chartStatePresenter)
        .updateItemPainter(SelectedPainter.bubble);
    await tester.pumpAndSettle();

    expect(find.textContaining('BubbleItemOptions'), findsOneWidget);
  });
}
```

`SelectableText.rich` renders one text widget, so `findTextContaining` matches on the assembled spans.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/playground/code_panel_test.dart`
Expected: FAIL — the placeholder panel renders only the title.

- [ ] **Step 3: Write the real panel**

`charts_web/lib/ui/playground/code_panel.dart` (replacing the placeholder):

```dart
import 'package:charts_web/codegen/chart_state_source.dart';
import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Generated Dart source for the current playground configuration.
class CodePanel extends ConsumerWidget {
  const CodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(chartStatePresenter);
    final decorations = ref.watch(chartDecorationsPresenter);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border:
            Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dart source', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Pass this to Chart(state: ...). Needs charts_painter and '
            'material_ui imported.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CodeBlock(
              title: 'ChartState<void>',
              source: buildChartStateSource(state, decorations),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd charts_web && fvm flutter test test/ui/playground/code_panel_test.dart`
Expected: PASS

- [ ] **Step 5: Check it by hand**

Run: `cd charts_web && fvm flutter run -d chrome`
Change the painter, add a decoration, set a gradient. Expected: the source updates on every change, and Copy puts it on the clipboard.

- [ ] **Step 6: Commit**

```bash
git add charts_web/lib/ui/playground charts_web/test/ui/playground
git commit -m "feat(charts_web): live Dart source panel in the playground"
```

---

### Task 14: Curated gallery

A grid of live charts — not screenshots — each with a blurb, tags, a snippet, and where the configuration maps onto presenter state, a jump into the playground.

Removing the old "Showcase" button also removes the last use of the `example` package, so its path dependency goes.

**Files:**
- Create: `charts_web/lib/ui/gallery/gallery_entry.dart`
- Create: `charts_web/lib/ui/gallery/gallery_entries.dart`
- Create: `charts_web/lib/ui/gallery/gallery_screen.dart`
- Create: `charts_web/lib/ui/gallery/gallery_detail.dart`
- Modify: `charts_web/lib/ui/shell/app_shell.dart` (real gallery panel)
- Modify: `charts_web/pubspec.yaml` (drop `example`)
- Test: `charts_web/test/ui/gallery/gallery_entries_test.dart`
- Test: `charts_web/test/ui/gallery/gallery_screen_test.dart`

**Interfaces:**
- Consumes: `SectionCard`, `CodeBlock` (Tasks 3-4), `AppBreakpoint` (Task 2), the presenters (for `applyToPlayground`).
- Produces:
  - `class GalleryEntry { const GalleryEntry({required String id, required String title, required String blurb, required List<String> tags, required Widget Function(BuildContext context) buildChart, required String snippet, void Function(WidgetRef ref)? applyToPlayground}); }`
  - `const List<GalleryEntry> galleryEntries`
  - `const List<String> galleryTags`
  - `class GalleryScreen extends ConsumerWidget`
  - `class GalleryDetail extends ConsumerWidget`

`buildChart` returns a widget rather than a `ChartState` so entries that need a wrapper — the scrollable one needs a `SingleChildScrollView` — fit the same shape.

- [ ] **Step 1: Write the failing tests**

`charts_web/test/ui/gallery/gallery_entries_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('entries have unique ids and non-empty copy', () {
    expect(galleryEntries, hasLength(greaterThanOrEqualTo(12)));

    final ids = galleryEntries.map((entry) => entry.id).toSet();
    expect(ids, hasLength(galleryEntries.length));

    for (final entry in galleryEntries) {
      expect(entry.title, isNotEmpty, reason: entry.id);
      expect(entry.blurb, isNotEmpty, reason: entry.id);
      expect(entry.snippet, contains('ChartState'), reason: entry.id);
      expect(entry.tags, isNotEmpty, reason: entry.id);
    }
  });

  test('every tag is declared in galleryTags', () {
    for (final entry in galleryEntries) {
      for (final tag in entry.tags) {
        expect(galleryTags, contains(tag), reason: '${entry.id} -> $tag');
      }
    }
  });

  testWidgets('every entry builds without throwing', (tester) async {
    for (final entry in galleryEntries) {
      await tester.pumpWidget(MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 240,
            child: Builder(builder: entry.buildChart),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: entry.id);
    }
  });
}
```

`charts_web/test/ui/gallery/gallery_screen_test.dart`:

```dart
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/gallery/gallery_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('filtering by tag narrows the grid', (tester) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: Scaffold(body: GalleryScreen())),
    ));
    await tester.pumpAndSettle();

    expect(find.text(galleryEntries.first.title), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'decoration'));
    await tester.pumpAndSettle();

    final decorationEntries =
        galleryEntries.where((entry) => entry.tags.contains('decoration'));
    for (final entry in decorationEntries) {
      expect(find.text(entry.title), findsOneWidget, reason: entry.id);
    }
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd charts_web && fvm flutter test test/ui/gallery/`
Expected: FAIL — URIs do not exist.

- [ ] **Step 3: Write the entry type**

`charts_web/lib/ui/gallery/gallery_entry.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// One gallery example: a live chart, the copy that explains it, and the
/// snippet that produces it.
class GalleryEntry {
  const GalleryEntry({
    required this.id,
    required this.title,
    required this.blurb,
    required this.tags,
    required this.buildChart,
    required this.snippet,
    this.applyToPlayground,
  });

  final String id;
  final String title;
  final String blurb;
  final List<String> tags;

  /// Builds the live chart. Returns a widget, not a `ChartState`, so entries
  /// needing a wrapper (the scrollable one) fit the same shape.
  final Widget Function(BuildContext context) buildChart;

  final String snippet;

  /// Set only for entries whose configuration the playground can actually
  /// represent. Entries without it show no "Open in playground" action.
  final void Function(WidgetRef ref)? applyToPlayground;
}

const List<String> galleryTags = [
  'bar',
  'bubble',
  'line',
  'stacked',
  'decoration',
  'axis',
  'custom',
  'scroll',
];
```

- [ ] **Step 4: Write the entries**

`charts_web/lib/ui/gallery/gallery_entries.dart`. The series palette is fixed rather than themed, because series colour is data, not chrome; grid and axis colours come from the active scheme so they read correctly in both themes.

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const Color _red = Color(0xFFD8262C);
const Color _sand = Color(0xFFD9A866);
const Color _plum = Color(0xFF916794);
const Color _blue = Color(0xFF6479C3);
const Color _green = Color(0xFF5A8772);

List<ChartItem<void>> _items(List<num> values) =>
    values.map((value) => ChartItem<void>(value.toDouble())).toList();

final List<GalleryEntry> galleryEntries = [
  GalleryEntry(
    id: 'simple-bar',
    title: 'Simple bar chart',
    blurb: 'BarItemOptions with a grid behind it. The shortest useful chart.',
    tags: const ['bar', 'decoration'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 6, 7, 9, 3, 2]),
            valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 2),
          barItemBuilder: _redBar,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            gridColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(
    [4, 6, 3, 6, 7, 9, 3, 2]
        .map((e) => ChartItem<void>(e.toDouble()))
        .toList(),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BarItemOptions(
    padding: EdgeInsets.symmetric(horizontal: 2),
    barItemBuilder: (_) => const BarItem(color: Color(0xFFD8262C)),
  ),
  backgroundDecorations: [
    GridDecoration(showVerticalGrid: false),
  ],
)''',
    applyToPlayground: (ref) {
      ref.read(chartStatePresenter)
        ..updateItemPainter(SelectedPainter.bar)
        ..updateData([_items([4, 6, 3, 6, 7, 9, 3, 2])]);
      ref
          .read(chartDecorationsPresenter)
          .addDecoration(HorizontalAxisDecoration(),
              layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'stacked-bar',
    title: 'Stacked series',
    blurb: 'StackDataStrategy puts every series on top of the previous one.',
    tags: const ['bar', 'stacked'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData(
          [
            _items([3, 5, 2, 4, 6]),
            _items([2, 1, 4, 2, 3]),
            _items([1, 3, 1, 3, 2]),
          ],
          dataStrategy: const StackDataStrategy(),
          valueAxisMaxOver: 2,
        ),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: _seriesBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData(
    [seriesA, seriesB, seriesC],
    dataStrategy: const StackDataStrategy(),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (data) => BarItem(
      color: palette[data.listIndex % palette.length],
    ),
  ),
)''',
    applyToPlayground: (ref) {
      final presenter = ref.read(chartStatePresenter)
        ..updateData([_items([3, 5, 2, 4, 6])]);
      presenter.addDataList(_items([2, 1, 4, 2, 3]));
      presenter.addDataList(_items([1, 3, 1, 3, 2]));
      presenter.updateDataStrategy(const StackDataStrategy());
    },
  ),
  GalleryEntry(
    id: 'grouped-bar',
    title: 'Grouped series',
    blurb: 'DefaultDataStrategy with stacking off draws series side by side.',
    tags: const ['bar', 'stacked'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData(
          [
            _items([3, 5, 2, 4, 6]),
            _items([2, 1, 4, 2, 3]),
          ],
          dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),
          valueAxisMaxOver: 2,
        ),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          multiValuePadding: EdgeInsets.symmetric(horizontal: 1),
          barItemBuilder: _seriesBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData(
    [seriesA, seriesB],
    dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    multiValuePadding: const EdgeInsets.symmetric(horizontal: 1),
    barItemBuilder: (data) => BarItem(
      color: palette[data.listIndex % palette.length],
    ),
  ),
)''',
    applyToPlayground: (ref) {
      final presenter = ref.read(chartStatePresenter)
        ..updateData([_items([3, 5, 2, 4, 6])]);
      presenter.addDataList(_items([2, 1, 4, 2, 3]));
      presenter.updateDataStrategy(
          const DefaultDataStrategy(stackMultipleValues: true));
      presenter.updateStackMultipleValues(false);
    },
  ),
  GalleryEntry(
    id: 'sparkline',
    title: 'Sparkline',
    blurb: 'A line is a decoration. Zero-width items plus SparkLineDecoration.',
    tags: const ['line', 'decoration'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([2, 7, 2, 4, 7, 6, 2, 5, 4]),
            valueAxisMaxOver: 2),
        // BubbleItemOptions has no const constructor, unlike BarItemOptions.
        itemOptions: BubbleItemOptions(
          maxBarWidth: 0,
          minBarWidth: 0,
          bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),
        ),
        backgroundDecorations: [
          SparkLineDecoration(
            fill: true,
            smoothPoints: true,
            lineWidth: 2,
            lineColor: _red,
            gradient: const LinearGradient(
              colors: [Color(0x66D8262C), Color(0x00D8262C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BubbleItemOptions(
    maxBarWidth: 0,
    minBarWidth: 0,
    bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),
  ),
  backgroundDecorations: [
    SparkLineDecoration(
      fill: true,
      smoothPoints: true,
      lineWidth: 2,
      lineColor: Color(0xFFD8262C),
      gradient: LinearGradient(
        colors: [Color(0x66D8262C), Color(0x00D8262C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ],
)''',
    applyToPlayground: (ref) {
      ref.read(chartStatePresenter)
        ..updateData([_items([2, 7, 2, 4, 7, 6, 2, 5, 4])])
        ..updateItemPainter(SelectedPainter.none);
      ref.read(chartDecorationsPresenter).addDecoration(SparkLineDecoration(),
          layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'bubble',
    title: 'Bubble chart',
    blurb: 'BubbleItemOptions draws a point per value instead of a bar.',
    tags: const ['bubble'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(
          [3, 6, 2, 8, 5, 7, 4]
              .map((value) => ChartItem<void>(value.toDouble(),
                  min: value.toDouble()))
              .toList(),
          valueAxisMaxOver: 2,
        ),
        itemOptions: BubbleItemOptions(
          maxBarWidth: 12,
          minBarWidth: 12,
          bubbleItemBuilder: (_) => const BubbleItem(color: _plum),
        ),
        backgroundDecorations: [
          GridDecoration(
            gridColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(
    values.map((v) => ChartItem<void>(v, min: v)).toList(),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BubbleItemOptions(
    maxBarWidth: 12,
    minBarWidth: 12,
    bubbleItemBuilder: (_) => const BubbleItem(color: Color(0xFF916794)),
  ),
  backgroundDecorations: [GridDecoration()],
)''',
    applyToPlayground: (ref) {
      ref.read(chartStatePresenter)
        ..updateItemPainter(SelectedPainter.bubble)
        ..updateMinBarWidth(12)
        ..updateMaxBarWidth(12);
    },
  ),
  GalleryEntry(
    id: 'negative-values',
    title: 'Negative values',
    blurb: 'axisMin opens space below zero; bar radius flips automatically.',
    tags: const ['bar', 'axis'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(
          _items([3, -2, 5, -4, 2, -1, 4]),
          axisMin: -6,
          valueAxisMaxOver: 2,
        ),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 3),
          barItemBuilder: _blueBar,
        ),
        backgroundDecorations: [
          HorizontalAxisDecoration(
            showValues: true,
            axisStep: 3,
            lineColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, axisMin: -6, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    barItemBuilder: (_) => const BarItem(color: Color(0xFF6479C3)),
  ),
  backgroundDecorations: [
    HorizontalAxisDecoration(showValues: true, axisStep: 3),
  ],
)''',
  ),
  GalleryEntry(
    id: 'gradient-bars',
    title: 'Gradient bars',
    blurb: 'Every item accepts a gradient instead of a flat colour.',
    tags: const ['bar'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 7, 3, 8, 5, 6]),
            valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: _gradientBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (_) => const BarItem(
      gradient: LinearGradient(
        colors: [Color(0xFFD8262C), Color(0xFF6479C3)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  ),
)''',
    applyToPlayground: (ref) => ref.read(chartStatePresenter).updateGradient(
          const LinearGradient(
            colors: [_red, _blue],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          0,
        ),
  ),
  GalleryEntry(
    id: 'rounded-bars',
    title: 'Rounded bars',
    blurb: 'BorderRadius per item, with a border side on top.',
    tags: const ['bar'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([5, 8, 4, 6, 9, 3]),
            valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 5),
          barItemBuilder: _roundedBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    barItemBuilder: (_) => const BarItem(
      color: Color(0xFF5A8772),
      radius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
  ),
)''',
    applyToPlayground: (ref) => ref
        .read(chartStatePresenter)
        .updateBarBorderRadius(
            const BorderRadius.vertical(top: Radius.circular(8)), 0,
            forAll: true),
  ),
  GalleryEntry(
    id: 'axis-labels',
    title: 'Labelled axes',
    blurb: 'Both axis decorations with values shown, in the background layer.',
    tags: const ['axis', 'decoration'],
    buildChart: (context) {
      final outline = Theme.of(context).colorScheme.outlineVariant;

      return Chart<void>(
        state: ChartState<void>(
          data: ChartData.fromList(_items([4, 6, 3, 6, 7, 9]),
              valueAxisMaxOver: 2),
          itemOptions: const BarItemOptions(
            padding: EdgeInsets.symmetric(horizontal: 4),
            barItemBuilder: _sandBar,
          ),
          backgroundDecorations: [
            HorizontalAxisDecoration(
                showValues: true, axisStep: 3, lineColor: outline),
            VerticalAxisDecoration(
                showValues: true, axisStep: 1, lineColor: outline),
          ],
        ),
      );
    },
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (_) => const BarItem(color: Color(0xFFD9A866)),
  ),
  backgroundDecorations: [
    HorizontalAxisDecoration(showValues: true, axisStep: 3),
    VerticalAxisDecoration(showValues: true, axisStep: 1),
  ],
)''',
    applyToPlayground: (ref) {
      final decorations = ref.read(chartDecorationsPresenter)
        ..addDecoration(HorizontalAxisDecoration(),
            layer: DecorationLayer.background);
      decorations.addDecoration(VerticalAxisDecoration(),
          layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'target-line',
    title: 'Target line',
    blurb: 'TargetLineDecoration recolours anything above the target.',
    tags: const ['decoration'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 8, 7, 9, 5]),
            valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: _greenBar,
        ),
        foregroundDecorations: [
          TargetLineDecoration(
            target: 7,
            targetLineColor: _red,
            colorOverTarget: _red,
            dashArray: const [4, 4],
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (_) => const BarItem(color: Color(0xFF5A8772)),
  ),
  foregroundDecorations: [
    TargetLineDecoration(
      target: 7,
      targetLineColor: Color(0xFFD8262C),
      colorOverTarget: Color(0xFFD8262C),
      dashArray: [4, 4],
    ),
  ],
)''',
  ),
  GalleryEntry(
    id: 'value-labels',
    title: 'Value labels',
    blurb: 'ValueDecoration prints each value above its item.',
    tags: const ['decoration'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 6, 7]),
            valueAxisMaxOver: 3),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 6),
          barItemBuilder: _plumBar,
        ),
        foregroundDecorations: [
          ValueDecoration(
            textStyle: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
            alignment: Alignment.topCenter,
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 3),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    barItemBuilder: (_) => const BarItem(color: Color(0xFF916794)),
  ),
  foregroundDecorations: [
    ValueDecoration(
      textStyle: Theme.of(context).textTheme.labelSmall!,
      alignment: Alignment.topCenter,
    ),
  ],
)''',
  ),
  GalleryEntry(
    id: 'scrollable',
    title: 'Scrollable chart',
    blurb: 'ScrollSettings fixes how many items are visible; wrap in a scroll '
        'view and the chart sizes itself.',
    tags: const ['bar', 'scroll'],
    buildChart: (context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Chart<void>(
        width: 900,
        state: ChartState<void>(
          data: ChartData.fromList(
            _items([4, 6, 3, 6, 7, 9, 3, 2, 5, 8, 4, 7, 6, 2, 9, 3]),
            valueAxisMaxOver: 2,
          ),
          itemOptions: const BarItemOptions(
            padding: EdgeInsets.symmetric(horizontal: 4),
            barItemBuilder: _redBar,
          ),
          behaviour: const ChartBehaviour(
            scrollSettings: ScrollSettings(visibleItems: 8),
          ),
        ),
      ),
    ),
    snippet: '''SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Chart<void>(
    state: ChartState<void>(
      data: ChartData.fromList(values, valueAxisMaxOver: 2),
      itemOptions: BarItemOptions(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        barItemBuilder: (_) => const BarItem(color: Color(0xFFD8262C)),
      ),
      behaviour: const ChartBehaviour(
        scrollSettings: ScrollSettings(visibleItems: 8),
      ),
    ),
  ),
)''',
  ),
  GalleryEntry(
    id: 'widget-items',
    title: 'Widget items',
    blurb: 'WidgetItemOptions replaces the painter with any widget you like.',
    tags: const ['custom'],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 6, 7]),
            valueAxisMaxOver: 2),
        itemOptions: WidgetItemOptions(
          widgetItemBuilder: (data) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [_blue, _plum],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: WidgetItemOptions(
    widgetItemBuilder: (data) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(
            colors: [Color(0xFF6479C3), Color(0xFF916794)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const SizedBox.expand(),
      ),
    ),
  ),
)''',
    applyToPlayground: (ref) =>
        ref.read(chartStatePresenter).updateItemPainter(SelectedPainter.widget),
  ),
];

// Top-level builders so the const item options above stay const.
BarItem _redBar(ItemBuilderData data) => const BarItem(color: _red);
BarItem _blueBar(ItemBuilderData data) => const BarItem(color: _blue);
BarItem _sandBar(ItemBuilderData data) => const BarItem(color: _sand);
BarItem _plumBar(ItemBuilderData data) => const BarItem(color: _plum);
BarItem _greenBar(ItemBuilderData data) => const BarItem(color: _green);

BarItem _roundedBar(ItemBuilderData data) => const BarItem(
      color: _green,
      radius: BorderRadius.vertical(top: Radius.circular(8)),
    );

BarItem _gradientBar(ItemBuilderData data) => const BarItem(
      gradient: LinearGradient(
        colors: [_red, _blue],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );

const List<Color> _palette = [_red, _sand, _plum, _blue, _green];

BarItem _seriesBar(ItemBuilderData data) =>
    BarItem(color: _palette[data.listIndex % _palette.length]);
```

Two API details that bite here, both verified against `lib/chart/model/theme/item_theme/`:
- `BarItemOptions` and `WidgetItemOptions` have const constructors; **`BubbleItemOptions` does not**. Bubble entries therefore use a plain constructor with an inline closure.
- `BarItemBuilder` is `BarItem Function(ItemBuilderData)` — note the raw type argument — which is why the top-level bar builders take a bare `ItemBuilderData`.

- [ ] **Step 5: Write the grid**

`charts_web/lib/ui/gallery/gallery_screen.dart`:

```dart
import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/gallery/gallery_detail.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final selectedGalleryTagProvider = StateProvider<String?>((ref) => null);

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedTag = ref.watch(selectedGalleryTagProvider);
    final entries = selectedTag == null
        ? galleryEntries
        : galleryEntries
            .where((entry) => entry.tags.contains(selectedTag))
            .toList();

    final columns = switch (context.breakpoint) {
      AppBreakpoint.compact => 1,
      AppBreakpoint.medium => 2,
      AppBreakpoint.expanded => 3,
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Gallery', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Every chart below is live, not a screenshot. Open one for its source.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: galleryTags
              .map((tag) => FilterChip(
                    label: Text(tag),
                    selected: selectedTag == tag,
                    onSelected: (selected) => ref
                        .read(selectedGalleryTagProvider.notifier)
                        .state = selected ? tag : null,
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) => _GalleryCard(entry: entries[index]),
        ),
      ],
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.entry});

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => GalleryDetail(entry: entry),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Builder(builder: entry.buildChart)),
              const SizedBox(height: 12),
              Text(entry.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                entry.blurb,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Write the detail view**

`charts_web/lib/ui/gallery/gallery_detail.dart`:

```dart
import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class GalleryDetail extends ConsumerWidget {
  const GalleryDetail({super.key, required this.entry});

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final apply = entry.applyToPlayground;

    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(entry.blurb, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                entry.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 320, child: Builder(builder: entry.buildChart)),
          const SizedBox(height: 24),
          CodeBlock(title: 'ChartState<void>', source: entry.snippet),
          if (apply != null) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                icon: const Icon(Icons.tune),
                label: const Text('Open in playground'),
                onPressed: () {
                  apply(ref);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

Popping returns to the gallery panel; the rail is still on Gallery, so tell the user where the config went by leaving the rail to them — or select Playground first. Keep it simple: pop only. The playground now holds the applied configuration when they switch to it.

- [ ] **Step 7: Put the gallery in the shell and drop the `example` dependency**

In `charts_web/lib/ui/shell/app_shell.dart`, replace `const _Placeholder(label: 'Gallery')` with `const GalleryScreen()` and add the import.

In `charts_web/pubspec.yaml`, delete:

```yaml
  example:
    path: ../example
```

Run: `cd charts_web && fvm flutter pub get && grep -rn "package:example" lib test`
Expected: resolves; grep prints nothing.

- [ ] **Step 8: Run the tests to verify they pass**

Run: `cd charts_web && fvm flutter analyze | tail -1 && fvm flutter test`
Expected: analyzer count at or below baseline; all tests pass, including the gallery entry and grid tests.

- [ ] **Step 9: Commit**

```bash
git add -A charts_web
git commit -m "feat(charts_web): curated gallery of live charts

Replaces the Showcase button into the example app, so the example path
dependency is no longer needed."
```

---

### Task 15: Concepts panel

Four sections teaching the model the playground assumes: `ChartState`, `ChartData` + `DataStrategy`, `ItemOptions`, `Decorations`. Each is a short explanation, a live mini-chart proving it, and a snippet.

**Files:**
- Create: `charts_web/lib/ui/concepts/concepts_screen.dart`
- Modify: `charts_web/lib/ui/shell/app_shell.dart` (real concepts panel)
- Test: `charts_web/test/ui/concepts/concepts_screen_test.dart`

**Interfaces:**
- Consumes: `SectionCard` (Task 3), `CodeBlock` (Task 4).
- Produces: `class ConceptsScreen extends StatelessWidget`.

- [ ] **Step 1: Write the failing test**

`charts_web/test/ui/concepts/concepts_screen_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/concepts/concepts_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders all four concepts with a live chart each',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(body: ConceptsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ChartState'), findsOneWidget);
    expect(find.text('ChartData and DataStrategy'), findsOneWidget);
    expect(find.text('ItemOptions'), findsOneWidget);
    expect(find.text('Decorations'), findsOneWidget);
    expect(find.byType(Chart<void>), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd charts_web && fvm flutter test test/ui/concepts/concepts_screen_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the concepts screen**

`charts_web/lib/ui/concepts/concepts_screen.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:material_ui/material_ui.dart';

const Color _red = Color(0xFFD8262C);
const Color _blue = Color(0xFF6479C3);

List<ChartItem<void>> _items(List<num> values) =>
    values.map((value) => ChartItem<void>(value.toDouble())).toList();

class ConceptsScreen extends StatelessWidget {
  const ConceptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('How charts_painter fits together',
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Four pieces. Once these click, every option in the playground has an '
          'obvious home.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _Concept(
          title: 'ChartState',
          body: 'The single object a chart renders. It holds the data, the item '
              'options, the behaviour, and two lists of decorations. Build one '
              'and hand it to Chart or AnimatedChart.',
          snippet: '''Chart<void>(
  state: ChartState<void>(
    data: ChartData.fromList(values),
    itemOptions: BarItemOptions(
      barItemBuilder: (_) => const BarItem(color: Color(0xFFD8262C)),
    ),
  ),
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData.fromList(_items([4, 6, 3, 6, 7]),
                  valueAxisMaxOver: 2),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _redBar,
              ),
            ),
          ),
        ),
        _Concept(
          title: 'ChartData and DataStrategy',
          body: 'Data is a list of lists: one inner list per series. The '
              'strategy decides what happens when several series share a slot '
              '— stacked on top of each other, or grouped side by side.',
          snippet: '''ChartData(
  [seriesA, seriesB],
  dataStrategy: const StackDataStrategy(),
  valueAxisMaxOver: 2,
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData(
                [
                  _items([3, 5, 2, 4]),
                  _items([2, 1, 4, 2]),
                ],
                dataStrategy: const StackDataStrategy(),
                valueAxisMaxOver: 2,
              ),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _twoSeriesBar,
              ),
            ),
          ),
        ),
        _Concept(
          title: 'ItemOptions',
          body: 'How one data point is drawn. BarItemOptions and '
              'BubbleItemOptions cover the common cases; the builder receives '
              'the item, its index and its series index, so colour, gradient, '
              'border and radius can vary per point. WidgetItemOptions hands '
              'the whole job to a widget.',
          snippet: '''BarItemOptions(
  maxBarWidth: 20,
  barItemBuilder: (data) => BarItem(
    color: data.item.max! > 5 ? Colors.red : Colors.blue,
    radius: const BorderRadius.vertical(top: Radius.circular(6)),
  ),
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData.fromList(_items([4, 6, 3, 7, 5]),
                  valueAxisMaxOver: 2),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _thresholdBar,
              ),
            ),
          ),
        ),
        _Concept(
          title: 'Decorations',
          body: 'Everything that is not an item: grids, axes, sparklines, '
              'target lines, value labels, or any widget. Background '
              'decorations paint under the items, foreground over them, and '
              'the same decoration can sit in either list.',
          snippet: '''ChartState<void>(
  data: ChartData.fromList(values),
  itemOptions: BarItemOptions(...),
  backgroundDecorations: [GridDecoration()],
  foregroundDecorations: [
    TargetLineDecoration(target: 6, dashArray: [4, 4]),
  ],
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData.fromList(_items([4, 6, 3, 7, 5]),
                  valueAxisMaxOver: 2),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _blueBar,
              ),
              backgroundDecorations: [GridDecoration(gridColor: outline)],
              foregroundDecorations: [
                TargetLineDecoration(
                  target: 6,
                  targetLineColor: _red,
                  colorOverTarget: _red,
                  dashArray: const [4, 4],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Concept extends StatelessWidget {
  const _Concept({
    required this.title,
    required this.body,
    required this.snippet,
    required this.chart,
  });

  final String title;
  final String body;
  final String snippet;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        title: title,
        collapsible: false,
        children: [
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          chart,
          const SizedBox(height: 16),
          CodeBlock(source: snippet),
        ],
      ),
    );
  }
}

BarItem _redBar(ItemBuilderData data) => const BarItem(color: _red);
BarItem _blueBar(ItemBuilderData data) => const BarItem(color: _blue);

BarItem _twoSeriesBar(ItemBuilderData data) =>
    BarItem(color: data.listIndex == 0 ? _red : _blue);

BarItem _thresholdBar(ItemBuilderData data) => BarItem(
      color: (data.item.max ?? 0) > 5 ? _red : _blue,
      radius: const BorderRadius.vertical(top: Radius.circular(6)),
    );
```

- [ ] **Step 4: Put it in the shell**

In `charts_web/lib/ui/shell/app_shell.dart`, replace `const _Placeholder(label: 'Concepts')` with `const ConceptsScreen()`, add the import, and delete the now-unused `_Placeholder` class.

- [ ] **Step 5: Run test to verify it passes**

Run: `cd charts_web && fvm flutter test test/ui/concepts/concepts_screen_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add charts_web/lib/ui charts_web/test/ui/concepts
git commit -m "feat(charts_web): concepts panel explaining the library model"
```

---

### Task 16: Web shell

The current `index.html` carries `description="A new Flutter project."` and a hand-rolled service-worker bootstrap that predates the modern template. Flutter 3.47.0's template is a single `flutter_bootstrap.js` tag.

**Files:**
- Modify: `charts_web/web/index.html` (whole file)
- Modify: `charts_web/web/style.css` (whole file)
- Modify: `charts_web/web/manifest.json` (name and description)

**Interfaces:**
- Consumes: nothing.
- Produces: nothing consumed by other tasks.

- [ ] **Step 1: Replace `index.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <!-- Served from a GitHub Pages subpath; replaced by --base-href at build time. -->
  <base href="/flutter-charts/">

  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description"
        content="Interactive playground and live gallery for charts_painter, a highly customizable Flutter charts library built with custom painters.">

  <meta name="theme-color" content="#FFF8F7" media="(prefers-color-scheme: light)">
  <meta name="theme-color" content="#1A1112" media="(prefers-color-scheme: dark)">

  <meta property="og:type" content="website">
  <meta property="og:title" content="charts_painter playground">
  <meta property="og:description"
        content="Build a Flutter chart in the browser and copy the Dart that produces it.">
  <meta property="og:image" content="icons/chart_image.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="charts_painter playground">
  <meta name="twitter:description"
        content="Build a Flutter chart in the browser and copy the Dart that produces it.">
  <meta name="twitter:image" content="icons/chart_image.png">

  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="charts_painter">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="manifest" href="manifest.json">
  <link rel="stylesheet" href="style.css">

  <title>charts_painter playground</title>
</head>
<body>
<div class="boot" id="boot">
  <div class="boot__mark">charts_painter</div>
  <div class="boot__bar"><span></span></div>
</div>

<script src="flutter_bootstrap.js" async></script>
<script>
  // The engine dispatches this once the first frame is on screen.
  window.addEventListener('flutter-first-frame', function () {
    var boot = document.getElementById('boot');
    if (!boot) return;
    boot.classList.add('boot--done');
    window.setTimeout(function () { boot.remove(); }, 400);
  });
</script>
</body>
</html>
```

- [ ] **Step 2: Replace `style.css`**

```css
:root {
  --boot-bg: #FFF8F7;
  --boot-fg: #1A1112;
  --boot-track: rgba(26, 17, 18, 0.12);
  --boot-accent: #D8262C;
}

@media (prefers-color-scheme: dark) {
  :root {
    --boot-bg: #1A1112;
    --boot-fg: #F5DDDC;
    --boot-track: rgba(245, 221, 220, 0.16);
  }
}

html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  background: var(--boot-bg);
}

.boot {
  position: fixed;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
  background: var(--boot-bg);
  color: var(--boot-fg);
  font: 500 16px/1.4 system-ui, -apple-system, "Segoe UI", sans-serif;
  letter-spacing: 0.02em;
  transition: opacity 320ms ease;
  z-index: 10;
}

.boot--done {
  opacity: 0;
  pointer-events: none;
}

.boot__bar {
  width: 180px;
  height: 3px;
  border-radius: 999px;
  background: var(--boot-track);
  overflow: hidden;
}

.boot__bar span {
  display: block;
  width: 40%;
  height: 100%;
  border-radius: 999px;
  background: var(--boot-accent);
  animation: boot-slide 1.1s ease-in-out infinite;
}

@keyframes boot-slide {
  0%   { transform: translateX(-100%); }
  100% { transform: translateX(250%); }
}

@media (prefers-reduced-motion: reduce) {
  .boot__bar span { animation: none; width: 100%; }
}
```

- [ ] **Step 3: Fix the manifest**

In `charts_web/web/manifest.json`, set `name` to `charts_painter playground`, `short_name` to `charts_painter`, and `description` to the same sentence used in the `<meta name="description">`. Leave the icon entries alone.

- [ ] **Step 4: Verify the build and the loader**

Run: `cd charts_web && fvm flutter build web --base-href /flutter-charts/`
Expected: build succeeds and `build/web/flutter_bootstrap.js` exists.

Run: `cd charts_web && fvm flutter run -d chrome`
Expected: the boot screen shows the wordmark and a moving bar, then fades once the app paints. Toggle the OS to dark mode and reload: the boot background follows.

- [ ] **Step 5: Commit**

```bash
git add charts_web/web
git commit -m "feat(charts_web): modern web shell with themed loading state

Replaces the hand-rolled service worker bootstrap with the current
flutter_bootstrap.js template and fixes the placeholder meta description."
```

---

### Task 17: Final verification

**Files:**
- Modify: `charts_web/test/widget_test.dart` (replaced with a real smoke test)
- Modify: `charts_web/README.md`

**Interfaces:**
- Consumes: everything.
- Produces: nothing.

- [ ] **Step 1: Replace the generated counter test**

`charts_web/test/widget_test.dart`:

```dart
import 'package:charts_painter/chart.dart';
import 'package:charts_web/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the app boots into the playground with a chart',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: ChartsWebApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(AnimatedChart<void>), findsOneWidget);
    expect(find.textContaining('ChartState<void>'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every destination opens without throwing', (tester) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: ChartsWebApp()));
    await tester.pumpAndSettle();

    for (final label in ['Gallery', 'Concepts', 'Playground']) {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }
  });
}
```

- [ ] **Step 2: Run the whole suite**

Run: `cd charts_web && fvm flutter test`
Expected: every test passes. Record the count.

- [ ] **Step 3: Run the analyzer and compare to the baseline**

Run: `cd charts_web && fvm flutter analyze`
Expected: well below the 68-issue baseline recorded in Task 0. The only `deprecated_member_use` that should remain is the `MaterialUiCompatibilityBridge` use, which carries its explaining ignore. Fix anything else that appears.

- [ ] **Step 4: Prove the generated source still compiles**

Run: `cd charts_web && fvm flutter analyze test/codegen/generated`
Expected: no errors.

- [ ] **Step 5: Check the three breakpoints and both themes by hand**

Run: `cd charts_web && fvm flutter run -d chrome`

Walk this list and fix what looks wrong:
- Resize past 1400, between 800 and 1400, and below 800. Confirm the code pane is inline, then a sheet, and that below 800 the chart sits above the options.
- Toggle the theme control three times (system, light, dark). Confirm no hardcoded light-only surface appears, especially in the dialogs and the code block.
- Add every decoration type, set a gradient and a border radius, switch painters. Confirm the code panel tracks each change and the chart never throws.
- Open a gallery entry, press "Open in playground", switch to Playground, and confirm the configuration arrived.

- [ ] **Step 6: Update the README**

Replace `charts_web/README.md` with:

~~~~markdown
# charts_web

The showcase site for [`charts_painter`](https://pub.dev/packages/charts_painter).

Three panels, switched from the navigation rail:

- **Playground** — build a chart by hand and read the Dart that produces it. The
  source panel regenerates on every change and is copy-paste runnable.
- **Gallery** — around a dozen live examples, each with its source. Every chart
  on the page is a real chart, not a screenshot.
- **Concepts** — what `ChartState`, `ChartData`, `ItemOptions` and decorations
  each do, with a live chart per idea.

## Running it

```sh
fvm flutter run -d chrome
```

## Building for GitHub Pages

The site is served from a subpath, so the base href matters:

```sh
fvm flutter build web --base-href /flutter-charts/
```

## Generated code fixtures

The playground's source panel is backed by `lib/codegen/`. Its output for eight
preset configurations is committed under `test/codegen/generated/` as real Dart,
so `fvm flutter analyze` proves the generated code compiles. After changing an
emitter, regenerate and review the diff:

```sh
UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
```

A drifted fixture fails the suite rather than silently changing what users copy.

## Material

This app uses [`material_ui`](https://pub.dev/packages/material_ui), the
standalone Material package, not `package:flutter/material.dart`.
`MaterialUiCompatibilityBridge` in `main.dart` exists only because
`flex_color_picker` still imports the legacy library; remove it when that
changes.
~~~~

- [ ] **Step 7: Commit**

```bash
git add charts_web/test/widget_test.dart charts_web/README.md
git commit -m "test(charts_web): smoke tests for the shell and every destination"
```

- [ ] **Step 8: Do not push**

The branch stays local. Report the final analyzer count, test count, and anything left open.

---

## Follow-ups, deliberately out of scope

- `charts_painter` itself still imports `package:flutter/material.dart` (`lib/chart.dart:11`). It only needs `Colors`, `TextStyle` and `BorderSide`, so migrating it to `material_ui` — or better, to `package:flutter/painting.dart` plus its own colour constants — would let consumers drop the legacy library entirely. Separate spec.
- `flex_color_picker` is the only reason `MaterialUiCompatibilityBridge` exists here. When it migrates, delete the bridge and its ignore.
- Gallery snippets are hand-written beside their live builders, so the two can drift. The compile-proof trick used for playground codegen does not apply, because these are literal source rather than generated. If they drift often, the fix is to generate gallery snippets from the builders — a bigger change than this plan warrants.
- Theme choice is not persisted across reloads; that needs a storage dependency.
