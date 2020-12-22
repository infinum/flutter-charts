part of flutter_charts;

class CandleValue<T> extends ChartItem<T> {
  CandleValue(T value, double min, double max) : super(value, min, max);

  @override
  CandleValue animateTo(ChartItem endValue, double t) {
    return CandleValue<T>(
      endValue.value,
      lerpDouble(this.max, endValue.max, t),
      lerpDouble(this.min, endValue.min, t),
    );
  }
}
