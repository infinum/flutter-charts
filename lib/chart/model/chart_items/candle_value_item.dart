part of flutter_charts;

class CandleValue extends ChartItem {
  CandleValue(double max, double min) : super(min, max);

  @override
  CandleValue animateTo(ChartItem endValue, double t) {
    return CandleValue(
      lerpDouble(this.max, endValue.max, t),
      lerpDouble(this.min, endValue.min, t),
    );
  }
}
