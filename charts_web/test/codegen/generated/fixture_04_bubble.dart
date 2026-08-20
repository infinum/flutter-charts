// GENERATED -- do not edit by hand.
// Regenerate with:
//   UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
// Committed so `fvm flutter analyze` proves the generated source compiles.

import 'package:charts_painter/chart.dart';
import 'package:material_ui/material_ui.dart';

ChartState<void> fixture04Bubble() => ChartState<void>(
  data: ChartData(
    [
      [4.0, 6.0, 3.0, 6.0, 7.0, 9.0, 3.0, 2.0].map((e) => ChartItem<void>(e)).toList(),
    ],
    dataStrategy: const StackDataStrategy(),
    valueAxisMaxOver: 2.0,
  ),
  itemOptions: BubbleItemOptions(
    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
    maxBarWidth: 10.0,
    minBarWidth: 6.0,
    bubbleItemBuilder: (data) => BubbleItem(
      color: Color(0xFFD8555F),
    ),
  ),
);
