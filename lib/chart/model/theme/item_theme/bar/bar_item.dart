part of charts_painter;

class BarItem extends DrawDataItem {
  const BarItem({
    this.radius,
    Gradient? gradient,
    BorderSide? border,
    Color? color,
  }) : super(color: color, gradient: gradient, border: border);

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
  static BarItemBuilder lerp(BarItemOptions a, BarItemOptions b, double t) {
    return (ItemBuilderData data) {
      final _aItem = a.barItemBuilder(data);
      final _bItem = b.barItemBuilder(data);
      return _aItem.lerp(_bItem, t);
    };
  }
}
