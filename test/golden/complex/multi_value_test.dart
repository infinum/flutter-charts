import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Complex - Multiple values', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Multiple',
        getMultiValueChart(
          size: 4,
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            color: Colors.red.withOpacity(0.1),
            colorForKey: (item, key) => [Colors.red, Colors.yellow, Colors.green, Colors.blue][key].withOpacity(0.4),
          ),
        ),
      )
      ..addScenario(
        'Stack',
        getMultiValueChart(
          size: 4,
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            color: Colors.red.withOpacity(0.1),
            colorForKey: (item, key) => [Colors.red, Colors.yellow, Colors.green, Colors.blue][key].withOpacity(0.4),
          ),
          strategy: StackDataStrategy(),
          behaviour: ChartBehaviour(
            multiItemStack: true,
          ),
        ),
      )
      ..addScenario(
        'Side by side',
        getMultiValueChart(
          size: 4,
          options: ItemOptions(
            geometryPainter: barPainter,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            color: Colors.red.withOpacity(0.1),
            colorForKey: (item, key) => [Colors.red, Colors.yellow, Colors.green, Colors.blue][key].withOpacity(0.2),
          ),
          behaviour: ChartBehaviour(
            multiItemStack: false,
          ),
        ),
      )
      ..addScenario(
        'Multiple lines',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: List.generate(
              4,
              (index) => SparkLineDecoration(
                    lineArrayIndex: index,
                    lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
                    lineWidth: 3.0,
                    linePosition: SparkLinePosition.stretch,
                  )),
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            color: Colors.red.withOpacity(0.025),
          ),
        ),
      )
      ..addScenario(
        'Multiple lines stack',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: List.generate(
              4,
              (index) => SparkLineDecoration(
                    lineArrayIndex: index,
                    lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
                    lineWidth: 3.0,
                    linePosition: SparkLinePosition.stretch,
                  )),
          strategy: StackDataStrategy(),
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            color: Colors.red.withOpacity(0.025),
          ),
        ),
      )
      ..addScenario(
        'Multiple lines side by side',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: List.generate(
              4,
              (index) => SparkLineDecoration(
                    lineArrayIndex: index,
                    lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
                    lineWidth: 3.0,
                    startPosition: index / 4,
                  )),
          options: BarItemOptions(
            multiValuePadding: const EdgeInsets.symmetric(horizontal: 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            colorForKey: (item, key) => [Colors.red, Colors.yellow, Colors.green, Colors.blue][key].withOpacity(0.1),
          ),
          behaviour: ChartBehaviour(
            multiItemStack: false,
          ),
        ),
      )
      ..addScenario(
        'Multiple lines different styles',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: [
            SparkLineDecoration(
              lineArrayIndex: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.green.withOpacity(0.8),
              linePosition: SparkLinePosition.stretch,
            ),
            SparkLineDecoration(
              lineArrayIndex: 1,
              lineColor: Colors.blue,
              lineWidth: 2.0,
              dashArray: [10, 10],
              linePosition: SparkLinePosition.stretch,
            ),
            SparkLineDecoration(
              lineArrayIndex: 2,
              lineColor: Colors.red,
              lineWidth: 4.0,
              smoothPoints: true,
              dashArray: translateMorse('.. -. ..-. .. -. ..- --  '),
              linePosition: SparkLinePosition.stretch,
            ),
            SparkLineDecoration(
              lineArrayIndex: 3,
              lineColor: Colors.yellow,
              lineWidth: 2.0,
              linePosition: SparkLinePosition.stretch,
            ),
          ],
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            colorForKey: (item, key) => [Colors.green, Colors.yellow, Colors.red, Colors.blue][key].withOpacity(0.1),
          ),
        ),
      )
      ..addScenario(
        'Items and lines mixed',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: [
            SparkLineDecoration(
              lineArrayIndex: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.red.withOpacity(0.6),
              linePosition: SparkLinePosition.stretch,
            ),
            SparkLineDecoration(
              lineArrayIndex: 1,
              lineColor: Colors.blue,
              lineWidth: 2.0,
              dashArray: [15, 5],
              linePosition: SparkLinePosition.stretch,
            ),
          ],
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            colorForKey: (item, key) => [
              Colors.transparent,
              Colors.transparent,
              Colors.yellow.withOpacity(0.8),
              Colors.green.withOpacity(0.8),
            ][key],
          ),
          behaviour: ChartBehaviour(
            multiItemStack: false,
          ),
        ),
      )
      ..addScenario(
        'Multiple decorations',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: [
            SparkLineDecoration(
              lineArrayIndex: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.redAccent.withOpacity(0.6),
              linePosition: SparkLinePosition.stretch,
            ),
            SparkLineDecoration(
              lineArrayIndex: 1,
              lineColor: Colors.red,
              lineWidth: 2.0,
              smoothPoints: true,
              dashArray: translateMorse('.. -. ..-. .. -. ..- --  '),
              linePosition: SparkLinePosition.stretch,
            ),
            TargetLineDecoration(target: 10),
            BorderDecoration(
              borderWidth: 4.0,
            ),
          ],
          backgroundDecorations: [
            GridDecoration(
              horizontalAxisStep: 4,
            ),
          ],
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            colorForKey: (item, key) => [
              Colors.transparent,
              Colors.transparent,
              Colors.yellow.withOpacity(0.8),
              Colors.green.withOpacity(0.8),
            ][key],
          ),
          behaviour: ChartBehaviour(
            multiItemStack: false,
          ),
        ),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 1000), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'complex_multi_charts');
  });
}

List<double> translateMorse(String morse) {
  final int _bigSpace = 6;

  final int dot = 6;
  final int line = 22;
  final int _smallSpace = 3;

  final _s = morse
      .replaceAll(' ', '0,$_bigSpace,0')
      .replaceAll('.', '$dot, $_smallSpace,')
      .replaceAll('-', '$line, $_smallSpace,');
  return _s.split(',').map((e) => double.tryParse(e) ?? 0).toList()..add(12);
}
