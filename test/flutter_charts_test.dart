import 'package:flutter_charts/chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('[ChartState] Chart state', () {
    group('[ChartState] Default min value is 0', () {
      test('[Bar] Default min value is 0', () {
        final _state = ChartState([BarValue(2)]);
        expect(_state.items.isEmpty, false);
        expect(_state.minValue, 0);
      });

      test('[Candle] Default min value is 0', () {
        final _state = ChartState([CandleValue(5, 2)]);
        expect(_state.items.isEmpty, false);
        expect(_state.minValue, 0);
      });

      test('[Bubble] Default min value is 0', () {
        final _state = ChartState([BubbleValue(2)]);
        expect(_state.items.isEmpty, false);
        expect(_state.minValue, 0);
      });
    });

    group('[ChartState] Min value tests', () {
      group('[ChartState] Value min value is item', () {
        test('[Bar] Value min value is item', () {
          final _state = ChartState([BarValue(2)], options: const ChartOptions(valueAxisMin: 1));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, 1);
        });

        test('[Candle] Value min value is item', () {
          final _state = ChartState([CandleValue(5, 2)], options: const ChartOptions(valueAxisMin: 1));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, 1);
        });

        test('[Bubble] Value min value is item', () {
          final _state = ChartState([BubbleValue(2)], options: const ChartOptions(valueAxisMin: 1));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, 1);
        });
      });
      group('[ChartState] Min value is min value', () {
        test('[Bar] Min value is min value', () {
          final _state = ChartState([BarValue(2)], options: const ChartOptions(valueAxisMin: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, 2);
        });

        test('[Candle] Min value is min value', () {
          final _state = ChartState([CandleValue(5, 2)], options: const ChartOptions(valueAxisMin: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, 2);
        });

        test('[Bubble] Min value is min value', () {
          final _state = ChartState([BubbleValue(2)], options: const ChartOptions(valueAxisMin: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, 2);
        });
      });
      group('[ChartState] Min can go negative', () {
        test('[Bar] Min can go negative', () {
          final _state = ChartState([BarValue(-2)], options: const ChartOptions(valueAxisMin: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, -2);
        });

        test('[Candle] Min can go negative', () {
          final _state = ChartState([CandleValue(5, -2)], options: const ChartOptions(valueAxisMin: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, -2);
        });

        test('[Bubble] Min can go negative', () {
          final _state = ChartState([BubbleValue(-2)], options: const ChartOptions(valueAxisMin: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.minValue, -2);
        });
      });
    });

    group('[ChartState] Max value tests', () {
      group('[ChartState] Value max value is item', () {
        test('[Bar] Value max value is item', () {
          final _state = ChartState([BarValue(2)], options: const ChartOptions(valueAxisMax: 1));
          expect(_state.items.isEmpty, false);
          expect(_state.maxValue, 2);
        });

        test('[Candle] Value max value is item', () {
          final _state = ChartState([CandleValue(5, 2)], options: const ChartOptions(valueAxisMax: 1));
          expect(_state.items.isEmpty, false);
          expect(_state.maxValue, 5);
        });

        test('[Bubble] Value max value is item', () {
          final _state = ChartState([BubbleValue(2)], options: const ChartOptions(valueAxisMax: 1));
          expect(_state.items.isEmpty, false);
          expect(_state.maxValue, 2);
        });
      });
      group('[ChartState] Max value is max value', () {
        test('[Bar] Max value is max value', () {
          final _state = ChartState([BarValue(2)], options: const ChartOptions(valueAxisMax: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.maxValue, 10);
        });

        test('[Candle] Max value is max value', () {
          final _state = ChartState([CandleValue(5, 2)], options: const ChartOptions(valueAxisMax: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.maxValue, 10);
        });

        test('[Bubble] Max value is max value', () {
          final _state = ChartState([BubbleValue(2)], options: const ChartOptions(valueAxisMax: 10));
          expect(_state.items.isEmpty, false);
          expect(_state.maxValue, 10);
        });
      });
    });
  });

  group('[Animation] Chart animation', () {
    test('[Animation] Lerp items, min, max', () {
      final _firstState = ChartState([BarValue(10)]);
      final _secondState = ChartState(
        [BarValue(10), BarValue(20), BarValue(15)],
        options: const ChartOptions(valueAxisMin: 10),
      );

      expect(_firstState.items.length, 1);
      expect(_firstState.maxValue, 10);
      expect(_firstState.minValue, 0);

      expect(_secondState.items.length, 3);
      expect(_secondState.maxValue, 20);
      expect(_secondState.minValue, 10);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);
      expect(_middleState.items.length, 2);
      expect(_middleState.maxValue, 15);
      expect(_middleState.minValue, 5);
    });

    test('[Animation] Animation animates items', () {
      final _firstState = ChartState([BarValue(10)]);
      final _secondState = ChartState([BarValue(20), BarValue(10), BarValue(5)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      expect(_middleState.items, [BarValue(15), BarValue(5)]);
    });

    test('[Animation] Bar -> Bubble animates different type items', () {
      final _firstState = ChartState([BarValue(10)]);
      final _secondState = ChartState([BubbleValue(20)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items, [BubbleValue(15)]);
    });

    test('[Animation] Bubble -> Bar animates different type items', () {
      final _firstState = ChartState([BubbleValue(10)]);
      final _secondState = ChartState([BarValue(20)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items, [BarValue(15)]);
    });

    test('[Animation] Bar -> Candle animates different type items', () {
      final _firstState = ChartState([BarValue(10)]);
      final _secondState = ChartState([CandleValue(20, 10)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items, [CandleValue(15, 5)]);
    });

    test('[Animation] Candle -> Bar animates different type items', () {
      final _firstState = ChartState([CandleValue(20, 10)]);
      final _secondState = ChartState([BarValue(10)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items, [BarValue(15)]);
    });

    test('[Animation] Bubble -> Candle animates different type items', () {
      final _firstState = ChartState([BubbleValue(10)]);
      final _secondState = ChartState([CandleValue(20, 10)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items, [CandleValue(15, 10)]);
    });

    test('[Animation] Candle -> Bubble animates different type items', () {
      final _firstState = ChartState([CandleValue(20, 10)]);
      final _secondState = ChartState([BubbleValue(10)]);

      final _middleState = ChartState.lerp(_firstState, _secondState, 0.5);

      // Animating to second state, so second item type has to be used
      expect(_middleState.items, [BubbleValue(15)]);
    });
  });
}
