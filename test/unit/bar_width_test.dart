import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _chartWidth = 400.0;
const _items = [4.0, 8.0, 6.0, 2.0];

Widget _chart({
  double? maxBarWidth,
  double? minBarWidth,
  double startPosition = 0.5,
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
                startPosition: startPosition,
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

/// Chart items, both the painted ones and the ones built from a widget.
Iterable<RenderBox> _barItems(WidgetTester tester) => tester.allRenderObjects
    .whereType<RenderBox>()
    .where((r) =>
        r.runtimeType.toString().contains('_RenderLeafChartItem') ||
        r.runtimeType.toString().contains('_RenderChildChartItem'));

List<double> _widths(WidgetTester tester) {
  final widths = _barItems(tester).map((r) => r.size.width).toList();
  expect(widths, hasLength(_items.length), reason: 'no chart items rendered');
  return widths;
}

/// Distance from the left edge of the chart to the left edge of every bar.
List<double> _lefts(WidgetTester tester) {
  final chartLeft = tester.getTopLeft(find.byType(AnimatedChart<void>)).dx;
  return _barItems(tester)
      .map((r) => r.localToGlobal(Offset.zero).dx - chartLeft)
      .toList();
}

/// Distance from the left edge of the chart to the center of every bar.
List<double> _centers(WidgetTester tester) {
  final chartLeft = tester.getTopLeft(find.byType(AnimatedChart<void>)).dx;
  return _barItems(tester)
      .map((r) => r.localToGlobal(Offset.zero).dx + r.size.width / 2 - chartLeft)
      .toList();
}

Widget _animatedChart({
  double? maxBarWidth,
  double? minBarWidth,
  bool widgetItems = false,
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: _chartWidth,
        height: 200,
        child: AnimatedChart<void>(
          key: const ValueKey('chart'),
          duration: const Duration(milliseconds: 300),
          width: _chartWidth,
          height: 200,
          state: ChartState<void>(
            data: ChartData.fromList(
                _items.map((e) => BarValue<void>(e)).toList()),
            itemOptions: widgetItems
                ? WidgetItemOptions(
                    maxBarWidth: maxBarWidth,
                    minBarWidth: minBarWidth,
                    widgetItemBuilder: (_) => const SizedBox.expand(),
                  )
                : BarItemOptions(
                    maxBarWidth: maxBarWidth,
                    minBarWidth: minBarWidth,
                  ),
          ),
        ),
      ),
    ),
  );
}

/// Item widths of every frame of a running animation, first frame excluded.
/// The first frame still shows the state the animation starts from.
Future<List<List<double>>> _animationFrames(WidgetTester tester) async {
  final frames = <List<double>>[];
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    frames.add(_widths(tester));
  }
  return frames;
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

    testWidgets('startPosition 0.0 draws the bar from the start of the slot',
        (tester) async {
      await tester.pumpWidget(_chart(maxBarWidth: 4, startPosition: 0.0));
      await tester.pumpAndSettle();

      final slot = _chartWidth / _items.length;
      expect(_widths(tester), everyElement(4.0));
      expect(_lefts(tester), [
        for (var i = 0; i < _items.length; i++) closeTo(slot * i, 0.01),
      ]);
    });

    testWidgets('startPosition 1.0 draws the bar at the end of the slot',
        (tester) async {
      await tester.pumpWidget(_chart(maxBarWidth: 4, startPosition: 1.0));
      await tester.pumpAndSettle();

      final slot = _chartWidth / _items.length;
      expect(_widths(tester), everyElement(4.0));
      expect(_lefts(tester), [
        for (var i = 0; i < _items.length; i++)
          closeTo(slot * (i + 1) - 4.0, 0.01),
      ]);
    });

    testWidgets('startPosition is measured from inside the padding',
        (tester) async {
      await tester.pumpWidget(_chart(
        maxBarWidth: 4,
        startPosition: 0.0,
        padding: const EdgeInsets.only(left: 10),
      ));
      await tester.pumpAndSettle();

      final slot = _chartWidth / _items.length;
      expect(_lefts(tester), [
        for (var i = 0; i < _items.length; i++) closeTo(slot * i + 10, 0.01),
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

  group('animating the limits', () {
    testWidgets('setting maxBarWidth does not collapse the items first',
        (tester) async {
      await tester.pumpWidget(_animatedChart());
      await tester.pumpAndSettle();
      expect(_widths(tester), everyElement(_chartWidth / _items.length));

      await tester.pumpWidget(_animatedChart(maxBarWidth: 4));
      final frames = await _animationFrames(tester);

      // `maxBarWidth: null` means unlimited, animating it as `0.0` used to shrink
      // every item to nothing before snapping it back to `maxBarWidth`.
      expect(frames, everyElement(everyElement(greaterThanOrEqualTo(4.0))));
      expect(frames.last, everyElement(4.0));
    });

    testWidgets('removing maxBarWidth does not collapse the items first',
        (tester) async {
      await tester.pumpWidget(_animatedChart(maxBarWidth: 4));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_animatedChart());
      final frames = await _animationFrames(tester);

      expect(frames, everyElement(everyElement(greaterThanOrEqualTo(4.0))));
      expect(frames.last, everyElement(_chartWidth / _items.length));
    });

    testWidgets('maxBarWidth animates between two set values', (tester) async {
      await tester.pumpWidget(_animatedChart(maxBarWidth: 4));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_animatedChart(maxBarWidth: 40));
      final frames = await _animationFrames(tester);

      expect(frames.first, everyElement(allOf(greaterThan(4.0), lessThan(40.0))),
          reason: 'expected a step between the two values, got ${frames.first}');
      expect(frames.last, everyElement(40.0));
    });

    testWidgets('widget items keep their limits while animating',
        (tester) async {
      await tester.pumpWidget(_animatedChart(maxBarWidth: 4, widgetItems: true));
      await tester.pumpAndSettle();

      await tester
          .pumpWidget(_animatedChart(maxBarWidth: 10, widgetItems: true));
      final frames = await _animationFrames(tester);

      // WidgetItemOptions used to drop both limits while animating, which let the
      // items jump to the full width of their slot.
      expect(frames, everyElement(everyElement(lessThanOrEqualTo(10.0))));
      expect(frames.last, everyElement(10.0));
    });
  });
}
