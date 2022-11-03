part of charts_painter;

/// Bubble value items max values that are just shown as a point
/// Values can go negative
@Deprecated('Use ChartItem(x, min: x)')
class BubbleValue<T> extends ChartItem<T?> {
  /// Simple bubble value with max value
  BubbleValue(double max) : super(max, min: max);

  /// Bubble value with item `T` and max value
  BubbleValue.withValue(T value, double max) : super(max, value: value, min: max);
}
