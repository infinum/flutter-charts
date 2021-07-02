part of charts_painter;

/// Paint bar value item. This is painter used for [BarValue] and [CandleValue]
///
/// Bar value:
///    ┌───────────┐ --> Max value in set or from [ChartData.axisMax]
///    │           │
///    │   ┌───┐   │ --> Bar value
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    └───┴───┴───┘ --> 0 or [ChartData.axisMin]
///
/// Candle value:
///    ┌───────────┐ --> Max value in set or [ChartData.axisMax]
///    │           │
///    │   ┌───┐   │ --> Candle max value
///    │   │   │   │
///    │   │   │   │
///    │   └───┘   │ --> Candle min value
///    │           │
///    └───────────┘ --> 0 or [ChartData.axisMin]
///
class BarGeometryPainter<T> extends GeometryPainter<T> {
  /// Constructor for Bar painter
  BarGeometryPainter(ChartItem<T> item, ChartState state) : super(item, state);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final options = state.itemOptions;

    final _maxValue = state.maxValue - state.minValue;
    final _verticalMultiplier = size.height / _maxValue;
    final _minValue = (state.minValue * _verticalMultiplier).abs();

    final _radius = options is BarItemOptions ? (options.radius ?? BorderRadius.zero) : BorderRadius.zero;

    final _itemWidth = itemWidth(size);

    final _itemMaxValue = item.max ?? 0.0;

    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || _itemMaxValue < state.minValue) {
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(
            0.0,
            _maxValue * _verticalMultiplier - max(state.minValue, item.min ?? 0.0) * _verticalMultiplier - _minValue,
          ),
          Offset(
            _itemWidth,
            _maxValue * _verticalMultiplier - _itemMaxValue * _verticalMultiplier - _minValue,
          ),
        ),
        bottomLeft: _itemMaxValue.isNegative ? _radius.topLeft : _radius.bottomLeft,
        bottomRight: _itemMaxValue.isNegative ? _radius.topRight : _radius.bottomRight,
        topLeft: _itemMaxValue.isNegative ? _radius.bottomLeft : _radius.topLeft,
        topRight: _itemMaxValue.isNegative ? _radius.bottomRight : _radius.topRight,
      ),
      paint,
    );

    final _border = options is BarItemOptions ? options.border : null;

    if (_border != null && _border.style == BorderStyle.solid) {
      final _borderPaint = Paint();
      _borderPaint.style = PaintingStyle.stroke;
      _borderPaint.color = _border.color;
      _borderPaint.strokeWidth = _border.width;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(
              0.0,
              max(state.minValue, item.min ?? 0.0) * _verticalMultiplier - _minValue,
            ),
            Offset(
              _itemWidth,
              _itemMaxValue * _verticalMultiplier - _minValue,
            ),
          ),
          bottomLeft: _itemMaxValue.isNegative ? _radius.topLeft : _radius.bottomLeft,
          bottomRight: _itemMaxValue.isNegative ? _radius.topRight : _radius.bottomRight,
          topLeft: _itemMaxValue.isNegative ? _radius.bottomLeft : _radius.topLeft,
          topRight: _itemMaxValue.isNegative ? _radius.bottomRight : _radius.topRight,
        ),
        _borderPaint,
      );
    }
  }
}
