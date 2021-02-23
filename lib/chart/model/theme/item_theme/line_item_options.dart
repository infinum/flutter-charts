part of flutter_charts;

/// Bubble painter
GeometryPainter<T> bubblePainter<T>(ChartItem<T> item, ChartState<T> state) => BubbleGeometryPainter<T>(item, state);

/// Options for [BubbleGeometryPainter]
class BubbleItemOptions extends ItemOptions {
  const BubbleItemOptions({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double maxBarWidth,
    double minBarWidth,
    Color color = Colors.red,
    ColorForValue colorForValue,
    ColorForKey colorForKey,
    this.gradient,
    this.border,
  }) : super(
          color: color,
          colorForValue: colorForValue,
          colorForKey: colorForKey,
          padding: padding,
          multiValuePadding: multiValuePadding,
          minBarWidth: minBarWidth,
          maxBarWidth: maxBarWidth,
          geometryPainter: bubblePainter,
        );

  final Gradient gradient;
  final BorderSide border;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    return BubbleItemOptions(
      gradient: Gradient.lerp(gradient, endValue is BubbleItemOptions ? endValue.gradient : null, t),
      color: Color.lerp(color, endValue.color, t),
      colorForKey: ColorForKeyLerp.lerp(this, endValue, t),
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t),
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t),
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      border: BorderSide.lerp(border ?? BorderSide.none,
          endValue is BubbleItemOptions ? (endValue.border ?? BorderSide.none) : BorderSide.none, t),
    );
  }

  @override
  Paint getPaintForItem(ChartItem<Object> item, Size size, int key) {
    final _paint = super.getPaintForItem(item, size, key);

    if (gradient != null) {
      _paint..shader = gradient.createShader(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    return _paint;
  }
}
