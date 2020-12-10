part of flutter_charts;

class BarValue extends ChartItem {
  BarValue(double value) : super(null, value);

  @override
  BarValue animateTo(ChartItem endValue, double t) {
    return BarValue(
      lerpDouble(this.max, endValue.max, t),
    );
  }
}
