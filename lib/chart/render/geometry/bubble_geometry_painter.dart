part of charts_painter;

/// Paint bubble value item.
///
///    ┌───────────┐ --> Max value in set or [ChartData.axisMax]
///    │           │
///    │           │
///    │    /⎺⎺\   │ --> Bubble value
///    │    \__/   │
///    │           │
///    │           │
///    └───────────┘ --> 0 or [ChartData.axisMin]
///
class BubbleGeometryPainter<T> extends GeometryPainter<T> {
  /// Constructor for bubble painter
  BubbleGeometryPainter(ChartItem<T> item, ChartState state) : super(item, state);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final options = state.itemOptions;

    final _maxValue = state.data.maxValue - state.data.minValue;
    final _verticalMultiplier = size.height / _maxValue;
    final _minValue = state.data.minValue * _verticalMultiplier;

    final _itemWidth = max(
        options.minBarWidth ?? 0.0,
        min(options.maxBarWidth ?? double.infinity,
            size.width - (options.padding.horizontal.isNegative ? 0.0 : options.padding.horizontal)));

    final _itemMaxValue = item.max ?? 0.0;
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || _itemMaxValue < state.data.minValue) {
      return;
    }

    /// Bubble value, we need to draw a circle for this one
    final _circleSize = _itemWidth / 2;

    canvas.drawCircle(
      Offset(size.width * 0.5, _itemMaxValue * _verticalMultiplier - _minValue),
      _circleSize,
      paint,
    );

    final _border = options is BubbleItemOptions ? options.border : null;

    if (_border != null && _border.style == BorderStyle.solid) {
      final _borderPaint = Paint();
      _borderPaint.style = PaintingStyle.stroke;

      _borderPaint.color = _border.color;
      _borderPaint.strokeWidth = _border.width;

      canvas.drawCircle(
        Offset(size.width * 0.5, _itemMaxValue * _verticalMultiplier - _minValue),
        _circleSize,
        _borderPaint,
      );
    }
  }
}
