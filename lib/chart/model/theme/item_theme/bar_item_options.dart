part of charts_painter;

/// Bar painter
GeometryPainter<T> barPainter<T>(ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, ChartDataItem chartDataItem) =>
    BarGeometryPainter<T>(item, data, itemOptions, chartDataItem as BarItem);

typedef ItemBuilder<T> = dynamic Function(ChartItem<T?> item, int itemKey, int listKey);

typedef BarItemBuilder<T> = BarItem Function(ChartItem<T?> item, int itemKey, int listKey);


abstract class ChartDataItem extends Equatable {
  ChartDataItem(this.color);

  final Color? color;
}

class BarItem extends ChartDataItem {
  BarItem({this.radius, this.gradient, this.border, Color? color}) : super(color);

  /// Set border radius for each item
  /// Radius will automatically flip when showing values in negative space
  final BorderRadius? radius;

  /// Set gradient color to chart items
  final Gradient? gradient;

  /// Set border to bar items
  final BorderSide? border;

  BarItem lerp(BarItem endValue, double t) {
    return BarItem(
      radius: BorderRadius.lerp(radius, endValue is BarItemOptions ? endValue.radius : null, t),
      gradient: Gradient.lerp(gradient, endValue is BarItemOptions ? endValue.gradient : null, t),
      border: BorderSide.lerp(border ?? BorderSide.none,
          endValue is BarItemOptions ? (endValue.border ?? BorderSide.none) : BorderSide.none, t),
      color: Color.lerp(color, endValue.color, t),
    );
  }

  @override
  List<Object?> get props => [radius, gradient, border, color];
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
    // Color color = Colors.red,
    ColorForValue? colorForValue,
    bool multiItemStack = true,
    required this.barItemBuilder,
  }) : super(
            colorForValue: colorForValue,
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
      Color color = Colors.red,
      ColorForValue? colorForValue,
      double multiItemStack = 1.0,
      required this.barItemBuilder})
      : super._lerp(
            // color: color,
            colorForValue: colorForValue,
            padding: padding,
            multiValuePadding: multiValuePadding,
            maxBarWidth: maxBarWidth,
            minBarWidth: minBarWidth,
            startPosition: startPosition,
            geometryPainter: barPainter,
            multiItemStack: multiItemStack,
            itemBuilder: barItemBuilder // todo: LERP it
            );

  final BarItemBuilder barItemBuilder;

  @override
  ItemOptions animateTo(ItemOptions endValue, double t) {
    // final _itemColor = Color.lerp(color, endValue.color, t) ?? Colors.red;

    return BarItemOptions._lerp(
      barItemBuilder: endValue is BarItemOptions ? endValue.barItemBuilder : barItemBuilder,
      // idk is this good
      // color: _itemColor,
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero,
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero,
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      startPosition: lerpDouble(startPosition, endValue.startPosition, t) ?? 0.5,
      multiItemStack: lerpDouble(_multiValueStacked, endValue._multiValueStacked, t) ?? 1.0,
    );
  }

// @override
// Paint getPaintForItem(ChartItem item, Size size, int key) {
//   final _paint = super.getPaintForItem(item, size, key);
//
//   final barItem = barItemBuilder(item, itemKey, key);
//
//   if (gradient != null) {
//     // Compiler complains that gradient could be null. But unless if fails us that will never be null.
//     _paint.shader = gradient!.createShader(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
//   }
//
//   return _paint;
// }
}
