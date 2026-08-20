// GENERATED -- do not edit by hand.
// Regenerate with:
//   UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
// Committed so `fvm flutter analyze` proves the generated source compiles.

import 'package:charts_painter/chart.dart';
import 'package:material_ui/material_ui.dart';

ChartState<void> fixture08WidgetEverything() => ChartState<void>(
  data: ChartData(
    [
      [4.0, 6.0, 3.0, 6.0, 7.0, 9.0, 3.0, 2.0].map((e) => ChartItem<void>(e)).toList(),
    ],
    dataStrategy: const StackDataStrategy(),
    valueAxisMaxOver: 2.0,
  ),
  itemOptions: WidgetItemOptions(
    // Any widget works here. This demo draws an image; see
    // charts_web/lib/ui/playground/options/futurama_bar_widget.dart
    widgetItemBuilder: (data) => DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFFD8262C),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: const SizedBox.expand(),
    ),
  ),
  foregroundDecorations: [
    WidgetDecoration(
      // This playground draws a target line here.
      // A widget decoration can return any widget; the demo builds
      // are in charts_web/lib/ui/playground/decorations/presenters/
      // decorations_widget_presenter.dart
      widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF2196F3), width: 3.0),
          ),
          child: const SizedBox.expand(),
        );
      },
    ),
  ],
);
