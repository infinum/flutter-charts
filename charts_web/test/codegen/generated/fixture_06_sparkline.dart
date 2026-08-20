// GENERATED -- do not edit by hand.
// Regenerate with:
//   UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
// Committed so `fvm flutter analyze` proves the generated source compiles.

import 'package:charts_painter/chart.dart';
import 'package:material_ui/material_ui.dart';

ChartState<void> fixture06Sparkline() => ChartState<void>(
  data: ChartData(
    [
      [4.0, 6.0, 3.0, 6.0, 7.0, 9.0, 3.0, 2.0].map((e) => ChartItem<void>(e)).toList(),
    ],
    dataStrategy: const StackDataStrategy(),
    valueAxisMaxOver: 2.0,
  ),
  itemOptions: BubbleItemOptions(
    bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),
    maxBarWidth: 0.0,
    minBarWidth: 0.0,
  ),
  foregroundDecorations: [
    SparkLineDecoration(
      fill: true,
      smoothPoints: true,
      lineColor: Color(0xFFD8555F),
      lineWidth: 2.0,
      gradient: LinearGradient(colors: [Color(0x66D8262C), Color(0x00D8262C)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    ),
  ],
);
