part of charts_painter;

// Hidden because it's only used if chart item is a widget.
GeometryPainter<T> _emptyPainter<T>(
        ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, ChartDataItem chartDataItem) =>
    _EmptyGeometryPainter<T>(item, data, itemOptions);

/// Options for widget items
///
/// There options include a [chartItemBuilder] where you need to return a [Widget] that
/// will be shown as [ChartItem].
///
/// Other options are reverted to 0 since you can set everything in the builder.
class WidgetItemOptions extends ItemOptions {
  /// Constructor for bar item options, has some extra options just for [BarGeometryPainter]
  const WidgetItemOptions({
    required this.chartItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    bool multiItemStack = true,
  }) : super(
          // color: Colors.transparent,
          colorForValue: null,
          padding: EdgeInsets.zero,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          geometryPainter: _emptyPainter,
          multiItemStack: multiItemStack,
          itemBuilder: chartItemBuilder,
        );

  const WidgetItemOptions._lerp({
    required this.chartItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    double multiItemStack = 1.0,
  }) : super._lerp(
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          geometryPainter: _emptyPainter,
          multiItemStack: multiItemStack,
          itemBuilder: chartItemBuilder,
        );

  final ChildChartItemBuilder chartItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    return WidgetItemOptions._lerp(
      chartItemBuilder: endValue is WidgetItemOptions ? endValue.chartItemBuilder : chartItemBuilder,
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero,
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }
//
// @override
// Paint getPaintForItem(ChartItem item, Size size, int key) {
//   return Paint();
// }
}
