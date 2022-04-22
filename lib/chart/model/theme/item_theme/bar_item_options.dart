part of charts_painter;

/// Bar painter
GeometryPainter<T> barPainter<T>(
        ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions) =>
    BarGeometryPainter<T>(item, data, itemOptions);

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
    Color color = Colors.red,
    ColorForValue? colorForValue,
    ColorForKey? colorForKey,
    bool multiItemStack = true,
    this.gradient,
    this.border,
    this.radius = BorderRadius.zero,
  }) : super(
          color: color,
          colorForValue: colorForValue,
          colorForKey: colorForKey,
          padding: padding,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          startPosition: startPosition,
          geometryPainter: barPainter,
          multiItemStack: multiItemStack,
        );

  const BarItemOptions._lerp({
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    double startPosition = 0.5,
    Color color = Colors.red,
    ColorForValue? colorForValue,
    ColorForKey? colorForKey,
    double multiItemStack = 1.0,
    this.gradient,
    this.border,
    this.radius = BorderRadius.zero,
  }) : super._lerp(
          color: color,
          colorForValue: colorForValue,
          colorForKey: colorForKey,
          padding: padding,
          multiValuePadding: multiValuePadding,
          maxBarWidth: maxBarWidth,
          minBarWidth: minBarWidth,
          startPosition: startPosition,
          geometryPainter: barPainter,
          multiItemStack: multiItemStack,
        );

  /// Set border radius for each item
  /// Radius will automatically flip when showing values in negative space
  final BorderRadius? radius;

  /// Set gradient color to chart items
  final Gradient? gradient;

  /// Set border to bar items
  final BorderSide? border;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    final _itemColor = Color.lerp(color, endValue.color, t) ?? Colors.red;

    return BarItemOptions._lerp(
      gradient: Gradient.lerp(
          gradient, endValue is BarItemOptions ? endValue.gradient : null, t),
      color: _itemColor,
      colorForKey: ColorForKeyLerp.lerp(this, endValue, t),
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
      multiValuePadding:
          EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ??
              EdgeInsets.zero,
      radius: BorderRadius.lerp(
          radius, endValue is BarItemOptions ? endValue.radius : null, t),
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      startPosition:
          lerpDouble(startPosition, endValue.startPosition, t) ?? 0.5,
      border: BorderSide.lerp(
          border ?? BorderSide.none,
          endValue is BarItemOptions
              ? (endValue.border ?? BorderSide.none)
              : BorderSide.none,
          t),
      multiItemStack:
          lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }

  @override
  Paint getPaintForItem(ChartItem item, Size size, int key) {
    final _paint = super.getPaintForItem(item, size, key);

    if (gradient != null) {
      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    return _paint;
  }
}
