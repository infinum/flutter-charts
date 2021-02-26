part of charts_painter;

/// Candle value items have min and max set up
/// Values can go negative
class CandleValue<T> extends ChartItem<T> {
  /// Simple candle value with min and max values
  CandleValue(double min, double max) : super(null, min, max);

  /// Candle value with item `T`, min and max value
  CandleValue.withValue(T value, double min, double max)
      : super(value, min, max);
}
