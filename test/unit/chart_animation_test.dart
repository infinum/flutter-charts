import 'package:charts_painter/chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Items', () {
    test('Lerp items, min, max', () {
      final _firstState = ChartData.fromList([BarValue<void>(10)]);
      final _secondState = ChartData.fromList(
          [BarValue<void>(10), BarValue<void>(20), BarValue<void>(15)],
          axisMin: 10);

      expect(_firstState.items[0].length, 1);
      expect(_firstState.maxValue, 10);
      expect(_firstState.minValue, 0);

      expect(_secondState.items[0].length, 3);
      expect(_secondState.maxValue, 20);
      expect(_secondState.minValue, 10);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);
      expect(_middleState.items[0].length, 2);
      expect(_middleState.maxValue, 15);
      expect(_middleState.minValue, 5);
    });

    test('Animation animates items', () {
      final _firstState = ChartData.fromList([BarValue<void>(10)]);
      final _secondState = ChartData.fromList(
          [BarValue<void>(20), BarValue<void>(10), BarValue<void>(5)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      expect(_middleState.items[0],
          [ChartItem<void>(null, min: null, value: 15), ChartItem<void>(0.0, min: 0.0, value: 5)]);
    });

    test('Bar -> Bubble animates different type items', () {
      final _firstState = ChartData.fromList([BarValue<void>(10)]);
      final _secondState = ChartData.fromList([BubbleValue<void>(20)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items[0], [ChartItem<void>(10, min: null, value: 15)]);
    });

    test('Bubble -> Bar animates different type items', () {
      final _firstState = ChartData.fromList([BubbleValue<void>(10)]);
      final _secondState = ChartData.fromList([BarValue<void>(20)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items[0], [ChartItem<void>(5, min: null, value: 15)]);
    });

    test('Bar -> Candle animates different type items', () {
      final _firstState = ChartData.fromList([BarValue<void>(10)]);
      final _secondState = ChartData.fromList([CandleValue<void>(10, 20)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items[0], [CandleValue<void>(5, 15)]);
    });

    test('Candle -> Bar animates different type items', () {
      final _firstState = ChartData.fromList([CandleValue<void>(10, 20)]);
      final _secondState = ChartData.fromList([BarValue<void>(10)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items[0], [ChartItem<void>(5, min: null, value: 15)]);
    });

    test('Bubble -> Candle animates different type items', () {
      final _firstState = ChartData.fromList([BubbleValue<void>(10)]);
      final _secondState = ChartData.fromList([CandleValue<void>(10, 20)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items[0], [CandleValue<void>(10, 15)]);
    });

    test('Candle -> Bubble animates different type items', () {
      final _firstState = ChartData.fromList([CandleValue<void>(10, 20)]);
      final _secondState = ChartData.fromList([BubbleValue<void>(10)]);

      final _middleState = ChartData.lerp<void>(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items[0], [ChartItem<void>(10, value:  15)]);
    });
  });

  group('Decorations', () {
    test('Decorations can animate if they are the same type', () {
      final _firstState = ChartState<void>(
          ChartData.fromList(
            [2, 4, 6, 3, 5, 1]
                .map((e) => BarValue<void>(e.toDouble()))
                .toList(),
          ),
          itemOptions: BarItemOptions(),
          foregroundDecorations: [
            HorizontalAxisDecoration(
              axisStep: 1,
              lineWidth: 5.0,
            ),
          ]);
      final _secondState = ChartState<void>(
          ChartData.fromList(
            [2, 4, 6, 3, 5, 1]
                .map((e) => BarValue<void>(e.toDouble()))
                .toList(),
          ),
          itemOptions: BarItemOptions(),
          foregroundDecorations: [
            HorizontalAxisDecoration(
              axisStep: 5,
              lineWidth: 1.0,
            ),
          ]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // We should have only one decoration and it should be HorizontalAxisDecoration
      final _middleDecoration =
          _middleState.foregroundDecorations.first as HorizontalAxisDecoration;

      expect(_middleDecoration.axisStep, 3);
      expect(_middleDecoration.lineWidth, 3);
    });

    test('Decorations won\'t try to animate if they are not the same type', () {
      final _firstState = ChartState<void>(
          ChartData.fromList(
            [2, 4, 6, 3, 5, 1]
                .map((e) => BarValue<void>(e.toDouble()))
                .toList(),
          ),
          itemOptions: BarItemOptions(),
          foregroundDecorations: [
            HorizontalAxisDecoration(
              axisStep: 1,
              lineWidth: 5.0,
            ),
          ]);
      final _secondState = ChartState<void>(
          ChartData.fromList(
            [2, 4, 6, 3, 5, 1]
                .map((e) => BarValue<void>(e.toDouble()))
                .toList(),
          ),
          itemOptions: BarItemOptions(),
          foregroundDecorations: [
            VerticalAxisDecoration(
              axisStep: 5,
              lineWidth: 1.0,
            ),
          ]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // We should have only one decoration and it should be HorizontalAxisDecoration
      final _middleDecoration = _middleState.foregroundDecorations.first;

      // There is no animation here, just make sure the end type is okay.
      expect(_middleDecoration, isA<VerticalAxisDecoration>());
    });
  });
}
