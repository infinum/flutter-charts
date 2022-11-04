import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Border decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(
          backgroundDecorations: [
            BorderDecoration(),
          ],
        ),
      )
      ..addScenario(
        'Increase width',
        getDefaultChart(
          backgroundDecorations: [
            BorderDecoration(
              borderWidth: 6,
            ),
          ],
        ),
      )
      ..addScenario(
        'End with chart',
        getDefaultChart(
          backgroundDecorations: [
            BorderDecoration(
              endWithChart: true,
            ),
          ],
        ),
      )
      ..addScenario(
        'Just vertical',
        getDefaultChart(
          backgroundDecorations: [
            BorderDecoration(
              sidesWidth: const Border.symmetric(
                vertical: BorderSide(),
              ),
            ),
          ],
        ),
      )
      ..addScenario(
        'Just horizontal',
        getDefaultChart(
          backgroundDecorations: [
            BorderDecoration(
              sidesWidth: const Border.symmetric(
                horizontal: BorderSide(),
              ),
            ),
          ],
        ),
      )
      ..addScenario(
        'All different',
        getDefaultChart(
          backgroundDecorations: [
            BorderDecoration(
              sidesWidth: const Border(
                top: BorderSide(width: 2, color: Colors.red),
                bottom: BorderSide(width: 4, color: Colors.yellow),
                left: BorderSide(width: 2, color: Colors.green),
                right: BorderSide(width: 4),
              ),
            ),
          ],
        ),
      );
    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1400, 660),
      textScaleSize: 1.4,
    );
    await screenMatchesGolden(tester, 'border_decoration_golden');
  });
}
