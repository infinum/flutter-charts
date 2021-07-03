import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Simple line chart', (tester) async {
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: Chart(
          height: 600.0,
          state: ChartState.line(
            ChartData.fromList(
              <double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e)).toList(),
            ),
          ),
        ),
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/simple_line_chart.png'));
  });

  testWidgets('Simple bar chart', (tester) async {
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: Chart(
          height: 600.0,
          state: ChartState.bar(
            ChartData.fromList(
              <double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e)).toList(),
            ),
          ),
        ),
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/simple_bar_chart.png'));
  });

  testWidgets('Bar chart', (tester) async {
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: Chart<void>(
          height: 600.0,
          state: ChartState(
            ChartData.fromList([1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
                axisMax: 8.0),
            itemOptions: BarItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              radius: BorderRadius.vertical(top: Radius.circular(42.0)),
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
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/bar_chart.png'));
  });

  testWidgets('Line chart', (tester) async {
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: Chart<void>(
          height: 600.0,
          state: ChartState(
            ChartData.fromList([1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),
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
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/line_chart.png'));
  });

  testWidgets('Multi line chart', (tester) async {
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: Chart<void>(
          height: 600.0,
          state: ChartState(
            ChartData(
              [
                [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),
                [4, 6, 3, 3, 2, 1, 4, 7, 5].map((e) => BubbleValue<void>(e.toDouble())).toList(),
              ],
              axisMax: 8.0,
            ),
            itemOptions: BubbleItemOptions(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              maxBarWidth: 4.0,
              colorForKey: (item, index) {
                return [Colors.red, Colors.blue][index];
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
                // Throws if `lineKey` does not exist in chart data
                lineArrayIndex: 1,
                lineColor: Colors.blue,
              ),
              SparkLineDecoration(),
            ],
          ),
        ),
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/multi_line_chart.png'));
  });
}
