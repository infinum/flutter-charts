import 'package:charts_painter/chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lerp items, min, max', () {
    final _firstState = ChartState<void>(ChartData.fromList([BarValue<void>(10)]));
    final _secondState = ChartState<void>(
      ChartData.fromList([BarValue<void>(10), BarValue<void>(20), BarValue<void>(15)], axisMin: 10),
    );

    expect(_firstState.items[0].length, 1);
    expect(_firstState.maxValue, 10);
    expect(_firstState.minValue, 0);

    expect(_secondState.items[0].length, 3);
    expect(_secondState.maxValue, 20);
    expect(_secondState.minValue, 10);

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);
    expect(_middleState.items[0].length, 2);
    expect(_middleState.maxValue, 15);
    expect(_middleState.minValue, 5);
  });

  test('Animation animates items', () {
    final _firstState = ChartState<void>(ChartData.fromList([BarValue<void>(10)]));
    final _secondState =
        ChartState<void>(ChartData.fromList([BarValue<void>(20), BarValue<void>(10), BarValue<void>(5)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    expect(_middleState.items[0], [ChartItem<void>(null, null, 15), ChartItem<void>(null, 0.0, 5)]);
  });

  test('Bar -> Bubble animates different type items', () {
    final _firstState = ChartState<void>(ChartData.fromList([BarValue<void>(10)]));
    final _secondState = ChartState<void>(ChartData.fromList([BubbleValue<void>(20)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    // Animating to second state, so second item type has to be used
    expect(_middleState.items[0], [ChartItem<void>(null, 10, 15)]);
  });

  test('Bubble -> Bar animates different type items', () {
    final _firstState = ChartState<void>(ChartData.fromList([BubbleValue<void>(10)]));
    final _secondState = ChartState<void>(ChartData.fromList([BarValue<void>(20)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    // Animating to second state, so second item type has to be used
    expect(_middleState.items[0], [ChartItem<void>(null, 5, 15)]);
  });

  test('Bar -> Candle animates different type items', () {
    final _firstState = ChartState<void>(ChartData.fromList([BarValue<void>(10)]));
    final _secondState = ChartState<void>(ChartData.fromList([CandleValue<void>(10, 20)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    // Animating to second state, so second item type has to be used
    expect(_middleState.items[0], [CandleValue<void>(5, 15)]);
  });

  test('Candle -> Bar animates different type items', () {
    final _firstState = ChartState<void>(ChartData.fromList([CandleValue<void>(10, 20)]));
    final _secondState = ChartState<void>(ChartData.fromList([BarValue<void>(10)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    // Animating to second state, so second item type has to be used
    expect(_middleState.items[0], [ChartItem<void>(null, 5, 15)]);
  });

  test('Bubble -> Candle animates different type items', () {
    final _firstState = ChartState<void>(ChartData.fromList([BubbleValue<void>(10)]));
    final _secondState = ChartState<void>(ChartData.fromList([CandleValue<void>(10, 20)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    // Animating to second state, so second item type has to be used
    expect(_middleState.items[0], [CandleValue<void>(10, 15)]);
  });

  test('Candle -> Bubble animates different type items', () {
    final _firstState = ChartState<void>(ChartData.fromList([CandleValue<void>(10, 20)]));
    final _secondState = ChartState<void>(ChartData.fromList([BubbleValue<void>(10)]));

    final _middleState = ChartState.lerp<void>(_firstState, _secondState, 0.5);

    // Animating to second state, so second item type has to be used
    expect(_middleState.items[0], [ChartItem<void>(null, 10, 15)]);
  });
}
