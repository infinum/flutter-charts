part of flutter_charts;

class CandleValue<T> extends ChartItem<T> {
  CandleValue(double min, double max) : super(null, min, max);
  CandleValue.withValue(T value, double min, double max) : super(value, min, max);

  @override
  CandleValue<T> animateTo<T>(ChartItem<T> endValue, double t) {
    return CandleValue<T>.withValue(
      endValue?.value,
      lerpDouble(this.min, endValue.min, t),
      lerpDouble(this.max, endValue.max, t),
    );
  }
}
