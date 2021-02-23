part of flutter_charts;

/// Paint bubble value item.
///
///    ┌───────────┐ --> Max value in set or [ChartOptions.valueAxisMax]
///    │           │
///    │           │
///    │    /⎺⎺\   │ --> Bubble value
///    │    \__/   │
///    │           │
///    │           │
///    └───────────┘ --> 0 or [ChartOptions.valueAxisMin]
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

    final _padding = options.padding ?? EdgeInsets.zero;

    final _itemWidth = max(
        options.minBarWidth ?? 0.0,
        min(options.maxBarWidth ?? double.infinity,
            size.width - (_padding.horizontal.isNegative ? 0.0 : _padding.horizontal)));

    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || item.max < state.data.minValue) {
      return;
    }

    /// Bubble value, we need to draw a circle for this one
    final _circleSize = _itemWidth / 2;

    canvas.drawCircle(
      Offset(size.width * 0.5, item.max * _verticalMultiplier - _minValue),
      _circleSize,
      paint,
    );

    if (options is BubbleItemOptions && options.border != null && options.border.style == BorderStyle.solid) {
      final _borderPaint = Paint();
      _borderPaint.style = PaintingStyle.stroke;
      _borderPaint.color = options.border.color;
      _borderPaint.strokeWidth = options.border.width;

      canvas.drawCircle(
        Offset(size.width * 0.5, item.max * _verticalMultiplier - _minValue),
        _circleSize,
        _borderPaint,
      );
    }
  }
}
