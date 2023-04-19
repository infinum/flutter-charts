import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

/// Short-hand to easier create several bubble charts
class BubbleChart<T> extends StatelessWidget {
  BubbleChart({
    required this.data,
    required this.dataToValue,
    this.height = 240.0,
    this.itemOptions = const BarItemOptions(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    Key? key,
  })  : _mappedValues = [
          data.map((e) => BubbleValue<T>(dataToValue(e))).toList()
        ],
        super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;
  final List<List<BubbleValue<T>>> _mappedValues;

  final double height;
  final ItemOptions itemOptions;

  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    return AnimatedChart<T>(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        data: ChartData(_mappedValues, valueAxisMaxOver: 5.0),
        itemOptions: itemOptions,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: [
          ...backgroundDecorations,
        ],
      ),
    );
  }
}
