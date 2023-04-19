part of charts_painter;

/// Candle value items have min and max set up
/// Values can go negative
@Deprecated('Use ChartItem(x, min: y)')
class CandleValue<T> extends ChartItem<T?> {
  /// Simple candle value with min and max values
  CandleValue(double min, double max) : super(max, min: min, value: null);

  /// Candle value with item `T`, min and max value
  CandleValue.withValue(T value, double min, double max)
      : super(max, value: value, min: min);
}
