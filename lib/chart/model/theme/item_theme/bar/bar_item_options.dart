part of charts_painter;

/// Bar painter
GeometryPainter<T> barPainter<T>(
  ChartItem<T> item,
  ChartData<T> data,
  ItemOptions itemOptions,
  DrawDataItem drawDataItem,
) =>
    BarGeometryPainter<T>(item, data, itemOptions, drawDataItem as BarItem);

typedef BarItemBuilder<T> = BarItem Function(ItemBuilderData data);

/// Extension options for bar items
/// [geometryPainter] is set to [BarGeometryPainter]
///
/// Extra options included in [BarGeometryPainter] are:
/// [radius] Define corner radius for each bar item
/// [border] Define border width and color
/// [gradient] Item can have gradient color
class BarItemOptions extends ItemOptions {
  /// Constructor for bar item options, has some extra options just for [BarGeometryPainter]
  const BarItemOptions({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    double startPosition = 0.5,
    this.barItemBuilder = _defaultBarItem,
  }) : super(
          padding: padding,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          startPosition: startPosition,
          geometryPainter: barPainter,
          itemBuilder: barItemBuilder,
        );

  BarItemOptions._lerp({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    double startPosition = 0.5,
    required this.barItemBuilder,
  }) : super._lerp(
          padding: padding,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          startPosition: startPosition,
          geometryPainter: barPainter,
          itemBuilder: barItemBuilder,
        );

  final BarItemBuilder barItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    if (endValue is BarItemOptions) {
      return BarItemOptions._lerp(
        barItemBuilder: BarItemBuilderLerp.lerp(this, endValue, t),
        padding:
            EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
        multiValuePadding:
            EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ??
                EdgeInsets.zero,
        maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
        minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
        startPosition:
            lerpDouble(startPosition, endValue.startPosition, t) ?? 0.5,
      );
    } else {
      return endValue;
    }
  }
}

BarItem _defaultBarItem(ItemBuilderData _) {
  return const BarItem();
}
