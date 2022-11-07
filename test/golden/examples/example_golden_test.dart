import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

void main() {
  goldenTest('Simple line chart', fileName: 'simple_line_chart', builder: () {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 300,
        width: 450,
        child: Chart(
          state: ChartState.line(
            ChartData.fromList(
              <double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e)).toList(),
            ),
            itemOptions: BubbleItemOptions(),
          ),
        ),
      ),
    );
  });

  goldenTest('Simple bar chart', fileName: 'simple_bar_chart', builder: () {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 300,
        width: 450,
        child: Chart(
          height: 600.0,
          state: ChartState.bar(
            ChartData.fromList(
              <double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e)).toList(),
            ),
            itemOptions: BarItemOptions(),
          ),
        ),
      ),
    );
  });

  goldenTest('Bar chart', fileName: 'bar_chart', builder: () {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 300,
        width: 450,
        child: Chart<void>(
          state: ChartState(
            data: ChartData.fromList([1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
                axisMax: 8.0),
            itemOptions: BarItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              barItemBuilder: (_) {
                return BarItem(
                  radius: BorderRadius.vertical(top: Radius.circular(42.0)),
                );
              },
            ),
            backgroundDecorations: [
              GridDecoration(
                verticalAxisStep: 1,
                horizontalAxisStep: 1,
              ),
            ],
            foregroundDecorations: [
              BorderDecoration(borderWidth: 5.0),
            ],
          ),
        ),
      ),
    );
  });

  goldenTest('Line chart', fileName: 'line_chart', builder: () {
    return Container(
      height: 300,
      width: 450,
      padding: EdgeInsets.zero,
      child: Chart<void>(
        state: ChartState(
          data: ChartData.fromList([1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),
              axisMax: 8.0),
          itemOptions: BubbleItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            maxBarWidth: 4.0,
          ),
          backgroundDecorations: [
            GridDecoration(
              verticalAxisStep: 1,
              horizontalAxisStep: 1,
            ),
          ],
          foregroundDecorations: [
            BorderDecoration(borderWidth: 5.0),
            SparkLineDecoration(),
          ],
        ),
      ),
    );
  });

  goldenTest('Multi line chart', fileName: 'multi_line_chart', builder: () {
    return Container(
      height: 300,
      width: 450,
      padding: EdgeInsets.zero,
      child: Chart<void>(
        state: ChartState(
          data: ChartData(
            [
              [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),
              [4, 6, 3, 3, 2, 1, 4, 7, 5].map((e) => BubbleValue<void>(e.toDouble())).toList(),
            ],
            axisMax: 8.0,
          ),
          itemOptions: BubbleItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            maxBarWidth: 4.0,
            bubbleItemBuilder: (data) {
              return BubbleItem(color: [Colors.red, Colors.blue][data.listIndex]);
            },
          ),
          backgroundDecorations: [
            GridDecoration(
              verticalAxisStep: 1,
              horizontalAxisStep: 1,
            ),
          ],
          foregroundDecorations: [
            BorderDecoration(borderWidth: 5.0),
            SparkLineDecoration(
              // Specify key that this [SparkLineDecoration] will follow
              // Throws if `listIndex` does not exist in chart data
              listIndex: 1,
              lineColor: Colors.blue,
            ),
            SparkLineDecoration(),
          ],
        ),
      ),
    );
  });
}
