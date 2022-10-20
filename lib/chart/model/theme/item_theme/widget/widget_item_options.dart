part of charts_painter;

// Hidden because it's only used if chart item is a widget.
GeometryPainter<T> _emptyPainter<T>(ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, DrawDataItem drawDataItem) =>
    _EmptyGeometryPainter<T>(item, data, itemOptions);

/// Options for widget items.
///
/// **You cannot pass this to [ChartState.itemOptionsBuilder]**, since builder already has the list key,
/// there is no need to use the builder. Use just [ChartState.itemOptions] instead.
///
/// [chartItemBuilder] return a [Widget] that will be shown as [ChartItem].
///
/// [multiStackItem] This has effect only if you have multiple lists.
/// Should the items stack one on top of the other. If false items will be shown side by side in single [itemWidth]
///
/// To show basic chart you can just use:
/// ```dart
/// itemOptions: WidgetItemOptions(
///   chartItemBuilder: (item, itemKey, listKey) => Container(color: Colors.red),
/// ),
/// ```
///
/// You can replace your [ValueDecoration] with [WidgetItemOptions] like this:
/// ```dart
/// itemOptions: WidgetItemOptions(
///  chartItemBuilder: (item, itemKey, listKey) => Container(
///   color: Colors.red,
///   child: Center(
///     child: Text(
///       '${item.max?.toString()}',
///       style: TextStyle(color: Colors.white),
///     ),
///   ),
///  ),
/// ),
/// ```
///
/// Other options are reverted to 0 since you can set everything in the builder.
///
class WidgetItemOptions extends ItemOptions {
  /// Constructor for bar item options, has some extra options just for [BarGeometryPainter]
  const WidgetItemOptions({
    required this.chartItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    bool multiItemStack = true,
  }) : super(
          padding: EdgeInsets.zero,
          multiValuePadding: multiValuePadding,
          geometryPainter: _emptyPainter,
          multiItemStack: multiItemStack,
          itemBuilder: chartItemBuilder,
        );

  const WidgetItemOptions._lerp({
    required this.chartItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double multiItemStack = 1.0,
  }) : super._lerp(
          multiValuePadding: multiValuePadding,
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
      multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }
//
// @override
// Paint getPaintForItem(ChartItem item, Size size, int key) {
//   return Paint();
// }
}
