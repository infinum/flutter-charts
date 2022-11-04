part of charts_painter;

/// Item painter, use [barPainter] or [bubblePainter].
/// Custom painter can also be added by extending [GeometryPainter]
typedef ChartGeometryPainter<T> = GeometryPainter<T> Function(
  ChartItem<T?> item,
  ChartData data,
  ItemOptions itemOptions,
  DrawDataItem drawDataItem,
);

/// Options for chart items. You can use this subclasses: [BarItemOptions], [BubbleItemOptions], [WidgetItemOptions]
///
/// Required [itemBuilder] parameter is used to provide a data for each item on the chart.
///
/// Required [geometryPainter] specifies how to draw these items on the chart.
///
/// Extend this to make your custom options or painters if needed.
///
/// [WidgetItemOptions] is only [ItemOptions] that is not using [geometryPainter] and
/// instead is passing [_EmptyGeometryPainter] as the painter, and defaulting all other values to 0.0.
abstract class ItemOptions {
  /// Default constructor for ItemOptions
  /// It's recommended to make/use custom item options for custom painters.
  const ItemOptions({
    required this.geometryPainter,
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.maxBarWidth,
    this.minBarWidth,
    this.startPosition = 0.5,
    required this.itemBuilder,
  });

  const ItemOptions._lerp({
    required this.geometryPainter,
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.maxBarWidth,
    this.minBarWidth,
    this.startPosition = 0.5,
    required this.itemBuilder,
  });

  /// Item padding, if [minBarWidth] and [padding] are more then available space
  /// [padding] will get ignored
  final EdgeInsets padding;

  /// Multi value chart padding, this will `group` values with same index from different lists
  /// use to make space between index changes in multi value charts
  /// Only used for multiple data lists when they are not stacked
  final EdgeInsets multiValuePadding;

  final ItemBuilder itemBuilder;

  /// Define color for value, this allows different colors for different values

  /// Max width of item in the chart
  final double? maxBarWidth;

  /// Min width of item in the chart
  final double? minBarWidth;

  /// Set start position.
  /// This value ranges from 0.0 - 1.0.
  ///
  /// 0.0 means that start position is left most point of the item,
  /// 1.0 means right most point.
  ///
  /// By default this is set to 0.5, so items are located in center
  final double startPosition;

  /// Geometry
  final ChartGeometryPainter geometryPainter;

  /// Animate to next [ItemOptions] state
  /// When making custom [ItemOptions] make sure to override this return custom painter
  /// with all available options, otherwise changes in options won't be animated
  ItemOptions animateTo(ItemOptions endValue, double t);
}
