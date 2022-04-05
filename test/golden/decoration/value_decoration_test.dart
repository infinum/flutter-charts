import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Value decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(backgroundDecorations: [
          ValueDecoration(
            textStyle: defaultTextStyle,
          ),
        ]),
      )
      ..addScenario(
        'Align at bottom',
        getDefaultChart(backgroundDecorations: [
          ValueDecoration(
            textStyle: defaultTextStyle,
            alignment: Alignment.bottomCenter,
          ),
        ]),
      )
      ..addScenario(
        'Change label',
        getDefaultChart(backgroundDecorations: [
          ValueDecoration(
            labelGenerator: (item) => '<${item.max}>',
            textStyle: defaultTextStyle,
            alignment: Alignment.bottomCenter,
          ),
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(),
        surfaceSize: const Size(1400, 330), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'value_decoration_golden');
  });
}
