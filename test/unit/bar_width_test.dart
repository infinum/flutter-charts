import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _chart({double? maxBarWidth, double? minBarWidth}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: 400,
        height: 200,
        child: Chart<void>(
          state: ChartState<void>(
            data: ChartData.fromList(
              [4, 8, 6, 2].map((e) => BarValue<void>(e.toDouble())).toList(),
            ),
            itemOptions: BarItemOptions(
              maxBarWidth: maxBarWidth,
              minBarWidth: minBarWidth,
            ),
          ),
        ),
      ),
    ),
  );
}

Iterable<double> _itemWidths(WidgetTester tester) => tester.allRenderObjects
    .whereType<RenderBox>()
    .where((r) => r.runtimeType.toString().contains('_RenderLeafChartItem'))
    .map((r) => r.size.width);

void main() {
  testWidgets('maxBarWidth caps painted bar width', (tester) async {
    await tester.pumpWidget(_chart(maxBarWidth: 4));
    final widths = _itemWidths(tester).toList();
    expect(widths, isNotEmpty);
    expect(widths.every((w) => w <= 4.0), isTrue,
        reason: 'expected all bars <= 4, got $widths');
  });

  testWidgets('minBarWidth enforces painted bar width', (tester) async {
    await tester.pumpWidget(_chart(minBarWidth: 150));
    final widths = _itemWidths(tester).toList();
    expect(widths, isNotEmpty);
    expect(widths.every((w) => w >= 150.0), isTrue,
        reason: 'expected all bars >= 150, got $widths');
  });
}
