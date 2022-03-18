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
  BubbleGeometryPainter(
      ChartItem<T> item, ChartData<T?> data, ItemOptions itemOptions)
      : super(item, data, itemOptions);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final _maxValue = data.maxValue - data.minValue;
    final _verticalMultiplier = size.height / max(1, _maxValue);
    final _minValue = data.minValue * _verticalMultiplier;

    final _itemWidth = max(
        itemOptions.minBarWidth ?? 0.0,
        min(
            itemOptions.maxBarWidth ?? double.infinity,
            size.width -
                (itemOptions.padding.horizontal.isNegative
                    ? 0.0
                    : itemOptions.padding.horizontal)));

    final _itemMaxValue = item.max ?? 0.0;
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || _itemMaxValue < data.minValue) {
      return;
    }

    /// Bubble value, we need to draw a circle for this one
    final _circleSize = _itemWidth / 2;

    canvas.drawCircle(
      Offset(size.width * 0.5,
          size.height - _itemMaxValue * _verticalMultiplier - _minValue),
      _circleSize,
      paint,
    );

    if (itemOptions is BubbleItemOptions) {
      final _border = (itemOptions as BubbleItemOptions).border;

      if (_border != null && _border.style == BorderStyle.solid) {
        final _borderPaint = Paint();
        _borderPaint.style = PaintingStyle.stroke;

        _borderPaint.color = _border.color;
        _borderPaint.strokeWidth = _border.width;

        canvas.drawCircle(
          Offset(size.width * 0.5,
              _itemMaxValue * _verticalMultiplier - _minValue),
          _circleSize,
          _borderPaint,
        );
      }
    }
  }
}
