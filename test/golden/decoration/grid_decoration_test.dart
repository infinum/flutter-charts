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

  goldenTest('grid_decoration_golden', fileName: 'grid_decoration_golden', builder: () {
    return GoldenTestGroup(children: [
      GoldenTestScenario(
        name: 'Default',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(),
        ]),
      ),
      GoldenTestScenario(
        name: 'Show horizontal values',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: false,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Show vertical values',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: false,
            showVerticalValues: true,
            textStyle: defaultTextStyle,
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Show all values',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      ),
      GoldenTestScenario(
          name: 'Show all values flipped',
          child: getDefaultChart(backgroundDecorations: [
            GridDecoration(
              showHorizontalValues: true,
              showVerticalValues: true,
              horizontalLegendPosition: HorizontalLegendPosition.start,
              verticalLegendPosition: VerticalLegendPosition.top,
              textStyle: defaultTextStyle,
              horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
              verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            ),
          ])),
      GoldenTestScenario(
        name: 'Show all values with dashed lines',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            dashArray: [10, 10],
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Increase vertical step',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            showHorizontalValues: true,
            showVerticalValues: true,
            verticalAxisStep: 4,
            verticalTextAlign: TextAlign.start,
            textStyle: defaultTextStyle,
            horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
            verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Increase grid width',
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            gridWidth: 4.0,
          ),
        ]),
      ),
      GoldenTestScenario(
          name: 'End lines with chart',
          child: getDefaultChart(backgroundDecorations: [
            GridDecoration(
              showHorizontalValues: true,
              showVerticalValues: true,
              endWithChartVertical: true,
              endWithChartHorizontal: true,
              textStyle: defaultTextStyle,
              horizontalValuesPadding: const EdgeInsets.only(right: 8.0, left: 8.0),
              verticalValuesPadding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            ),
          ])),
    ]);
  });
}
