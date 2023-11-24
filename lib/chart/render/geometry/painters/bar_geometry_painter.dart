part of charts_painter;

/// Paint bar value item.
///
/// Bar value:
///    ┌───────────┐ --> Max value in set or from [ChartData.maxValue]
///    │           │
///    │   ┌───┐   │ --> ChartItem value
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    └───┴───┴───┘ --> 0 or [ChartData.minValue]
///
/// Candle value:
///    ┌───────────┐ --> Max value in set or [ChartData.maxValue]
///    │           │
///    │   ┌───┐   │ --> ChartItem max value
///    │   │   │   │
///    │   │   │   │
///    │   └───┘   │ --> ChartItem min value
///    │           │
///    └───────────┘ --> 0 or [ChartData.minValue]
///
class BarGeometryPainter<T> extends GeometryPainter<T> {
  /// Constructor for Bar painter
  BarGeometryPainter(ChartItem<T> item, ChartData<T?> data, ItemOptions itemOptions, this.drawDataItem)
      : super(item, data, itemOptions);

  final BarItem drawDataItem;

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final _maxValue = data.maxValue - data.minValue;
    final _verticalMultiplier = size.height / _maxValue;
    final _minValue = (data.minValue * _verticalMultiplier);

    final _radius = drawDataItem.radius ?? BorderRadius.zero;

    final _itemMaxValue = item.max ?? 0.0;

    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item.isEmpty || _itemMaxValue < data.minValue) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(
              0.0,
              _maxValue * _verticalMultiplier - max(data.minValue, item.min ?? 0.0) * _verticalMultiplier + _minValue,
            ),
            Offset(
              size.width,
              _maxValue * _verticalMultiplier - 0.01 * _verticalMultiplier + _minValue,
            ),
          ),
          bottomLeft: _itemMaxValue.isNegative ? _radius.topLeft : _radius.bottomLeft,
          bottomRight: _itemMaxValue.isNegative ? _radius.topRight : _radius.bottomRight,
          topLeft: _itemMaxValue.isNegative ? _radius.bottomLeft : _radius.topLeft,
          topRight: _itemMaxValue.isNegative ? _radius.bottomRight : _radius.topRight,
        ),
        paint,
      );
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(
            0.0,
            _maxValue * _verticalMultiplier - max(data.minValue, item.min ?? 0.0) * _verticalMultiplier + _minValue,
          ),
          Offset(
            size.width,
            _maxValue * _verticalMultiplier - _itemMaxValue * _verticalMultiplier + _minValue,
          ),
        ),
        bottomLeft: _itemMaxValue.isNegative ? _radius.topLeft : _radius.bottomLeft,
        bottomRight: _itemMaxValue.isNegative ? _radius.topRight : _radius.bottomRight,
        topLeft: _itemMaxValue.isNegative ? _radius.bottomLeft : _radius.topLeft,
        topRight: _itemMaxValue.isNegative ? _radius.bottomRight : _radius.topRight,
      ),
      paint,
    );

    final _border = drawDataItem.border;

    if (_border.style == BorderStyle.solid) {
      final _borderPaint = Paint();
      _borderPaint.style = PaintingStyle.stroke;
      _borderPaint.color = _border.color;
      _borderPaint.strokeWidth = _border.width;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(
              0.0,
              _maxValue * _verticalMultiplier - max(data.minValue, item.min ?? 0.0) * _verticalMultiplier + _minValue,
            ),
            Offset(
              size.width,
              _maxValue * _verticalMultiplier - _itemMaxValue * _verticalMultiplier + _minValue,
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
