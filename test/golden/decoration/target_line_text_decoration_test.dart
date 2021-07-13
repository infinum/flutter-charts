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
          TargetLineLegendDecoration(
            legendTarget: 4.0,
            legendDescription: 'Target',
            legendStyle: defaultTextStyle,
          )
        ]),
      )
      ..addScenario(
        'Big',
        getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(target: 4),
          TargetLineLegendDecoration(
            legendTarget: 4.0,
            legendDescription: 'Target',
            legendStyle: defaultTextStyle.copyWith(fontSize: 36.0),
          )
        ]),
      )
      ..addScenario(
        'with padding',
        getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(target: 4),
          TargetLineLegendDecoration(
            legendTarget: 4.0,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            legendDescription: 'Target',
            legendStyle: defaultTextStyle,
          )
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(),
        surfaceSize: const Size(1400, 330), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'target_line_text_decoration_golden');
  });
}
