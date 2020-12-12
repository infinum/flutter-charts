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
    this.targetValueMax,
    this.targetValueMin,
    this.valueAxisStep,
    this.minValue,
    this.maxValue,
    this.colorForValue,
    this.backgroundDecorations,
    this.itemColor,
    this.targetOverColor,
    this.itemPadding,
    this.isTargetInclusive = true,
    this.maxBarWidth,
    this.itemRadius,
    Key key,
  }) : super(key: key);

  final List<T> data;
  final DataToValue<T> dataToValue;

  final double height;

  final double minValue;
  final double maxValue;
  final double targetValueMax;
  final double targetValueMin;

  final double valueAxisStep;

  final ColorForValue colorForValue;

  final Color targetOverColor;
  final Color itemColor;

  final EdgeInsets itemPadding;
  final bool isTargetInclusive;
  final BorderRadius itemRadius;
  final double maxBarWidth;

  final List<DecorationPainter> backgroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _foregroundDecorations = <DecorationPainter>[];
    final _backgroundDecorations = backgroundDecorations ?? <DecorationPainter>[];

    if (targetValueMin != null && targetValueMax != null) {
      print('Not null');
      _backgroundDecorations.add(TargetAreaDecoration(
        dashArray: [15, 10],
        lineWidth: 1.0,
        targetColor: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
        targetAreaRadius: BorderRadius.circular(8.0),
        targetAreaFillColor: Theme.of(context).colorScheme.background.withOpacity(0.6),
      ));
    } else if (targetValueMin != null || targetValueMax != null) {
      _foregroundDecorations.add(TargetLineDecoration(
        dashArray: [15, 10],
        lineWidth: 1.0,
        targetColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.7),
      ));
    }

    // Map values
    final _values = data.map(dataToValue).toList();

    // Chart options
    final _options = ChartOptions(
      valueAxisMax: maxValue ?? (targetValueMax ?? valueAxisStep ?? 2.0) * 1.1,
      axisLegendTextColor: Theme.of(context).colorScheme.primary,
      valueAxisMin: minValue,
      padding: EdgeInsets.only(right: 36.0),
    );

    return AnimatedChart(
      height: height,
      duration: const Duration(milliseconds: 450),
      state: ChartState(
        _values,
        options: _options,
        itemOptions: ChartItemOptions(
          maxBarWidth: maxBarWidth,
          color: itemColor ?? Theme.of(context).accentColor,
          targetOverColor: targetOverColor ?? Theme.of(context).errorColor,
          targetMax: targetValueMax,
          targetMin: targetValueMin,
          isTargetInclusive: isTargetInclusive,
          colorForValue: colorForValue,
          radius: itemRadius,
          padding: itemPadding,
        ),
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: [
          ..._backgroundDecorations,
        ],
      ),
    );
  }
}
