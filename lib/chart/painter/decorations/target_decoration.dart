part of flutter_charts;

/// Check iv item is inside the target
bool _isInTarget(double max, {double min, double targetMin, double targetMax, bool inclusive = true}) {
  if (targetMin == null && targetMax == null) {
    return true;
  }

  final _min = min ?? max;

  if ((targetMin != null && _min <= targetMin) || (targetMax != null && max >= targetMax)) {
    // Check if target is inclusive, don't show error color in that case
    if (inclusive && (_min == targetMin || max == targetMax)) {
      return true;
    }

    return false;
  }

  return true;
}

Color _getColorForTarget(
    Color color, Color colorOverTarget, bool isTargetInclusive, double targetMin, double targetMax, double max,
    [double min]) {
  return _isInTarget(max, min: min, targetMax: targetMax, targetMin: targetMin, inclusive: isTargetInclusive)
      ? color
      : (colorOverTarget ?? color);
}

/// Target line decoration will draw target line horizontally across the chart
/// height of the line is defined by [ChartItemOptions.targetMin] or if target min is missing
/// then [ChartItemOptions.targetMax] is used
///
///
/// If you provide [targetMax] or/and [targetMin] then [colorOverTarget] color will
/// be applied to items that missed the target.
///
/// In order to change the color of item when it didn't meet the target criteria, you will need
/// to add [getTargetItemColor] to [ChartItemOptions.colorForValue]
class TargetLineDecoration extends DecorationPainter {
  TargetLineDecoration({
    @required this.target,
    this.dashArray,
    this.colorOverTarget = Colors.red,
    this.targetLineColor = Colors.red,
    this.lineWidth = 2.0,
    this.isTargetInclusive = true,
  });

  final List<double> dashArray;
  final double lineWidth;

  final double target;

  /// In case you want to change how value acts on the target value
  /// by default this is true, meaning that when the target is the same
  /// as the value then the value and it's not using [colorOverTarget] or [valueColorOver]
  final bool isTargetInclusive;

  /// Color for target line, this will modify [TargetLineDecoration] and [TargetAreaDecoration]
  final Color targetLineColor;

  final Color colorOverTarget;

  ColorForValue getTargetItemColor() => (Color defaultColor, double max, [double min]) =>
      _getColorForTarget(defaultColor, colorOverTarget, isTargetInclusive, target, null, max, min);

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _maxValue = state.maxValue - state.minValue;
    final scale = size.height / _maxValue;
    final _minValue = state.minValue * scale;

    final _linePaint = Paint()
      ..color = targetLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    canvas.save();
    canvas.translate(
        (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left, size.height + state.defaultMargin.top);

    final _path = Path()
      ..moveTo(0.0, -scale * target + _minValue)
      ..lineTo(size.width, -scale * target + _minValue);

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
        targetLineColor: Color.lerp(targetLineColor, endValue.targetLineColor, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        target: lerpDouble(target, endValue.target, t),
        colorOverTarget: Color.lerp(colorOverTarget, endValue.colorOverTarget, t),
      );
    }

    return this;
  }
}

/// Target area decoration, draw a RRect on the chart as `target range`
/// To actually change item colors you have to also set [ChartItemOptions.colorOverTarget]
///
/// Target range is defined by [ChartItemOptions.targetMin] and [ChartItemOptions.targetMax]
class TargetAreaDecoration extends DecorationPainter {
  TargetAreaDecoration({
    this.targetMin,
    this.targetMax,
    this.isTargetInclusive = true,
    this.dashArray,
    this.lineWidth = 2.0,
    this.targetLineColor = Colors.red,
    this.colorOverTarget = Colors.red,
    this.areaPadding = EdgeInsets.zero,
    this.targetAreaRadius,
    this.targetAreaFillColor,
  }) : assert(areaPadding.vertical == 0, 'Vertical padding cannot be applied here!');

  final List<double> dashArray;
  final double lineWidth;

  /// Color for target line
  final Color targetLineColor;

  final double targetMin;
  final double targetMax;

  /// In case you want to change how value acts on the target value
  /// by default this is true, meaning that when the target is the same
  /// as the value then the value and it's not using [colorOverTarget] or [valueColorOver]
  final bool isTargetInclusive;
  final Color colorOverTarget;
  final EdgeInsets areaPadding;

  /// Border radius for [TargetAreaDecoration]
  final BorderRadius targetAreaRadius;

  /// Fill color for [TargetAreaDecoration]
  final Color targetAreaFillColor;

  ColorForValue getTargetItemColor() => (Color defaultColor, double max, [double min]) =>
      _getColorForTarget(defaultColor, colorOverTarget, isTargetInclusive, targetMin, targetMax, max, min);

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state?.defaultPadding?.deflateSize(size) ?? size;
    final _maxValue = state.maxValue - state.minValue;
    final scale = _size.height / _maxValue;
    final _minValue = state.minValue * scale;

    canvas.save();
    canvas.translate(areaPadding.left + (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left,
        _size.height + state.defaultMargin.top);

    if (targetAreaFillColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(0.0, -scale * targetMin + _minValue),
            Offset(_size.width - areaPadding.horizontal, -scale * targetMax + _minValue),
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
          Offset(0.0, -scale * (targetMin ?? 0.0) + _minValue),
          Offset(_size.width, -scale * (targetMax ?? 0.0) + _minValue),
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
          ..color = targetLineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke,
      );
    } else {
      canvas.drawPath(
        _rectPath,
        Paint()
          ..color = targetLineColor
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
        targetLineColor: Color.lerp(targetLineColor, endValue.targetLineColor, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        targetAreaFillColor: Color.lerp(targetAreaFillColor, endValue.targetAreaFillColor, t),
        targetAreaRadius: BorderRadius.lerp(targetAreaRadius, endValue.targetAreaRadius, t),
        areaPadding: EdgeInsets.lerp(areaPadding, endValue.areaPadding, t),
        targetMin: lerpDouble(targetMin, endValue.targetMin, t),
        targetMax: lerpDouble(targetMax, endValue.targetMax, t),
        colorOverTarget: Color.lerp(colorOverTarget, endValue.colorOverTarget, t),
      );
    }

    return this;
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.symmetric(horizontal: lineWidth / 2);
  }
}
