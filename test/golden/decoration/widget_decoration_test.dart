import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Widget decoration examples', (tester) async {
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.4)
      ..addScenario(
        'Target line decoration',
        getDefaultChart(backgroundDecorations: [
          WidgetDecoration(widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: verticalMultiplier * 3,
                  child: Container(color: Colors.red, height: 2),
                ),
              ],
            );
          })
        ]),
      )
      ..addScenario(
        'Target line text decoration',
        getDefaultChart(backgroundDecorations: [
          WidgetDecoration(
              widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: null,
                      bottom: 2 * verticalMultiplier,
                      child: const RotatedBox(quarterTurns: 3, child: Text('This is target line')),
                    ),
                    Positioned.fill(
                      top: null,
                      left: 0,
                      bottom: 2 * verticalMultiplier,
                      child: Container(color: Colors.red, width: double.infinity, height: 2),
                    ),
                  ],
                );
              },
              margin: const EdgeInsets.only(left: 20)),
        ]),
      )
      ..addScenario(
        'Target area decoration',
        getDefaultChart(backgroundDecorations: [
          WidgetDecoration(
            widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
              return Padding(
                padding: EdgeInsets.only(top: 5 * verticalMultiplier),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: double.infinity,
                  height: verticalMultiplier * 2,
                ),
              );
            },
          ),
        ]),
      )
      ..addScenario(
        'Border decoration',
        getDefaultChart(backgroundDecorations: [
          WidgetDecoration(
              widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
                return Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 3)),
                  width: double.infinity,
                  height: double.infinity,
                );
              },
              margin: EdgeInsets.all(3)),
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(), surfaceSize: const Size(1400, 1020), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'widget_decoration_golden');
  });
}
