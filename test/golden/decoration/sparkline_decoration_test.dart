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

  goldenTest('sparkline_decoration', fileName: 'sparkline_decoration_golden',
      builder: () {
    return GoldenTestGroup(children: [
      GoldenTestScenario(
        name: 'Default',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(lineWidth: 3.0),
        ]),
      ),
      GoldenTestScenario(
        name: 'Start positions at 0',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            startPosition: 0.0,
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Start positions at 1',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            startPosition: 1.0,
          )
        ]),
      ),
      GoldenTestScenario(
        name: 'Thick',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 5.0,
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Smooth',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
            smoothPoints: true,
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Stretch line',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            stretchLine: true,
            smoothPoints: true,
            lineWidth: 3.0,
          )
        ]),
      ),
      GoldenTestScenario(
        name: 'Fill',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            fill: true,
          ),
        ]),
      ),
      GoldenTestScenario(
        name: 'Gradient',
        child: getDefaultChart(foregroundDecorations: [
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
      ),
      GoldenTestScenario(
        name: 'Gradient fill',
        child: getDefaultChart(foregroundDecorations: [
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
      ),
      GoldenTestScenario(
        name: 'Fill and line smooth',
        child: getDefaultChart(foregroundDecorations: [
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
      ),
      GoldenTestScenario(
        name: 'Stretch line dashed',
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            stretchLine: true,
            smoothPoints: true,
            dashArray: [15, 15],
            lineWidth: 3.0,
          )
        ]),
      ),
      GoldenTestScenario(
        name: 'Multiline',
        child: SizedBox(
          height: 300,
          width: 450,
          child: Chart<void>(
            state: ChartState(
                data: ChartData(
                  [
                    [5, 6, 8, 4, 3, 5, 2, 6, 7]
                        .map((e) => BarValue<void>(e.toDouble()))
                        .toList(),
                    [3, 5, 2, 6, 7, 5, 6, 8, 4]
                        .map((e) => BarValue<void>(e.toDouble()))
                        .toList(),
                  ],
                  valueAxisMaxOver: 2,
                ),
                itemOptions: BarItemOptions(
                  barItemBuilder: (_) => BarItem(color: Colors.transparent),
                ),
                foregroundDecorations: [
                  SparkLineDecoration(
                    stretchLine: true,
                    smoothPoints: true,
                    dashArray: [25, 15],
                    lineWidth: 3.0,
                  ),
                  SparkLineDecoration(
                    listIndex: 1,
                    stretchLine: true,
                    lineColor: Colors.red.withOpacity(0.2),
                    smoothPoints: true,
                    fill: true,
                  )
                ]),
          ),
        ),
      )
    ]);
  });
}
