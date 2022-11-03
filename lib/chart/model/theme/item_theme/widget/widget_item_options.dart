part of charts_painter;

// Hidden because it's only used if chart item is a widget.
GeometryPainter<T> _emptyPainter<T>(ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, DrawDataItem drawDataItem) =>
    _EmptyGeometryPainter<T>(item, data, itemOptions);


typedef WidgetItemBuilder<T> = Widget Function(ItemBuilderData<T>);

/// Options for widget items.
///
/// [widgetItemBuilder] returns a [Widget] that will be shown as [ChartItem].
///
/// [multiStackItem] This has effect only if you have multiple lists.
/// Should the items stack one on top of the other. If false items will be shown side by side in single [itemWidth]
///
/// To show basic chart you can just use:
/// ```dart
/// itemOptions: WidgetItemOptions(
///   chartItemBuilder: (data) => Container(color: Colors.red),
/// ),
/// ```
///
/// You can replace your ValueDecoration with [WidgetItemOptions] like this:
/// ```dart
/// itemOptions: WidgetItemOptions(
///  chartItemBuilder: (data) => Container(
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
    required this.widgetItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
  }) : super(
          padding: EdgeInsets.zero,
          multiValuePadding: multiValuePadding,
          geometryPainter: _emptyPainter,
          itemBuilder: widgetItemBuilder,
        );

  const WidgetItemOptions._lerp({
    required this.widgetItemBuilder,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
  }) : super._lerp(
          multiValuePadding: multiValuePadding,
          geometryPainter: _emptyPainter,
          itemBuilder: widgetItemBuilder,
        );

  final WidgetItemBuilder widgetItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    return WidgetItemOptions._lerp(
      widgetItemBuilder: endValue is WidgetItemOptions ? endValue.widgetItemBuilder : widgetItemBuilder,
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero
    );
  }
}
