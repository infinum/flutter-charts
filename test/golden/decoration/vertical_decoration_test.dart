import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Vertical decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(
          backgroundDecorations: [
            VerticalAxisDecoration(),
          ],
        ),
      )
      ..addScenario(
        'Show values on bottom',
        getDefaultChart(
          backgroundDecorations: [
            VerticalAxisDecoration(
              showValues: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8, bottom: 4),
            ),
          ],
        ),
      )
      ..addScenario(
        'Show values on top',
        getDefaultChart(
          backgroundDecorations: [
            VerticalAxisDecoration(
              showValues: true,
              legendPosition: VerticalLegendPosition.top,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8, bottom: 4),
            ),
          ],
        ),
      )
      ..addScenario(
        'Increase steps',
        getDefaultChart(
          backgroundDecorations: [
            VerticalAxisDecoration(
              showValues: true,
              axisStep: 2,
              valuesAlign: TextAlign.start,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8, bottom: 4),
            ),
          ],
        ),
      )
      ..addScenario(
        'Show dashed lines',
        getDefaultChart(
          backgroundDecorations: [
            VerticalAxisDecoration(
              showValues: true,
              dashArray: [10, 10],
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8, bottom: 4),
            ),
          ],
        ),
      )
      ..addScenario(
        'End lines with chart',
        getDefaultChart(
          backgroundDecorations: [
            VerticalAxisDecoration(
              showValues: true,
              endWithChart: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8, bottom: 4),
            ),
          ],
        ),
      );
    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1400, 660),
      textScaleSize: 1.4,
    );
    await screenMatchesGolden(tester, 'vertical_decoration_golden');
  });
}
