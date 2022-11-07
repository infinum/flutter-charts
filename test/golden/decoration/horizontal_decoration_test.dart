import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  goldenTest('horizontal_decoartion', fileName: 'horizontal_decoration_golden', builder: () {
    return GoldenTestGroup(children: [
      GoldenTestScenario(
        name: 'Default',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Show values on right',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
                showValues: true,
                legendFontStyle: defaultTextStyle,
                valuesPadding: const EdgeInsets.only(right: 8.0, left: 4.0)),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Show values on left',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
                showValues: true,
                legendPosition: HorizontalLegendPosition.start,
                legendFontStyle: defaultTextStyle,
                valuesPadding: const EdgeInsets.only(right: 8.0, left: 4.0)),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Increase steps',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
                showValues: true,
                axisStep: 2.0,
                legendFontStyle: defaultTextStyle,
                valuesPadding: const EdgeInsets.only(right: 8.0, left: 4.0)),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'End lines with chart',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
                showValues: true,
                endWithChart: true,
                legendFontStyle: defaultTextStyle,
                valuesPadding: const EdgeInsets.only(right: 8.0, left: 4.0)),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Show top value',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
              showValues: true,
              endWithChart: true,
              showTopValue: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(right: 8.0, left: 4.0),
            ),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Show dashed lines',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
              showValues: true,
              dashArray: [10, 10],
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(right: 8.0, left: 4.0),
            ),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Lines only on top 3 values',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
              showLineForValue: (value) => [6, 8, 7].contains(value),
              lineWidth: 3.0,
            ),
          ],
        ),
      ),
      GoldenTestScenario(
        name: 'Change color',
        child: getDefaultChart(
          backgroundDecorations: [
            HorizontalAxisDecoration(
              lineColor: Colors.red,
            ),
          ],
        ),
      ),
    ]);
  });
}
