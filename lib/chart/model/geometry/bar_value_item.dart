part of flutter_charts;

/// Bar value items have min locked to 0.0 (or [ChartOptions.verticalAxisMin] if defined)
/// Value for bar item can be negative
class BarValue<T> extends ChartItem<T> {
  BarValue(double max) : super(null, null, max);
  BarValue.withValue(T value, double max) : super(value, null, max);
}
