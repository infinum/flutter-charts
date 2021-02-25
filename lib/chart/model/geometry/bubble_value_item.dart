part of charts_painter;

/// Bubble value items max values that are just shown as a point
/// Values can go negative
class BubbleValue<T> extends ChartItem<T> {
  /// Simple bubble value with max value
  BubbleValue(double max) : super(null, max, max);

  /// Bubble value with item `T` and max value
  BubbleValue.withValue(T value, double max) : super(value, max, max);
}
