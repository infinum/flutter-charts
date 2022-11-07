import 'dart:math';

import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  goldenTest('Bar painter', fileName: 'bar_geometry_golden', builder: () {
    return Container(
      height: 500,
      width: 800,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Chart<void>(
          state: ChartState(
            data: ChartData.fromList(
              [5, 6, 8, 4, 3, 5, 2, 6, 7]
                  .map((e) => BarValue<void>(e.toDouble()))
                  .toList(),
              valueAxisMaxOver: 2,
            ),
            itemOptions: BarItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              barItemBuilder: (data) {
                return BarItem(color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  });

  goldenTest('Widget painter', fileName: 'widget_geometry_golden', builder: () {
    return Container(
      height: 500,
      width: 800,
      child: Padding(
        key: ValueKey('chart'),
        padding: EdgeInsets.zero,
        child: Chart<void>(
          state: ChartState(
            data: ChartData.fromList(
              [5, 6, 8, 4, 3, 5, 2, 6, 7]
                  .map((e) => BarValue<void>(e.toDouble()))
                  .toList(),
              valueAxisMaxOver: 2,
            ),
            itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
              return Container(
                color: Colors.red,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Widget',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  });

  goldenTest('Widget painter', fileName: 'widget_geometry_golden', builder: () {
    return Container(
      height: 500,
      width: 800,
      child: Padding(
        key: ValueKey('chart'),
        padding: EdgeInsets.zero,
        child: Chart<void>(
          state: ChartState(
            data: ChartData.fromList(
              [5, 6, 8, 4, 3, 5, 2, 6, 7]
                  .map((e) => BarValue<void>(e.toDouble()))
                  .toList(),
              valueAxisMaxOver: 2,
            ),
            itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
              return Container(
                color: Colors.red,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Widget',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  });

  goldenTest('Candle painter', fileName: 'candle_geometry_golden', builder: () {
    return Container(
      height: 500,
      width: 800,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Chart<void>(
          state: ChartState(
            data: ChartData.fromList(
              [5, 6, 8, 4, 3, 5, 2, 6, 7]
                  .mapIndexed((i, e) => CandleValue<void>(e.toDouble(),
                      e.toDouble() + (Random(i).nextDouble() * 10) - 5))
                  .toList(),
              valueAxisMaxOver: 2,
            ),
            itemOptions: BarItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              barItemBuilder: (data) {
                return BarItem(color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  });

  goldenTest('Bubble painter', fileName: 'bubble_geometry_golden', builder: () {
    return Container(
      height: 500,
      width: 800,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Chart<void>(
          state: ChartState(
            data: ChartData.fromList(
              [5, 6, 8, 4, 3, 5, 2, 6, 7]
                  .map((e) => BubbleValue<void>(e.toDouble()))
                  .toList(),
              valueAxisMaxOver: 2,
            ),
            itemOptions: BubbleItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              bubbleItemBuilder: (data) {
                return BubbleItem(color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  });
}
