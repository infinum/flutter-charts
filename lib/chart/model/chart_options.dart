part of flutter_charts;

/// Modifiers for chart, some of decoration thins are included here,
/// ex. setting [gridColor] will modify how [GridDecoration] will paint its grid
class ChartOptions {
  const ChartOptions({
    this.padding,
    this.valueAxisMax,
    this.valueAxisMin,
    this.axisLegendTextColor,
  });

  final EdgeInsets padding;

  /// Max value that chart should show, in case that [valueAxisMax] is bellow
  /// the value of value passed with data in the chart this will be ignored.
  final double valueAxisMax;

  /// Min value of the chart, anything below that will not be shown and chart
  /// x axis will start from [valueAxisMin] (default: 0)
  final double valueAxisMin;

  /// Text color for Text on the right and below the chart
  final Color axisLegendTextColor;

  static ChartOptions lerp(ChartOptions a, ChartOptions b, double t) {
    return ChartOptions(
      valueAxisMax: lerpDouble(a?.valueAxisMax, b?.valueAxisMax, t),
      valueAxisMin: lerpDouble(a?.valueAxisMin, b?.valueAxisMin, t),
      axisLegendTextColor: Color.lerp(a?.axisLegendTextColor, b?.axisLegendTextColor, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
    );
  }
}
