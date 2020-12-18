part of flutter_charts;

class BarPainter extends ItemPainter {
  BarPainter(ChartItem item, ChartState state) : super(item, state);

  void paintText(Canvas canvas, Size size, double width, double verticalMultiplier, double minValue) {
    final _padding = state?.itemOptions?.padding;

    final _maxValuePainter = ItemPainter.makeTextPainter(
      '${item.max.toInt()}',
      width,
      TextStyle(
        fontSize: 14.0,
        color: state?.itemOptions?.getTextColor(item),
        fontWeight: FontWeight.w700,
      ),
    );

    _maxValuePainter.paint(
      canvas,
      Offset(
        _padding?.left ?? 0.0,
        item.max * verticalMultiplier - minValue + _maxValuePainter.height / 2,
      ),
    );

    if (item.min == null) {
      return;
    }

    final _minValuePainter = ItemPainter.makeTextPainter(
      '${item.min.toInt()}',
      width,
      TextStyle(
        fontSize: 14.0,
        color: state?.itemOptions?.getTextColor(item),
        fontWeight: FontWeight.w700,
      ),
    );

    _minValuePainter.paint(
      canvas,
      Offset(
        _padding?.left ?? 0.0,
        item.min * verticalMultiplier - minValue - _minValuePainter.height * 1.5,
      ),
    );
  }

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

    /// If [ChartItemOptions.showValue] is on the this will draw value on top of
    /// the bar item as well.
    ///
    /// If value is [CandleValue] it will draw min and max values.
    if (state?.itemOptions?.showValue ?? false) {
      paintText(canvas, size, _itemWidth, _verticalMultiplier, _minValue);
    }
  }
}
