part of charts_painter;

/// Bar value items have min locked to 0.0 (or [ChartData.axisMin] if defined)
/// Value for bar item can be negative
@Deprecated('Use ChartItem(x)')
class BarValue<T> extends ChartItem<T?> {
  /// Simple [BarValue] item just with max value.
  BarValue(double max) : super(max);

  /// Bar value, with item `T` and max value
  BarValue.withValue(T value, double max) : super(max, value: value);
}
