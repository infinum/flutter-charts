part of charts_painter;

/// Bubble painter
GeometryPainter<T> bubblePainter<T>(ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, ChartDataItem chartDataItem) =>
    BubbleGeometryPainter<T>(item, data, itemOptions, chartDataItem as BubbleItem);

typedef BubbleItemBuilder<T> = BubbleItem Function(ChartItem<T?> item, int itemKey, int listKey);

class BubbleItem extends ChartDataItem {
  BubbleItem({this.gradient, this.border, Color? color}) : super(color);

  /// Set gradient color to chart items
  final Gradient? gradient;

  /// Set border to bar items
  final BorderSide? border;

  BubbleItem lerp(BubbleItem endValue, double t) {
    return BubbleItem(
      gradient: Gradient.lerp(gradient, endValue is BubbleItemOptions ? endValue.gradient : null, t),
      border: BorderSide.lerp(border ?? BorderSide.none,
          endValue is BubbleItemOptions ? (endValue.border ?? BorderSide.none) : BorderSide.none, t),
      color: Color.lerp(color, endValue.color, t),
    );
  }

  @override
  List<Object?> get props => [gradient, border, color];
}

/// Extension options for bar items
/// [geometryPainter] is set to [BubbleGeometryPainter]
///
/// Extra options included in [BubbleGeometryPainter] are:
/// [border] Define border width and color
/// [gradient] Item can have gradient color
class BubbleItemOptions extends ItemOptions {
  /// Constructor for bubble item options, has some options just for [BubbleGeometryPainter]
  BubbleItemOptions({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    // Color color = Colors.red,
    ColorForValue? colorForValue,
    bool multiItemStack = true,
    required this.bubbleItemBuilder,
  }) : super(
            colorForValue: colorForValue,
            padding: padding,
            multiValuePadding: multiValuePadding,
            minBarWidth: minBarWidth,
            maxBarWidth: maxBarWidth,
            geometryPainter: bubblePainter,
            multiItemStack: multiItemStack,
            itemBuilder: bubbleItemBuilder);

  BubbleItemOptions._lerp({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    // Color color = Colors.red,
    ColorForValue? colorForValue,
    double multiItemStack = 1.0,
    required this.bubbleItemBuilder,
  }) : super._lerp(
          colorForValue: colorForValue,
          padding: padding,
          multiValuePadding: multiValuePadding,
          minBarWidth: minBarWidth,
          maxBarWidth: maxBarWidth,
          geometryPainter: bubblePainter,
          multiItemStack: multiItemStack,
          itemBuilder: bubbleItemBuilder, // todo lerp
        );

  final BubbleItemBuilder bubbleItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    return BubbleItemOptions._lerp(
      bubbleItemBuilder: endValue is BubbleItemOptions ? endValue.bubbleItemBuilder : bubbleItemBuilder,
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero,
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }

// @override
// Paint getPaintForItem(ChartItem item, Size size, int key) {
//   final _paint = super.getPaintForItem(item, size, key);
//
//   if (gradient != null) {
//     // Compiler complains that gradient could be null. But unless if fails us that will never be null.
//     _paint.shader = gradient!.createShader(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
//   }
//
//   return _paint;
// }
}
