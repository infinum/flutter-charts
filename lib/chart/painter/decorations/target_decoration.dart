part of flutter_charts;

/// Target line decoration will draw target line horizontally across the chart
/// height of the line is defined by [ChartItemOptions.targetMin] or if target min is missing
/// then [ChartItemOptions.targetMax] is used
class TargetLineDecoration extends DecorationPainter {
  TargetLineDecoration({
    this.dashArray,
    this.targetColor = Colors.red,
    this.lineWidth = 2.0,
  });

  final List<double> dashArray;
  final double lineWidth;

  /// Color for target line, this will modify [TargetLineDecoration] and [TargetAreaDecoration]
  final Color targetColor;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _maxValue = state.maxValue - state.minValue;
    final scale = size.height / _maxValue;
    final _minValue = state.minValue * scale;

    final _target = state.itemOptions.targetMin ?? state.itemOptions.targetMax ?? 0.0;
    final _linePaint = Paint()
      ..color = targetColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    canvas.save();
    canvas.translate(
        (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left, size.height + state.defaultMargin.top);

    final _path = Path()
      ..moveTo(0.0, -scale * _target + _minValue)
      ..lineTo(size.width, -scale * _target + _minValue);

    if (dashArray != null) {
      canvas.drawPath(
        dashPath(_path, dashArray: CircularIntervalList(dashArray)),
        _linePaint,
      );
    } else {
      canvas.drawPath(
        _path,
        _linePaint,
      );
    }

    canvas.restore();
  }

  @override
  TargetLineDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is TargetLineDecoration) {
      return TargetLineDecoration(
        targetColor: Color.lerp(targetColor, endValue.targetColor, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
      );
    }

    return this;
  }
}

/// Target area decoration, draw a RRect on the chart as `target range`
/// To actually change item colors you have to also set [ChartItemOptions.targetOverColor]
///
/// Target range is defined by [ChartItemOptions.targetMin] and [ChartItemOptions.targetMax]
class TargetAreaDecoration extends DecorationPainter {
  TargetAreaDecoration({
    this.dashArray,
    this.lineWidth = 2.0,
    this.targetColor = Colors.red,
    this.targetAreaRadius,
    this.targetAreaFillColor,
  });

  final List<double> dashArray;
  final double lineWidth;

  /// Color for target line
  final Color targetColor;

  /// Border radius for [TargetAreaDecoration]
  final BorderRadius targetAreaRadius;

  /// Fill color for [TargetAreaDecoration]
  final Color targetAreaFillColor;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state?.defaultPadding?.deflateSize(size) ?? size;
    final _maxValue = state.maxValue - state.minValue;
    final scale = _size.height / _maxValue;
    final _minValue = state.minValue * scale;

    canvas.save();
    canvas.translate(
        (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left, _size.height + state.defaultMargin.top);

    if (targetAreaFillColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(0.0, -scale * state.itemOptions.targetMin + _minValue),
            Offset(_size.width, -scale * state.itemOptions.targetMax + _minValue),
          ),
          bottomLeft: targetAreaRadius?.bottomLeft ?? Radius.zero,
          bottomRight: targetAreaRadius?.bottomRight ?? Radius.zero,
          topLeft: targetAreaRadius?.topLeft ?? Radius.zero,
          topRight: targetAreaRadius?.topRight ?? Radius.zero,
        ),
        Paint()
          ..color = targetAreaFillColor
          ..strokeWidth = 3.0,
      );
    }

    final _rectPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(0.0, -scale * state.itemOptions.targetMin + _minValue),
          Offset(_size.width, -scale * state.itemOptions.targetMax + _minValue),
        ),
        bottomLeft: targetAreaRadius?.bottomLeft ?? Radius.zero,
        bottomRight: targetAreaRadius?.bottomRight ?? Radius.zero,
        topLeft: targetAreaRadius?.topLeft ?? Radius.zero,
        topRight: targetAreaRadius?.topRight ?? Radius.zero,
      ));

    if (dashArray != null) {
      canvas.drawPath(
        dashPath(_rectPath, dashArray: CircularIntervalList(dashArray)),
        Paint()
          ..color = targetColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke,
      );
    } else {
      canvas.drawPath(
        _rectPath,
        Paint()
          ..color = targetColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke,
      );
    }

    canvas.restore();
  }

  @override
  TargetAreaDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is TargetAreaDecoration) {
      return TargetAreaDecoration(
        targetColor: Color.lerp(targetColor, endValue.targetColor, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        targetAreaFillColor: Color.lerp(targetAreaFillColor, endValue.targetAreaFillColor, t),
        targetAreaRadius: BorderRadius.lerp(targetAreaRadius, endValue.targetAreaRadius, t),
      );
    }

    return this;
  }
}
