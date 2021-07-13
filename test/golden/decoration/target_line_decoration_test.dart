import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Target line decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(target: 4),
        ]),
      )
      ..addScenario(
        'Thick',
        getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(target: 4, lineWidth: 5.0),
        ]),
      )
      ..addScenario(
        'Dashed',
        getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(target: 4, lineWidth: 3.0, dashArray: [20, 10]),
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(),
        surfaceSize: const Size(1400, 330), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'target_line_decoration_golden');
  });
}
