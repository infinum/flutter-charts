import 'package:charts_painter/chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Max is extracted from data', () {
    final _data = ChartState(ChartData.fromList(
        [2, 4, 6].map((e) => BarValue<void>(e.toDouble())).toList()));
    expect(_data.maxValue, 6);
    // Min should be 0
    expect(_data.minValue, 0);
  });

  test('Negative data is new min', () {
    final _data = ChartState(ChartData.fromList(
        [-2, 4, 6].map((e) => BarValue<void>(e.toDouble())).toList()));

    expect(_data.minValue, -2);
  });

  test('Value over axis adds to max value', () {
    final _data = ChartState(ChartData.fromList(
      [2, 4, 6].map((e) => BarValue<void>(e.toDouble())).toList(),
      valueAxisMaxOver: 2,
    ));

    expect(_data.maxValue, 8);
  });

  test('Max value is extracted even if there are multiple lists', () {
    final _data = ChartState(
      ChartData(
        [
          [2, 4, 6].map((e) => BarValue<void>(e.toDouble())).toList(),
          [8, 10, 12].map((e) => BarValue<void>(e.toDouble())).toList()
        ],
      ),
      strategy: DefaultDataStrategy(),
    );

    expect(_data.maxValue, 12);
  });

  test('Data can stack on top of each other', () {
    final _data = ChartState(
      ChartData(
        [
          [2, 4, 6].map((e) => BarValue<void>(e.toDouble())).toList(),
          [8, 10, 12].map((e) => BarValue<void>(e.toDouble())).toList()
        ],
      ),
      strategy: StackDataStrategy(),
    );

    expect(_data.maxValue, 18);
  });
}
