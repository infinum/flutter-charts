part of flutter_charts;

class BubbleValue<T> extends ChartItem<T> {
  BubbleValue(double max) : super(null, max, max);
  BubbleValue.withValue(T value, double max) : super(value, max, max);
}
