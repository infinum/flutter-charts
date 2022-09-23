import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

class BubbleChart<T> extends StatelessWidget {
  BubbleChart({
    required this.data,
    required this.dataToValue,
    this.height = 240.0,
    this.itemOptions = const BubbleItemOptions(),
    this.backgroundDecorations,
    this.foregroundDecorations,
    Key? key,
  })  : _mappedValues = [
          data.map((e) => BubbleValue<T>(dataToValue(e))).toList()
              as List<ChartItem<T>>
        ],
        super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;
  final List<List<ChartItem<T>>> _mappedValues;

  final double height;
  final ItemOptions itemOptions;

  final List<DecorationPainter>? backgroundDecorations;
  final List<DecorationPainter>? foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _foregroundDecorations = <DecorationPainter>[];
    final _backgroundDecorations =
        backgroundDecorations ?? <DecorationPainter>[];

    return AnimatedChart<T>(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        ChartData(_mappedValues, valueAxisMaxOver: 5.0),
        itemOptions: itemOptions,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: [
          ..._backgroundDecorations,
        ],
      ),
    );
  }
}
