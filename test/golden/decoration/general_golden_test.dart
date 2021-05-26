import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('General decorations test', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Horizontal decoration',
        getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(),
        ]),
      )
      ..addScenario(
        'Vertical decoration',
        getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(),
        ]),
      )
      ..addScenario(
        'Grid decoration',
        getDefaultChart(backgroundDecorations: [
          GridDecoration(),
        ]),
      )
      ..addScenario(
        'Border decoration',
        getDefaultChart(backgroundDecorations: [
          BorderDecoration(),
        ]),
      )
      ..addScenario(
        'Value decoration',
        getDefaultChart(backgroundDecorations: [
          ValueDecoration(textStyle: defaultTextStyle.copyWith(fontSize: 16.0)),
        ]),
      )
      ..addScenario(
        'Selected item decoration',
        getDefaultChart(backgroundDecorations: [
          SelectedItemDecoration(2,
              backgroundColor: Colors.black,
              selectedStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontFamily: 'Roboto',
                fontSize: 26.0,
              )),
        ]),
      )
      ..addScenario(
        'Target line decoration',
        getDefaultChart(foregroundDecorations: [
          TargetLineDecoration(target: 4),
        ]),
      )
      ..addScenario(
        'Target line text decoration',
        getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(target: 4, targetLineColor: Colors.red.withOpacity(0.1)),
          TargetLineLegendDecoration(
            legendTarget: 4,
            legendDescription: 'This is target |',
            legendStyle: defaultTextStyle.copyWith(fontSize: 18.0),
          ),
        ]),
      )
      ..addScenario(
        'Target area decoration',
        getDefaultChart(foregroundDecorations: [
          TargetAreaDecoration(targetMin: 3, targetMax: 5),
        ]),
      )
      ..addScenario(
        'Sparkline text decoration',
        getDefaultChart(backgroundDecorations: [
          SparkLineDecoration(),
        ]),
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1400, 1300),
      textScaleSize: 1.4,
    );
    await screenMatchesGolden(tester, 'general_decorations_golden');
  });
}
