part of charts_painter;

/// Bar painter
GeometryPainter<T> barPainter<T>(
        ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, DrawDataItem drawDataItem) =>
    BarGeometryPainter<T>(item, data, itemOptions, drawDataItem as BarItem);

typedef BarItemBuilder<T> = BarItem Function(ChartItem<T?> item, int itemKey, int listKey);

abstract class DrawDataItem extends Equatable {
  DrawDataItem({Color? color, this.gradient, BorderSide? border})
      : color = color ?? Colors.black,
        border = border ?? BorderSide.none;

  /// Set solid color to chart items
  final Color color;

  /// Set gradient color to chart items
  final Gradient? gradient;

  /// Set border to chart items
  final BorderSide border;

  Paint getPaint(Size size) {
    var _paint = Paint();
    _paint.color = color;

    if (gradient != null) {
      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    return _paint;
  }
}

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
    bool multiItemStack = true,
    required this.barItemBuilder,
  }) : super(
            padding: padding,
            multiValuePadding: multiValuePadding,
            maxBarWidth: maxBarWidth,
            minBarWidth: minBarWidth,
            startPosition: startPosition,
            geometryPainter: barPainter,
            multiItemStack: multiItemStack,
            itemBuilder: barItemBuilder);

  BarItemOptions._lerp(
      {EdgeInsets padding = EdgeInsets.zero,
      EdgeInsets multiValuePadding = EdgeInsets.zero,
      double? maxBarWidth,
      double? minBarWidth,
      double startPosition = 0.5,
      double multiItemStack = 1.0,
      required this.barItemBuilder})
      : super._lerp(
            padding: padding,
            multiValuePadding: multiValuePadding,
            maxBarWidth: maxBarWidth,
            minBarWidth: minBarWidth,
            startPosition: startPosition,
            geometryPainter: barPainter,
            multiItemStack: multiItemStack,
            itemBuilder: barItemBuilder);

  final BarItemBuilder barItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    if (endValue is BarItemOptions) {
      return BarItemOptions._lerp(
        barItemBuilder: BarItemBuilderLerp.lerp(this, endValue, t),
        padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
        multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero,
        maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
        minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
        startPosition: lerpDouble(startPosition, endValue.startPosition, t) ?? 0.5,
        multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
      );
    } else {
      return endValue;
    }
  }
}
