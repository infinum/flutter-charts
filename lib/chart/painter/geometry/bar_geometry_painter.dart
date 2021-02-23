part of flutter_charts;

/// Paint bar value item. This is painter used for [BarValue] and [CandleValue]
///
/// Bar value:
///    ┌───────────┐ --> Max value in set or [ChartOptions.valueAxisMax]
///    │           │
///    │   ┌───┐   │ --> Bar value
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    │   │   │   │
///    └───┴───┴───┘ --> 0 or [ChartOptions.valueAxisMin]
///
/// Candle value:
///    ┌───────────┐ --> Max value in set or [ChartOptions.valueAxisMax]
///    │           │
///    │   ┌───┐   │ --> Candle max value
///    │   │   │   │
///    │   │   │   │
///    │   └───┘   │ --> Candle min value
///    │           │
///    └───────────┘ --> 0 or [ChartOptions.valueAxisMin]
///
class BarGeometryPainter<T> extends GeometryPainter<T> {
  /// Constructor for Bar painter
  BarGeometryPainter(ChartItem<T> item, ChartState state) : super(item, state);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {
    final options = state.itemOptions;

    final _maxValue = state.data.maxValue - state.data.minValue;
    final _verticalMultiplier = size.height / _maxValue;
    final _minValue = state.data.minValue * _verticalMultiplier;

    EdgeInsets _padding = state.itemOptions.padding ?? EdgeInsets.zero;
    final _radius = options is BarItemOptions ? (options.radius ?? BorderRadius.zero) : BorderRadius.zero;

    final _itemWidth = itemWidth(size);

    if (size.width - _itemWidth - _padding.horizontal >= 0) {
      _padding = EdgeInsets.symmetric(horizontal: (size.width - _itemWidth) / 2);
    }
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (item == null || item.isEmpty || item.max < state.data.minValue) {
      return;
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(
            _padding.left,
            max(state.data.minValue ?? 0.0, item.min ?? 0.0) * _verticalMultiplier - _minValue,
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

    if (options is BarItemOptions && options.border != null && options.border.style == BorderStyle.solid) {
      final _borderPaint = Paint();
      _borderPaint.style = PaintingStyle.stroke;
      _borderPaint.color = options.border.color;
      _borderPaint.strokeWidth = options.border.width;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(
              _padding.left,
              max(state.data.minValue ?? 0.0, item.min ?? 0.0) * _verticalMultiplier - _minValue,
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
        _borderPaint,
      );
    }
  }
}
