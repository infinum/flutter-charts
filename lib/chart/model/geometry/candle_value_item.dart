part of flutter_charts;

class CandleValue<T> extends ChartItem<T> {
  CandleValue(double min, double max) : super(null, min, max);
  CandleValue.withValue(T value, double min, double max) : super(value, min, max);
}
