part of flutter_charts;

class BubblePainter extends ItemPainter {
  BubblePainter(ChartItem item, ChartState state) : super(item, state);

  @override
  void paintText(Canvas canvas, Size size, ChartState state, double width, double verticalMultiplier, double minValue) {
    final _padding = state?.itemOptions?.padding;

    final _maxValuePainter =
        ItemPainter.makeTextPainter(state?.itemOptions?.getTextColor(item), '${item.max.toInt()}', width);

    _maxValuePainter.paint(
      canvas,
      Offset(
        _padding?.left ?? 0.0,
        item.max * verticalMultiplier - minValue - _maxValuePainter.height / 2,
      ),
    );
  }

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final _maxValue = state.maxValue - state.minValue;
    final _verticalMultiplier = size.height / _maxValue;
    final _minValue = state.minValue * _verticalMultiplier;

    final _padding = state?.itemOptions?.padding ?? EdgeInsets.zero;

    final _itemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0,
        min(state?.itemOptions?.maxBarWidth ?? double.infinity, size.width - (_padding?.horizontal ?? 0.0)));

    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || item.max < state?.minValue) {
      return;
    }

    /// Bubble value, we need to draw a circle for this one
    final _circleSize = (_itemWidth - _padding.horizontal) / 2;

    canvas.drawCircle(
      Offset(size.width * 0.5, item.min * _verticalMultiplier - _minValue),
      _circleSize,
      paint,
    );

    /// If [ChartItemOptions.showValue] is on the this will draw value on top of
    /// the bar item as well.
    ///
    /// If value is [CandleValue] it will draw min and max values.
    if (state?.itemOptions?.showValue ?? false) {
      paintText(canvas, size, state, _itemWidth, _verticalMultiplier, _minValue);
    }
  }
}
