part of flutter_charts;

class BarValue<T> extends ChartItem<T> {
  BarValue(T value, double max) : super(value, null, max);

  @override
  BarValue animateTo(ChartItem endValue, double t) {
    return BarValue<T>(
      endValue.value,
      lerpDouble(this.max, endValue.max, t),
    );
  }
}
