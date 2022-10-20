part of charts_painter;

class BubbleItem extends DrawDataItem {
  const BubbleItem({
    Gradient? gradient,
    BorderSide? border,
    Color? color,
  }) : super(color: color, gradient: gradient, border: border);

  BubbleItem lerp(BubbleItem endValue, double t) {
    return BubbleItem(
      gradient: Gradient.lerp(gradient, endValue is BubbleItemOptions ? endValue.gradient : null, t),
      border: BorderSide.lerp(border, endValue is BubbleItemOptions ? (endValue.border) : BorderSide.none, t),
      color: Color.lerp(color, endValue.color, t),
    );
  }

  @override
  List<Object?> get props => [gradient, border, color];
}

class BubbleItemBuilderLerp {
  static BubbleItemBuilder lerp(BubbleItemOptions a, BubbleItemOptions b, double t) {
    return (ItemBuilderData data) {
      final _aItem = a.bubbleItemBuilder(data);
      final _bItem = b.bubbleItemBuilder(data);
      return _aItem.lerp(_bItem, t);
    };
  }
}
