import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

typedef DataToValue<T> = CandleValue Function(T item);
typedef DataToAxis<T> = String Function(int item);

String defaultAxisValues(int item) => '$item';

class CandleChart<T> extends StatelessWidget {
  const CandleChart({
    @required this.data,
    @required this.dataToValue,
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.chartBehaviour,
    this.chartOptions,
    this.chartItemOptions,
    this.foregroundDecorations = const [],
    Key key,
  }) : super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;

  final double height;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;
  final ChartBehaviour chartBehaviour;
  final ChartOptions chartOptions;
  final ChartItemOptions chartItemOptions;

  @override
  Widget build(BuildContext context) {
    // Map values
    final _values = data.map(dataToValue).toList();

    return AnimatedChart(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState(
        _values,
        options: chartOptions,
        itemOptions: chartItemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: backgroundDecorations,
      ),
    );
  }
}
