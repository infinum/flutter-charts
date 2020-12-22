part of flutter_charts;

class BarPainter extends ItemPainter {
  BarPainter(ChartItem item, ChartState state) : super(item, state);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final _maxValue = state.maxValue - state.minValue;
    final _verticalMultiplier = size.height / _maxValue;
    final _minValue = state.minValue * _verticalMultiplier;

    EdgeInsets _padding = state?.itemOptions?.padding ?? EdgeInsets.zero;
    final _radius = state?.itemOptions?.radius ?? BorderRadius.zero;

    final _itemWidth = itemWidth(size);

    if (size.width - _itemWidth - _padding.horizontal >= 0) {
      _padding = EdgeInsets.symmetric(horizontal: (size.width - _itemWidth) / 2);
    }
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || item.max < state?.minValue) {
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(
            _padding.left,
            max(state?.minValue ?? 0.0, item.min ?? 0.0) * _verticalMultiplier - _minValue,
          ),
          Offset(
            _itemWidth + _padding.left,
            item.max * _verticalMultiplier - _minValue,
          ),
        ),
        bottomLeft: item.max.isNegative ? _radius.topLeft : _radius.bottomLeft,
        bottomRight: item.max.isNegative ? _radius.topRight : _radius.bottomRight,
        topLeft: item.max.isNegative ? _radius.bottomLeft : _radius.topLeft,
        topRight: item.max.isNegative ? _radius.bottomRight : _radius.topRight,
      ),
      paint,
    );
  }
}
