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
            barItemBuilder: (data) {
              return BarItem(
                  color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listKey].withOpacity(0.5));
            },
          ),
          strategy: DefaultDataStrategy(stackMultipleValues: true),
        ),
      )
      ..addScenario(
        'Stack',
        getMultiValueChart(
          size: 4,
          options: BarItemOptions(
            barItemBuilder: (data) {
              return BarItem(
                color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listKey].withOpacity(0.5),
              );
            },
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
          ),
          strategy: StackDataStrategy(),
        ),
      )
      ..addScenario(
        'Side by side',
        getMultiValueChart(
          size: 4,
          strategy: DefaultDataStrategy(stackMultipleValues: false),
          options: BarItemOptions(
            barItemBuilder: (data) {
              return BarItem(
                color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listKey].withOpacity(0.5),
              );
            },
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
              lineKey: index,
              lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
              lineWidth: 3.0,
              stretchLine: true,
            ),
          ),
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            barItemBuilder: (_) => BarItem(color: Colors.red.withOpacity(0.025)),
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
              lineKey: index,
              lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
              lineWidth: 3.0,
              stretchLine: true,
            ),
          ),
          strategy: StackDataStrategy(),
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            barItemBuilder: (data) => BarItem(color: Colors.red.withOpacity(0.025)),
          ),
        ),
      )
      ..addScenario(
        'Multiple lines side by side',
        getMultiValueChart(
          size: 4,
          strategy: DefaultDataStrategy(stackMultipleValues: false),
          foregroundDecorations: List.generate(
              4,
              (index) => SparkLineDecoration(
                    lineKey: index,
                    lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
                    lineWidth: 3.0,
                    startPosition: index / 4,
                  )),
          options: BarItemOptions(
            barItemBuilder: (data) {
              return BarItem(
                  color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listKey].withOpacity(0.1));
            },
            multiValuePadding: const EdgeInsets.symmetric(horizontal: 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
          ),
        ),
      )
      ..addScenario(
        'Multiple lines different styles',
        getMultiValueChart(
          size: 4,
          foregroundDecorations: [
            SparkLineDecoration(
              lineKey: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.green.withOpacity(0.8),
              stretchLine: true,
            ),
            SparkLineDecoration(
              lineKey: 1,
              lineColor: Colors.blue,
              lineWidth: 2.0,
              dashArray: [10, 10],
              stretchLine: true,
            ),
            SparkLineDecoration(
              lineKey: 2,
              lineColor: Colors.red,
              lineWidth: 4.0,
              smoothPoints: true,
              dashArray: translateMorse('.. -. ..-. .. -. ..- --  '),
              stretchLine: true,
            ),
            SparkLineDecoration(
              lineKey: 3,
              lineColor: Colors.yellow,
              lineWidth: 2.0,
              stretchLine: true,
            ),
          ],
          options: BarItemOptions(
            barItemBuilder: (data) {
              return BarItem(
                  color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listKey].withOpacity(0.1));
            },
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
          ),
        ),
      )
      ..addScenario(
        'Items and lines mixed',
        getMultiValueChart(
          size: 4,
          strategy: DefaultDataStrategy(stackMultipleValues: false),
          foregroundDecorations: [
            SparkLineDecoration(
              lineKey: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.red.withOpacity(0.6),
              stretchLine: true,
            ),
            SparkLineDecoration(
              lineKey: 1,
              lineColor: Colors.blue,
              lineWidth: 2.0,
              dashArray: [15, 5],
              stretchLine: true,
            ),
          ],
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            barItemBuilder: (data) {
              return BarItem(
                color: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.yellow.withOpacity(0.8),
                  Colors.green.withOpacity(0.8),
                ][data.listKey],
              );
            },
          ),
        ),
      )
      ..addScenario(
        'Multiple decorations',
        getMultiValueChart(
          size: 4,
          strategy: DefaultDataStrategy(stackMultipleValues: false),
          foregroundDecorations: [
            SparkLineDecoration(
              lineKey: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.redAccent.withOpacity(0.6),
              stretchLine: true,
            ),
            SparkLineDecoration(
              lineKey: 1,
              lineColor: Colors.red,
              lineWidth: 2.0,
              smoothPoints: true,
              dashArray: translateMorse('.. -. ..-. .. -. ..- --  '),
              stretchLine: true,
            ),
            BorderDecoration(
              borderWidth: 4.0,
            ),
          ],
          backgroundDecorations: [
            GridDecoration(
              horizontalAxisStep: 2,
              gridColor: Colors.grey.shade400,
            ),
            TargetAreaDecoration(
              targetMin: 8,
              targetMax: 14,
              targetLineColor: Colors.transparent,
              targetAreaFillColor: Colors.blue.withOpacity(0.4),
            ),
          ],
          options: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            barItemBuilder: (data) {
              return BarItem(
                color: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.yellow.withOpacity(0.8),
                  Colors.green.withOpacity(0.8),
                ][data.listKey],
              );
            },
          ),
          behaviour: ChartBehaviour(),
        ),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 1000), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'complex_multi_charts');
  });
}

List<double> translateMorse(String morse) {
  final _bigSpace = 6;
  final dot = 6;
  final line = 22;
  final _smallSpace = 3;

  final _s = morse
      .replaceAll(' ', '0,$_bigSpace,0')
      .replaceAll('.', '$dot, $_smallSpace,')
      .replaceAll('-', '$line, $_smallSpace,');
  return _s.split(',').map((e) => double.tryParse(e) ?? 0).toList()..add(12);
}
