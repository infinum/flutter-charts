// GENERATED -- do not edit by hand.
// Regenerate with:
//   UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
// Committed so `fvm flutter analyze` proves the generated source compiles.

import 'package:charts_painter/chart.dart';
import 'package:material_ui/material_ui.dart';

ChartState<void> fixture07BothAxes() => ChartState<void>(
  data: ChartData(
    [
      [4.0, 6.0, 3.0, 6.0, 7.0, 9.0, 3.0, 2.0].map((e) => ChartItem<void>(e)).toList(),
    ],
    dataStrategy: const StackDataStrategy(),
    valueAxisMaxOver: 2.0,
  ),
  itemOptions: BarItemOptions(
    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
    barItemBuilder: (data) => BarItem(
      color: Color(0xFFD8555F),
    ),
  ),
  backgroundDecorations: [
    HorizontalAxisDecoration(
      lineColor: Color(0xFF9E9E9E),
      textScale: 1.2,
    ),
    VerticalAxisDecoration(
      lineColor: Color(0xFF9E9E9E),
      textScale: 1.2,
    ),
  ],
);
