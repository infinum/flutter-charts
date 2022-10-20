part of charts_painter;

/// Bubble painter
GeometryPainter<T> bubblePainter<T>(
        ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, ChartDataItem chartDataItem) =>
    BubbleGeometryPainter<T>(item, data, itemOptions, chartDataItem as BubbleItem);

typedef BubbleItemBuilder<T> = BubbleItem Function(ChartItem<T?> item, int itemKey, int listKey);

class BubbleItem extends ChartDataItem {
  BubbleItem({Gradient? gradient, BorderSide? border, Color? color})
      : super(color: color, gradient: gradient, border: border);

  BubbleItem lerp(BubbleItem endValue, double t) {
    return BubbleItem(
      gradient: Gradient.lerp(gradient, endValue is BubbleItemOptions ? endValue.gradient : null, t),
      border: BorderSide.lerp(border, endValue is BubbleItemOptions ? (endValue.border) : BorderSide.none, t),
      color: Color.lerp(color, endValue.color, t),
    );
  }

  @override
  List<Object?> get props => [gradient, border, color];
}

class BubbleItemBuilderLerp {
  /// Make new function that will return lerp [ItemOptions] based on [ChartState.itemOptionsBuilder]
  static BubbleItemBuilder lerp(BubbleItemOptions a, BubbleItemOptions b, double t) {
    return (ChartItem item, int itemKey, int listKey) {
      final _aItem = a.bubbleItemBuilder(item, itemKey, listKey);
      final _bItem = b.bubbleItemBuilder(item, itemKey, listKey);
      return _aItem.lerp(_bItem, t);
    };
  }
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
    double multiItemStack = 1.0,
    required this.bubbleItemBuilder,
  }) : super._lerp(
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
    if (endValue is BubbleItemOptions) {
      return BubbleItemOptions._lerp(
        bubbleItemBuilder: BubbleItemBuilderLerp.lerp(this, endValue, t),
        padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
        multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero,
        maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
        minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
        multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
      );
    } else {
      return endValue;
    }
  }
}
