part of charts_painter;

/// Bubble painter
GeometryPainter<T> bubblePainter<T>(ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions) =>
    BubbleGeometryPainter<T>(item, data, itemOptions);

/// Extension options for bar items [geometryPainter] is set to [BubbleGeometryPainter]
///
/// Extra options included in [BubbleGeometryPainter] are:
/// [border] Define border width and color
/// [gradient] Items can have gradient color, in order to change gradient for different lists use [ChartState.itemOptionsBuilder]
///
/// If more customization is needed see [WidgetItemOptions]
class BubbleItemOptions extends ItemOptions {
  /// Constructor for bubble item options, has some options just for [BubbleGeometryPainter]
  const BubbleItemOptions({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    Color color = Colors.red,
    ColorForValue? colorForValue,
    bool multiItemStack = true,
    this.gradient,
    this.border,
  }) : super(
          color: color,
          colorForValue: colorForValue,
          padding: padding,
          multiValuePadding: multiValuePadding,
          minBarWidth: minBarWidth,
          maxBarWidth: maxBarWidth,
          geometryPainter: bubblePainter,
          multiItemStack: multiItemStack,
        );

  /// Separate lerp constructor because we would like to animate the change of [multiItemStack]
  const BubbleItemOptions._lerp({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    Color color = Colors.red,
    ColorForValue? colorForValue,
    double multiItemStack = 1.0,
    this.gradient,
    this.border,
  }) : super._lerp(
          color: color,
          colorForValue: colorForValue,
          padding: padding,
          multiValuePadding: multiValuePadding,
          minBarWidth: minBarWidth,
          maxBarWidth: maxBarWidth,
          geometryPainter: bubblePainter,
          multiItemStack: multiItemStack,
        );

  /// Set gradient for each bubble item
  final Gradient? gradient;

  /// Draw border on bubble items
  final BorderSide? border;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    return BubbleItemOptions._lerp(
      gradient: Gradient.lerp(gradient, endValue is BubbleItemOptions ? endValue.gradient : null, t),
      color: Color.lerp(color, endValue.color, t) ?? endValue.color,
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero,
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      border: BorderSide.lerp(border ?? BorderSide.none,
          endValue is BubbleItemOptions ? (endValue.border ?? BorderSide.none) : BorderSide.none, t),
      multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }

  @override
  Paint getPaintForItem(ChartItem item, Size size, int key) {
    final _paint = super.getPaintForItem(item, size, key);

    if (gradient != null) {
      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    return _paint;
  }
}
