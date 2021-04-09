part of charts_painter;

/// Bar painter
GeometryPainter<T> barPainter<T>(ChartItem<T> item, ChartState<T> state) => BarGeometryPainter<T>(item, state);

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
    EdgeInsets? padding = EdgeInsets.zero,
    EdgeInsets? multiValuePadding = EdgeInsets.zero,
    double? maxBarWidth,
    double? minBarWidth,
    Color color = Colors.red,
    ColorForValue? colorForValue,
    ColorForKey? colorForKey,
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
          geometryPainter: barPainter,
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
    return BarItemOptions(
      gradient: Gradient.lerp(gradient, endValue is BarItemOptions ? endValue.gradient : null, t),

      /// TODO(lukaknezic): NULLSAFETY - Remove !
      color: Color.lerp(color, endValue.color, t)!,
      colorForKey: ColorForKeyLerp.lerp(this, endValue, t),
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t),
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t),
      radius: BorderRadius.lerp(radius, endValue is BarItemOptions ? endValue.radius : null, t),
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      border: BorderSide.lerp(border ?? BorderSide.none,
          endValue is BarItemOptions ? (endValue.border ?? BorderSide.none) : BorderSide.none, t),
    );
  }

  @override
  Paint getPaintForItem(ChartItem item, Size size, int key) {
    final _paint = super.getPaintForItem(item, size, key);

    if (gradient != null) {
      _paint.shader = gradient!.createShader(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    return _paint;
  }
}
