part of charts_painter;

/// Bar painter
GeometryPainter<T> barPainter<T>(
        ChartItem<T> item, ChartData<T> data, ItemOptions itemOptions, ChartDataItem chartDataItem) =>
    BarGeometryPainter<T>(item, data, itemOptions, chartDataItem as BarItem);

typedef ItemBuilder<T> = dynamic Function(ChartItem<T?> item, int itemKey, int listKey);

typedef BarItemBuilder<T> = BarItem Function(ChartItem<T?> item, int itemKey, int listKey);

abstract class ChartDataItem extends Equatable {
  ChartDataItem({Color? color, this.gradient, BorderSide? border})
      : color = color ?? Colors.black,
        border = border ?? BorderSide.none;

  final Color color;

  /// Set gradient color to chart items
  final Gradient? gradient;

  /// Set border to bar items
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

class BarItemBuilderLerp {
  /// Make new function that will return lerp [ItemOptions] based on [ChartState.itemOptionsBuilder]
  static BarItemBuilder lerp(BarItemOptions a, BarItemOptions b, double t) {
    return (ChartItem item, int itemKey, int listKey) {
      final _aItem = a.barItemBuilder(item, itemKey, listKey);
      final _bItem = b.barItemBuilder(item, itemKey, listKey);
      return _aItem.lerp(_bItem, t);
    };
  }
}

class BarItem extends ChartDataItem {
  BarItem({this.radius, Gradient? gradient, BorderSide? border, Color? color})
      : super(color: color, gradient: gradient, border: border);

  /// Set border radius for each item
  /// Radius will automatically flip when showing values in negative space
  final BorderRadius? radius;

  BarItem lerp(BarItem endValue, double t) {
    return BarItem(
      radius: BorderRadius.lerp(radius, endValue is BarItemOptions ? endValue.radius : null, t),
      gradient: Gradient.lerp(gradient, endValue is BarItemOptions ? endValue.gradient : null, t),
      border: BorderSide.lerp(border, endValue is BarItemOptions ? (endValue.border) : BorderSide.none, t),
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
            itemBuilder: barItemBuilder
            );

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
