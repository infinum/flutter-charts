part of flutter_charts;

class BarValue<T> extends ChartItem<T> {
  BarValue(double max) : super(null, null, max);
  BarValue.withValue(T value, double max) : super(value, null, max);

  @override
  BarValue animateTo(ChartItem endValue, double t) {
    return BarValue<T>.withValue(
      endValue.value,
      lerpDouble(this.max, endValue.max, t),
    );
  }
}
