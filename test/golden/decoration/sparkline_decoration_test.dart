import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Sparkline decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(lineWidth: 3.0),
        ]),
      )
      ..addScenario(
        'Start positions at 0',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            startPosition: 0.0,
          ),
        ]),
      )
      ..addScenario(
        'Start positions at 1',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            startPosition: 1.0,
          )
        ]),
      )
      ..addScenario(
        'Thick',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 5.0,
          ),
        ]),
      )
      ..addScenario(
        'Smooth',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            smoothPoints: true,
          ),
        ]),
      )
      ..addScenario(
        'Stretch line',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            linePosition: SparkLinePosition.stretch,
            smoothPoints: true,
            lineWidth: 3.0,
          )
        ]),
      )
      ..addScenario(
        'Fill',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            fill: true,
          ),
        ]),
      )
      ..addScenario(
        'Gradient',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ]),
      )
      ..addScenario(
        'Gradient fill',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            fill: true,
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ]),
      )
      ..addScenario(
        'Fill and line smooth',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            smoothPoints: true,
            fill: true,
            lineColor: Colors.red.withOpacity(0.2),
          ),
          SparkLineDecoration(
            smoothPoints: true,
            lineWidth: 3.0,
          )
        ]),
      )
      ..addScenario(
        'Stretch line dashed',
        getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            linePosition: SparkLinePosition.stretch,
            smoothPoints: true,
            dashArray: [15, 15],
            lineWidth: 3.0,
          )
        ]),
      )
      ..addScenario(
        'Multiline',
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Chart<void>(
            state: ChartState(
                ChartData(
                  [
                    [5, 6, 8, 4, 3, 5, 2, 6, 7].map((e) => BarValue<void>(e.toDouble())).toList(),
                    [3, 5, 2, 6, 7, 5, 6, 8, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
                  ],
                  valueAxisMaxOver: 2,
                ),
                itemOptions: ItemOptions(
                  geometryPainter: barPainter,
                  color: Colors.transparent,
                ),
                foregroundDecorations: [
                  SparkLineDecoration(
                    linePosition: SparkLinePosition.stretch,
                    smoothPoints: true,
                    dashArray: [25, 15],
                    lineWidth: 3.0,
                  ),
                  SparkLineDecoration(
                    lineArrayIndex: 1,
                    linePosition: SparkLinePosition.stretch,
                    lineColor: Colors.red.withOpacity(0.2),
                    smoothPoints: true,
                    fill: true,
                  )
                ]),
          ),
        ),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 1300), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'sparkline_decoration_golden');
  });
}
