import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Target area decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(
          backgroundDecorations: [
            TargetAreaDecoration(
              targetMax: 7,
              targetMin: 4,
            ),
          ],
        ),
      )
      ..addScenario(
        'Dashed',
        getDefaultChart(
          backgroundDecorations: [
            TargetAreaDecoration(
              targetMax: 7,
              targetMin: 4,
              dashArray: [20, 10],
            ),
          ],
        ),
      )
      ..addScenario(
        'Background color',
        getDefaultChart(
          backgroundDecorations: [
            TargetAreaDecoration(
              targetMax: 7,
              targetMin: 4,
              targetAreaFillColor: Colors.red.withOpacity(0.5),
            ),
          ],
        ),
      )
      ..addScenario(
        'Radius',
        getDefaultChart(
          backgroundDecorations: [
            TargetAreaDecoration(
              targetMax: 7,
              targetMin: 4,
              targetAreaRadius: BorderRadius.circular(24.0),
            ),
          ],
        ),
      )
      ..addScenario(
        'Line width',
        getDefaultChart(
          backgroundDecorations: [
            TargetAreaDecoration(
              targetMax: 7,
              targetMin: 4,
              lineWidth: 6.0,
            ),
          ],
        ),
      )
      ..addScenario(
        'All',
        getDefaultChart(
          backgroundDecorations: [
            TargetAreaDecoration(
              targetMax: 7,
              targetMin: 4,
              targetAreaRadius: BorderRadius.circular(24.0),
              lineWidth: 6.0,
              dashArray: [20, 10],
              targetAreaFillColor: Colors.red.withOpacity(0.5),
            ),
          ],
        ),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 660), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'target_area_decoration_golden');
  });
}
