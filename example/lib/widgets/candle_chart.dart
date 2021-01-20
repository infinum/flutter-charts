import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

typedef DataToValue<T> = CandleValue<T> Function(T item);
typedef DataToAxis<T> = String Function(int item);

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
    this.itemPainter = barItemPainter,
    Key key,
  })  : _mappedValues = {0: data.map(dataToValue).toList()},
        super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;

  final double height;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;
  final ChartBehaviour chartBehaviour;
  final ChartOptions chartOptions;
  final ChartItemOptions chartItemOptions;
  final ChartItemPainter itemPainter;

  final Map<int, List<CandleValue<T>>> _mappedValues;

  @override
  Widget build(BuildContext context) {
    return AnimatedChart<T>(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        _mappedValues,
        options: chartOptions,
        itemOptions: chartItemOptions,
        behaviour: chartBehaviour,
        itemPainter: itemPainter,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: backgroundDecorations,
      ),
    );
  }
}
