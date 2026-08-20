import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _chartWidth = 400.0;
const _items = [4.0, 8.0, 6.0, 2.0];

Widget _chart({
  double? maxBarWidth,
  double? minBarWidth,
  EdgeInsets padding = EdgeInsets.zero,
  ScrollSettings scrollSettings = const ScrollSettings.none(),
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: _chartWidth,
        height: 200,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedChart<void>(
            duration: const Duration(milliseconds: 10),
            width: _chartWidth,
            height: 200,
            state: ChartState<void>(
              data: ChartData.fromList(
                  _items.map((e) => BarValue<void>(e)).toList()),
              itemOptions: BarItemOptions(
                maxBarWidth: maxBarWidth,
                minBarWidth: minBarWidth,
                padding: padding,
              ),
              behaviour: ChartBehaviour(scrollSettings: scrollSettings),
            ),
          ),
        ),
      ),
    ),
  );
}

Iterable<RenderBox> _barItems(WidgetTester tester) => tester.allRenderObjects
    .whereType<RenderBox>()
    .where((r) => r.runtimeType.toString().contains('_RenderLeafChartItem'));

List<double> _widths(WidgetTester tester) =>
    _barItems(tester).map((r) => r.size.width).toList();

/// Distance from the left edge of the chart to the center of every bar.
List<double> _centers(WidgetTester tester) {
  final chartLeft = tester.getTopLeft(find.byType(AnimatedChart<void>)).dx;
  return _barItems(tester)
      .map((r) => r.localToGlobal(Offset.zero).dx + r.size.width / 2 - chartLeft)
      .toList();
}

void main() {
  group('non-scrollable chart', () {
    testWidgets('maxBarWidth caps bar width', (tester) async {
      await tester.pumpWidget(_chart(maxBarWidth: 4));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(4.0));
    });

    testWidgets('minBarWidth enforces bar width', (tester) async {
      await tester.pumpWidget(_chart(minBarWidth: 150));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(150.0));
    });

    testWidgets('bars without limits fill the space they got', (tester) async {
      await tester.pumpWidget(_chart());
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(_chartWidth / _items.length));
    });

    testWidgets('clamped bars stay centered in their slot', (tester) async {
      await tester.pumpWidget(_chart(maxBarWidth: 4));
      await tester.pumpAndSettle();

      final slot = _chartWidth / _items.length;
      expect(_centers(tester), [
        for (var i = 0; i < _items.length; i++) closeTo(slot * (i + 0.5), 0.01),
      ]);
    });

    testWidgets('padding is applied before clamping, not twice',
        (tester) async {
      await tester.pumpWidget(
          _chart(padding: const EdgeInsets.symmetric(horizontal: 10)));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(_chartWidth / _items.length - 20));
    });
  });

  group('scrollable chart', () {
    testWidgets('minBarWidth sets the bar width', (tester) async {
      await tester.pumpWidget(
          _chart(minBarWidth: 36, scrollSettings: ScrollSettings()));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(36.0));
    });

    testWidgets('maxBarWidth sets the bar width', (tester) async {
      await tester
          .pumpWidget(_chart(maxBarWidth: 4, scrollSettings: ScrollSettings()));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(4.0));
    });

    testWidgets('maxBarWidth caps visibleItems width when minBarWidth is set',
        (tester) async {
      // 400 / 2 visible items would give 200px wide bars.
      await tester.pumpWidget(_chart(
        minBarWidth: 10,
        maxBarWidth: 20,
        scrollSettings: ScrollSettings(visibleItems: 2),
      ));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(20.0));
    });

    testWidgets('minBarWidth raises visibleItems width', (tester) async {
      // 400 / 100 visible items would give 4px wide bars.
      await tester.pumpWidget(_chart(
        minBarWidth: 24,
        scrollSettings: ScrollSettings(visibleItems: 100),
      ));
      await tester.pumpAndSettle();

      expect(_widths(tester), everyElement(24.0));
    });
  });
}
