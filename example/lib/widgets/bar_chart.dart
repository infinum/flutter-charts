import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

String defaultAxisValues(int item) => '$item';

class BarChart<T> extends StatelessWidget {
  BarChart({
    @required this.data,
    @required this.dataToValue,
    this.height = 240.0,
    this.backgroundDecorations,
    this.foregroundDecorations,
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const ChartItemOptions(),
    this.chartOptions = const ChartOptions(),
    Key key,
  })  : _mappedValues = data.map((e) => BarValue(dataToValue(e))).toList().asMap(),
        super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;
  final Map<int, BarValue> _mappedValues;
  final double height;

  final ChartItemOptions itemOptions;
  final ChartOptions chartOptions;
  final ChartBehaviour chartBehaviour;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _foregroundDecorations = foregroundDecorations ?? <DecorationPainter>[];
    final _backgroundDecorations = backgroundDecorations ?? <DecorationPainter>[];

    return AnimatedChart(
      height: height,
      width: MediaQuery.of(context).size.width - 24.0,
      duration: const Duration(milliseconds: 450),
      state: ChartState(
        _mappedValues,
        options: chartOptions,
        itemOptions: itemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: [
          ..._backgroundDecorations,
        ],
      ),
    );
  }
}
