part of flutter_charts;

/// Options that have effect on whole chart.
/// [padding] - Chart padding, this will affect whole chart and all decorations.
/// [valueAxisMin] - Min value that has to be displayed on the chart, if data contains value that is
/// lower than [valueAxisMin] in that case [valueAxisMin] is ignored and actual min value is shown.
/// [valueAxisMax] - Same as [valueAxisMin] but for max value.
class ChartOptions {
  const ChartOptions({
    this.padding,
    this.valueAxisMax,
    this.valueAxisMin,
  });

  final EdgeInsets padding;

  /// Max value that chart should show, in case that [valueAxisMax] is bellow
  /// the value of value passed with data in the chart this will be ignored.
  final double valueAxisMax;

  /// Min value of the chart, anything below that will not be shown and chart
  /// x axis will start from [valueAxisMin] (default: 0)
  final double valueAxisMin;

  static ChartOptions lerp(ChartOptions a, ChartOptions b, double t) {
    return ChartOptions(
      valueAxisMax: lerpDouble(a?.valueAxisMax, b?.valueAxisMax, t),
      valueAxisMin: lerpDouble(a?.valueAxisMin, b?.valueAxisMin, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
    );
  }
}
