part of charts_painter;

class BarItem extends DrawDataItem {
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