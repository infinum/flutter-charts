import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Horizontal decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(),
        ]),
      )
      ..addScenario(
        'Show values on right',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
              showValues: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      )
      ..addScenario(
        'Show values on left',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
              showValues: true,
              legendPosition: HorizontalLegendPosition.start,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      )
      ..addScenario(
        'Increase steps',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
              showValues: true,
              axisStep: 2.0,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      )
      ..addScenario(
        'Show dashed lines',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
            showValues: true,
            dashArray: [10, 10],
            legendFontStyle: defaultTextStyle,
            valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      )
      ..addScenario(
        'End lines with chart',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
              showValues: true,
              endWithChart: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 660), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'horizontal_decoration_golden');
  });
}