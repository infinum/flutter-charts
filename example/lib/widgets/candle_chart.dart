import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

typedef DataToValue<T> = CandleValue Function(T item);
typedef DataToAxis<T> = String Function(int item);

String defaultAxisValues(int item) => '$item';

class CandleChart<T> extends StatelessWidget {
  CandleChart({
    @required this.data,
    @required this.dataToValue,
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.chartBehaviour,
    this.chartOptions,
    this.chartItemOptions,
    this.foregroundDecorations = const [],
    Key key,
  })  : _mappedValues = data.map(dataToValue).toList().asMap(),
        super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;

  final double height;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;
  final ChartBehaviour chartBehaviour;
  final ChartOptions chartOptions;
  final ChartItemOptions chartItemOptions;

  final Map<int, CandleValue> _mappedValues;

  @override
  Widget build(BuildContext context) {
    return AnimatedChart(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState(
        _mappedValues,
        options: chartOptions,
        itemOptions: chartItemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: backgroundDecorations,
      ),
    );
  }
}
