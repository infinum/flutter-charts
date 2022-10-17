part of charts_painter;

// Hidden because it's only used if chart item is a widget.
GeometryPainter<T> _emptyPainter<T>(
        ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions) =>
    _EmptyGeometryPainter<T>(item, data, itemOptions);

/// Extension options for bar items
/// [geometryPainter] is set to [BarGeometryPainter]
///
/// Extra options included in [BarGeometryPainter] are:
/// [radius] Define corner radius for each bar item
/// [border] Define border width and color
/// [gradient] Item can have gradient color
class WidgetItemOptions extends ItemOptions {
  /// Constructor for bar item options, has some extra options just for [BarGeometryPainter]
  const WidgetItemOptions({
    required this.chartItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    bool multiItemStack = true,
  }) : super(
          color: Colors.transparent,
          colorForValue: null,
          padding: EdgeInsets.zero,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          geometryPainter: _emptyPainter,
          multiItemStack: multiItemStack,
        );

  const WidgetItemOptions._lerp({
    required this.chartItemBuilder,
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    double startPosition = 0.5,
    Color color = Colors.red,
    ColorForValue? colorForValue,
    double multiItemStack = 1.0,
  }) : super._lerp(
          color: color,
          colorForValue: colorForValue,
          padding: padding,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          startPosition: startPosition,
          geometryPainter: _emptyPainter,
          multiItemStack: multiItemStack,
        );

  final ChildChartItemBuilder chartItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    final _itemColor = Color.lerp(color, endValue.color, t) ?? Colors.red;

    return WidgetItemOptions._lerp(
      color: _itemColor,
      chartItemBuilder: endValue is WidgetItemOptions
          ? endValue.chartItemBuilder
          : chartItemBuilder,
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
      multiValuePadding:
          EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ??
              EdgeInsets.zero,
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      startPosition:
          lerpDouble(startPosition, endValue.startPosition, t) ?? 0.5,
      multiItemStack:
          lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }

  @override
  Paint getPaintForItem(ChartItem item, Size size, int key) {
    return Paint();
  }
}
