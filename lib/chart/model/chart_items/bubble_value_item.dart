part of flutter_charts;

class BubbleValue<T> extends ChartItem<T> {
  BubbleValue(T value, double max) : super(value, max, max);

  @override
  BubbleValue animateTo(ChartItem endValue, double t) {
    return BubbleValue<T>(
      endValue.value,
      lerpDouble(this.max, endValue.max, t),
    );
  }
}
