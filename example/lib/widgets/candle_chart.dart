import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DataToValue<T> = CandleValue<T> Function(T item);
typedef DataToAxis<T> = String Function(int item);

class CandleChart<T> extends StatelessWidget {
  CandleChart({
    @required this.data,
    @required this.dataToValue,
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.chartBehaviour,
    this.chartItemOptions,
    this.foregroundDecorations = const [],
    this.geometryPainter = barPainter,
    Key key,
  })  : _mappedValues = [data.map(dataToValue).toList()],
        super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;

  final double height;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;
  final ChartBehaviour chartBehaviour;
  final ItemOptions chartItemOptions;
  final ChartGeometryPainter geometryPainter;

  final List<List<CandleValue<T>>> _mappedValues;

  @override
  Widget build(BuildContext context) {
    return AnimatedChart<T>(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        ChartData(_mappedValues),
        itemOptions: chartItemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: backgroundDecorations,
      ),
    );
  }
}
