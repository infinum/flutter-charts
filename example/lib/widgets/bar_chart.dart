import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

/// Short-hand to easier create several bar charts
class BarChart<T> extends StatelessWidget {
  BarChart({
    required List<T> data,
    required DataToValue<T> dataToValue,
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.stack = false,
    Key? key,
  })  : _mappedValues = [data.map((e) => BarValue<T>(dataToValue(e))).toList()],
        super(key: key);

  const BarChart.map(
    this._mappedValues, {
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.stack = false,
    Key? key,
  }) : super(key: key);

  final List<List<BarValue<T>>> _mappedValues;
  final double height;

  final bool stack;
  final ItemOptions itemOptions;
  final ChartBehaviour chartBehaviour;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _data = ChartData<T>(
      _mappedValues,
      valueAxisMaxOver: 1,
      dataStrategy: stack
          ? StackDataStrategy()
          : DefaultDataStrategy(stackMultipleValues: false),
    );

    return AnimatedChart<T>(
      height: height,
      width: MediaQuery.of(context).size.width - 24.0,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        data: _data,
        itemOptions: itemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: [
          ...backgroundDecorations,
        ],
      ),
    );
  }
}
