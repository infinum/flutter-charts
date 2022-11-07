import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

import '../util.dart';

void main() {
  goldenTest('Complex - Multiple values', fileName: 'complex_multi_charts', builder: () {
    return GoldenTestGroup(children: [
      GoldenTestScenario(
          name: 'Multiple',
          child: getMultiValueChart(
            size: 4,
            options: BarItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              barItemBuilder: (data) {
                return BarItem(
                    color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listIndex].withOpacity(0.5));
              },
            ),
            strategy: DefaultDataStrategy(stackMultipleValues: true),
          )),
      GoldenTestScenario(
          name: 'Stack',
          child: getMultiValueChart(
            size: 4,
            options: BarItemOptions(
              barItemBuilder: (data) {
                return BarItem(
                  color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listIndex].withOpacity(0.5),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
            ),
            strategy: StackDataStrategy(),
          )),
      GoldenTestScenario(
        name: 'Side by side',
        child: getMultiValueChart(
          size: 4,
          strategy: DefaultDataStrategy(stackMultipleValues: false),
          options: BarItemOptions(
            barItemBuilder: (data) {
              return BarItem(
                color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listIndex].withOpacity(0.5),
              );
            },
            multiValuePadding: const EdgeInsets.symmetric(horizontal: 4.0),
          ),
        ),
      ),
      GoldenTestScenario(
        name: 'Multiple lines',
        child: getMultiValueChart(
          size: 4,
          foregroundDecorations: List.generate(
            4,
            (index) => SparkLineDecoration(
              listIndex: index,
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
      ),
      GoldenTestScenario(
        name: 'Multiple lines stack',
        child: getMultiValueChart(
          size: 4,
          foregroundDecorations: List.generate(
            4,
            (index) => SparkLineDecoration(
              listIndex: index,
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
      ),
      GoldenTestScenario(
          name: 'Multiple lines side by side',
          child: getMultiValueChart(
            size: 4,
            strategy: DefaultDataStrategy(stackMultipleValues: false),
            foregroundDecorations: List.generate(
                4,
                (index) => SparkLineDecoration(
                      listIndex: index,
                      lineColor: [Colors.red, Colors.yellow, Colors.green, Colors.blue][index],
                      lineWidth: 3.0,
                      startPosition: index / 4,
                    )),
            options: BarItemOptions(
              barItemBuilder: (data) {
                return BarItem(
                    color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listIndex].withOpacity(0.1));
              },
              multiValuePadding: const EdgeInsets.symmetric(horizontal: 1.0),
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
            ),
          )),
      GoldenTestScenario(
        name: 'Multiple lines different styles',
        child: getMultiValueChart(
          size: 4,
          foregroundDecorations: [
            SparkLineDecoration(
              listIndex: 0,
              fill: true,
              smoothPoints: true,
              lineColor: Colors.green.withOpacity(0.8),
              stretchLine: true,
            ),
            SparkLineDecoration(
              listIndex: 1,
              lineColor: Colors.blue,
              lineWidth: 2.0,
              dashArray: [10, 10],
              stretchLine: true,
            ),
            SparkLineDecoration(
              listIndex: 2,
              lineColor: Colors.red,
              lineWidth: 4.0,
              smoothPoints: true,
              dashArray: translateMorse('.. -. ..-. .. -. ..- --  '),
              stretchLine: true,
            ),
            SparkLineDecoration(
              listIndex: 3,
              lineColor: Colors.yellow,
              lineWidth: 2.0,
              stretchLine: true,
            ),
          ],
          options: BarItemOptions(
            barItemBuilder: (data) {
              return BarItem(
                  color: [Colors.red, Colors.yellow, Colors.green, Colors.blue][data.listIndex].withOpacity(0.1));
            },
          ),
        ),
      ),
      GoldenTestScenario(
          name: 'Items and lines mixed',
          child: getMultiValueChart(
            size: 4,
            strategy: DefaultDataStrategy(stackMultipleValues: false),
            foregroundDecorations: [
              SparkLineDecoration(
                listIndex: 0,
                fill: true,
                smoothPoints: true,
                lineColor: Colors.red.withOpacity(0.6),
                stretchLine: true,
              ),
              SparkLineDecoration(
                listIndex: 1,
                lineColor: Colors.blue,
                lineWidth: 2.0,
                dashArray: [15, 5],
                stretchLine: true,
              ),
            ],
            options: BarItemOptions(
              barItemBuilder: (data) {
                return BarItem(
                  color: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.yellow.withOpacity(0.8),
                    Colors.green.withOpacity(0.8),
                  ][data.listIndex],
                );
              },
            ),
          )),
      GoldenTestScenario(
          name: 'Multiple decorations',
          child: getMultiValueChart(
            size: 4,
            strategy: DefaultDataStrategy(stackMultipleValues: false),
            foregroundDecorations: [
              SparkLineDecoration(
                listIndex: 0,
                fill: true,
                smoothPoints: true,
                lineColor: Colors.redAccent.withOpacity(0.6),
                stretchLine: true,
              ),
              SparkLineDecoration(
                listIndex: 1,
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
                  ][data.listIndex],
                );
              },
            ),
            behaviour: ChartBehaviour(),
          )),
    ]);
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
