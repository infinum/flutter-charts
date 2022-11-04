import 'package:charts_painter/chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Default min value is 0', () {
    test('[Bar] Default min value is 0', () {
      final _state = ChartState<void>(
        data: ChartData.fromList([BarValue<void>(2)]),
        itemOptions: const BarItemOptions(),
      );
      expect(_state.data.isEmpty, false);
      expect(_state.data.minValue, 0);
    });

    test('[Candle] Default min value is 0', () {
      final _state = ChartState<void>(
        data: ChartData.fromList([CandleValue<void>(5, 2)]),
        itemOptions: const BarItemOptions(),
      );
      expect(_state.data.isEmpty, false);
      expect(_state.data.minValue, 0);
    });

    test('[Bubble] Default min value is 0', () {
      final _state = ChartState<void>(
        data: ChartData.fromList([BubbleValue<void>(2)]),
        itemOptions: BubbleItemOptions(),
      );
      expect(_state.data.isEmpty, false);
      expect(_state.data.minValue, 0);
    });
  });

  group('Min value tests', () {
    group('Value min value is item', () {
      test('[Bar] Value min value is item', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BarValue<void>(2)], axisMin: 1),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, 1);
      });

      test('[Candle] Value min value is item', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([CandleValue<void>(5, 2)], axisMin: 1),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, 1);
      });

      test('[Bubble] Value min value is item', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BubbleValue<void>(2)], axisMin: 1),
          itemOptions: BubbleItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, 1);
      });
    });

    group('Min value is min value', () {
      test('[Bar] Min value is min value', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BarValue<void>(2)], axisMin: 10),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, 2);
      });

      test('[Candle] Min value is min value', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([CandleValue<void>(2, 5)], axisMin: 10),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, 2);
      });

      test('[Bubble] Min value is min value', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BubbleValue<void>(2)], axisMin: 10),
          itemOptions: BubbleItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, 2);
      });
    });

    group('Min can go negative', () {
      test('[Bar] Min can go negative', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BarValue<void>(-2)], axisMin: 10),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, -2);
      });

      test('[Candle] Min can go negative', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([CandleValue<void>(-2, 5)], axisMin: 10),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, -2);
      });

      test('[Bubble] Min can go negative', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BubbleValue<void>(-2)], axisMin: 10),
          itemOptions: BubbleItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.minValue, -2);
      });
    });
  });

  group('Max value tests', () {
    group('Value max value is item', () {
      test('[Bar] Value max value is item', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BarValue<void>(2)], axisMax: 1),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.maxValue, 2);
      });

      test('[Candle] Value max value is item', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([CandleValue<void>(2, 5)], axisMax: 1),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.maxValue, 5);
      });

      test('[Bubble] Value max value is item', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BubbleValue<void>(2)], axisMax: 1),
          itemOptions: BubbleItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.maxValue, 2);
      });
    });
    group('Max value is max value', () {
      test('[Bar] Max value is max value', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BarValue<void>(2)], axisMax: 10),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.maxValue, 10);
      });

      test('[Candle] Max value is max value', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([CandleValue<void>(2, 5)], axisMax: 10),
          itemOptions: const BarItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.maxValue, 10);
      });

      test('[Bubble] Max value is max value', () {
        final _state = ChartState<void>(
          data: ChartData.fromList([BubbleValue<void>(2)], axisMax: 10),
          itemOptions: BubbleItemOptions(),
        );
        expect(_state.data.isEmpty, false);
        expect(_state.data.maxValue, 10);
      });
    });
  });
}
