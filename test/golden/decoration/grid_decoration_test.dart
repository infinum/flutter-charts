import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Grid decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(),
        ]),
      )
      ..addScenario(
        'Show horizontal values',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: false,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
          ),
        ]),
      )
      ..addScenario(
        'Show vertical values',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: false,
            showVerticalValues: true,
            textStyle: defaultTextStyle,
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      )
      ..addScenario(
        'Show all values',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      )
      ..addScenario(
        'Show all values flipped',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            horizontalLegendPosition: HorizontalLegendPosition.start,
            verticalLegendPosition: VerticalLegendPosition.top,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      )
      ..addScenario(
        'Show all values with dashed lines',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            dashArray: [10, 10],
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      )
      ..addScenario(
        'Increase vertical step',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            verticalAxisStep: 4,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      )
      ..addScenario(
        'Increase grid width',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            gridWidth: 4.0,
          ),
        ]),
      )
      ..addScenario(
        'End lines with chart',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            endWithChartVertical: true,
            endWithChartHorizontal: true,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 1000), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'grid_decoration_golden');
  });
}
