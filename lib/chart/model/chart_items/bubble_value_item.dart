part of flutter_charts;

class BubbleValue extends ChartItem {
  BubbleValue(double value) : super(value, value);

  @override
  BubbleValue animateTo(ChartItem endValue, double t) {
    return BubbleValue(
      lerpDouble(this.max, endValue.max, t),
    );
  }
}
