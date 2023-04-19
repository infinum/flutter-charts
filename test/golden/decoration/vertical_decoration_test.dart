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

  goldenTest('Vertical decoration', fileName: 'vertical_decoration_golden',
      builder: () {
    return GoldenTestGroup(children: [
      GoldenTestScenario(
        name: 'Default',
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(),
        ]),
      ),
      GoldenTestScenario(
        name: 'Show values on bottom',
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(
              showValues: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      ),
      GoldenTestScenario(
        name: 'Show values on top',
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(
              showValues: true,
              legendPosition: VerticalLegendPosition.top,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      ),
      GoldenTestScenario(
        name: 'Increase steps',
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(
              showValues: true,
              axisStep: 2.0,
              valuesAlign: TextAlign.start,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      ),
      GoldenTestScenario(
        name: 'Show dashed lines',
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(
              showValues: true,
              dashArray: [10, 10],
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      ),
      GoldenTestScenario(
        name: 'End lines with chart',
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(
              showValues: true,
              endWithChart: true,
              legendFontStyle: defaultTextStyle,
              valuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0)),
        ]),
      )
    ]);
  });
}
