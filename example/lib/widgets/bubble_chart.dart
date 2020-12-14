import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

String defaultAxisValues(int item) => '$item';

class BubbleChart<T> extends StatelessWidget {
  const BubbleChart({
    @required this.data,
    @required this.dataToValue,
    this.height = 240.0,
    this.chartOptions,
    this.itemOptions,
    this.backgroundDecorations,
    this.foregroundDecorations,
    Key key,
  }) : super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;

  final double height;
  final ChartOptions chartOptions;
  final ChartItemOptions itemOptions;

  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _foregroundDecorations = <DecorationPainter>[];
    final _backgroundDecorations = backgroundDecorations ?? <DecorationPainter>[];

    // Map values
    final _values = data.map((e) => BubbleValue(dataToValue(e))).toList();

    return AnimatedChart(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState(
        _values,
        options: chartOptions,
        itemOptions: itemOptions,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: [
          ..._backgroundDecorations,
        ],
      ),
    );
  }
}
