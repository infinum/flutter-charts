# charts_web

The showcase site for [`charts_painter`](https://pub.dev/packages/charts_painter).

Three panels, switched from the navigation rail:

- **Playground** — build a chart by hand and read the Dart that produces it. The
  source panel regenerates on every change and is copy-paste runnable.
- **Gallery** — a dozen live examples, each with its source. Every chart on the
  page is a real chart, not a screenshot.
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
changes. The one file allowed to import the legacy library is
`test/ui/common/dialog/color_picker_dialog_test.dart`, which tests that
boundary.
