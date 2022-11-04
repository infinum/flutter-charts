import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Selected item decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(
          backgroundDecorations: [
            SelectedItemDecoration(
              2,
              selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      )
      ..addScenario(
        'Can be null',
        getDefaultChart(
          backgroundDecorations: [
            SelectedItemDecoration(
              null,
              selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      )
      ..addScenario(
        'with background color',
        getDefaultChart(
          backgroundDecorations: [
            SelectedItemDecoration(
              2,
              selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
              backgroundColor: Colors.black,
            ),
          ],
        ),
      )
      ..addScenario(
        'Show on value',
        getDefaultChart(
          backgroundDecorations: [
            SelectedItemDecoration(
              2,
              showOnTop: false,
              selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      )
      ..addScenario(
        'Can be widget',
        getDefaultChart(
          backgroundDecorations: [
            SelectedItemDecoration(
              2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('8'),
                ),
              ),
              selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      )
      ..addScenario(
        'Can be complex widget with margin',
        Chart<void>(
          state: ChartState(
            data: ChartData(
              [
                [5, 6, 8, 4, 3, 5, 2, 6, 7]
                    .map((e) => BarValue<void>(e.toDouble()))
                    .toList(),
                [3, 5, 2, 6, 7, 5, 6, 8, 4]
                    .map((e) => BarValue<void>(e.toDouble()))
                    .toList(),
                [4, 2, 3, 8, 4, 5, 7, 5, 6]
                    .map((e) => BarValue<void>(e.toDouble()))
                    .toList(),
              ],
              valueAxisMaxOver: 2,
            ),
            itemOptions: BarItemOptions(
              barItemBuilder: (_) => const BarItem(color: Colors.transparent),
            ),
            backgroundDecorations: [
              GridDecoration(
                gridColor: Colors.grey.shade300,
              ),
            ],
            foregroundDecorations: [
              SparkLineDecoration(
                stretchLine: true,
                lineWidth: 3,
              ),
              SparkLineDecoration(
                listIndex: 1,
                stretchLine: true,
                lineColor: Colors.yellow,
                lineWidth: 3,
              ),
              SparkLineDecoration(
                listIndex: 2,
                stretchLine: true,
                lineColor: Colors.green,
                lineWidth: 3,
              ),
              SelectedItemDecoration(
                2,
                topMargin: 90,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 15,
                              height: 1.5,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text('8'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 15,
                              height: 1.5,
                              color: Colors.yellow,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text('2'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 15,
                              height: 1.5,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text('3'),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                selectedStyle: const TextStyle().copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(1400, 660),
      textScaleSize: 1.4,
    );
    await screenMatchesGolden(tester, 'selected_item_decoration_golden');
  });
}
