part of charts_painter;

/// Target line decoration will draw target line horizontally across the chart
/// height of the line is defined by [target]
///
/// [colorOverTarget] color will be applied to items that missed the target.
///
/// In order to change the color of item when it didn't meet the target
/// criteria, you will need to add [getTargetItemColor] to [ItemOptions.colorForValue]
class TargetLineDecoration extends DecorationPainter {
  /// Constructor for target line decoration
  ///
  /// [target] is required
  TargetLineDecoration({
    required this.target,
    this.dashArray,
    this.colorOverTarget = Colors.red,
    this.targetLineColor = Colors.red,
    this.lineWidth = 2.0,
    this.isTargetInclusive = true,
  });

  /// Dash pattern for the line, if left empty line will be solid
  final List<double>? dashArray;

  /// Width of the target line
  final double lineWidth;

  /// Target value for the line
  final double? target;

  /// In case you want to change how value acts when it's exactly
  /// on the target value.
  ///
  /// By default this is true, meaning that when the target is the same as the
  /// value then the value and it's not using [colorOverTarget]
  final bool isTargetInclusive;

  /// Color for target line, this will modify [TargetLineDecoration] and [TargetAreaDecoration]
  final Color? targetLineColor;

  /// Color item should take once target is missed
  final Color? colorOverTarget;

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    final _size = (state.defaultPadding + state.defaultMargin).deflateSize(size);
    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = _size.height / _maxValue;
    final _minValue = state.data.minValue * scale;

    return Offset(state.defaultMargin.left,
        (_size.height - (lineWidth / 2)) - scale * (target ?? 0) + _minValue + state.defaultMargin.top);
  }

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    return Size((constraints.maxWidth - (state.defaultPadding.horizontal + state.defaultMargin.horizontal)), lineWidth);
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _linePaint = Paint()
      ..color = targetLineColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final _path = Path()
      ..moveTo(0.0, lineWidth / 2)
      ..lineTo(size.width, lineWidth / 2);

    if (dashArray != null) {
      canvas.drawPath(
        dashPath(_path, dashArray: dashArray!),
        _linePaint,
      );
    } else {
      canvas.drawPath(
        _path,
        _linePaint,
      );
    }
  }

  @override
  TargetLineDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is TargetLineDecoration) {
      return TargetLineDecoration(
        targetLineColor: Color.lerp(targetLineColor, endValue.targetLineColor, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t) ?? 2.0,
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        target: lerpDouble(target, endValue.target, t),
        colorOverTarget: Color.lerp(colorOverTarget, endValue.colorOverTarget, t),
      );
    }

    return this;
  }
}

/// Target area decoration, draw a RRect on the chart as `target range`
/// To actually change item colors you have to also set [colorOverTarget]
///
/// Target range is defined by [targetMin] and [targetMax]
class TargetAreaDecoration extends DecorationPainter {
  /// Constructor for target area
  ///
  /// [targetMin] and [targetMax] are required
  TargetAreaDecoration({
    required this.targetMin,
    required this.targetMax,
    this.isTargetInclusive = true,
    this.dashArray,
    this.lineWidth = 2.0,
    this.targetLineColor = Colors.red,
    this.colorOverTarget = Colors.red,
    this.areaPadding = EdgeInsets.zero,
    this.targetAreaRadius,
    this.targetAreaFillColor,
  }) : assert(areaPadding.vertical == 0, 'Vertical padding cannot be applied here!');

  /// Dash pattern for the line, if left empty line will be solid
  final List<double>? dashArray;

  /// Width of the target area border
  final double lineWidth;

  /// Color for target border
  final Color targetLineColor;

  /// Min target value for the area
  final double targetMin;

  /// Max target value for the area
  final double targetMax;

  /// In case you want to change how value acts on the target value
  /// by default this is true, meaning that when the target is the same
  /// as the value then the value and it's not using [colorOverTarget]
  final bool isTargetInclusive;

  /// Color item should take once target is missed
  final Color colorOverTarget;

  /// Padding for target area
  final EdgeInsets areaPadding;

  /// Border radius for [TargetAreaDecoration]
  final BorderRadius? targetAreaRadius;

  /// Fill color for [TargetAreaDecoration]
  final Color? targetAreaFillColor;

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    final _size = (state.defaultPadding + state.defaultMargin).deflateSize(constraints.biggest);
    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = _size.height / _maxValue;
    final _minValue = state.data.minValue * scale;

    return Rect.fromPoints(
      Offset(0.0, -scale * targetMax + _minValue + areaPadding.vertical),
      Offset(constraints.maxWidth, -scale * targetMin + _minValue),
    ).size;
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    final _size = (state.defaultPadding + state.defaultMargin).deflateSize(size);
    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = _size.height / _maxValue;
    final _minValue = state.data.minValue * scale;

    return Offset(
        areaPadding.left, _size.height - scale * targetMax + _minValue + state.defaultMargin.top);
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    canvas.save();
    if (targetAreaFillColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(lineWidth / 2, lineWidth / 2),
            Offset(size.width - lineWidth / 2, size.height - lineWidth / 2),
          ),
          bottomLeft: targetAreaRadius?.bottomLeft ?? Radius.zero,
          bottomRight: targetAreaRadius?.bottomRight ?? Radius.zero,
          topLeft: targetAreaRadius?.topLeft ?? Radius.zero,
          topRight: targetAreaRadius?.topRight ?? Radius.zero,
        ),
        Paint()..color = targetAreaFillColor!,
      );
    }

    final _rectPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(lineWidth / 2, lineWidth / 2),
          Offset(size.width - lineWidth / 2, size.height - lineWidth / 2),
        ),
        bottomLeft: targetAreaRadius?.bottomLeft ?? Radius.zero,
        bottomRight: targetAreaRadius?.bottomRight ?? Radius.zero,
        topLeft: targetAreaRadius?.topLeft ?? Radius.zero,
        topRight: targetAreaRadius?.topRight ?? Radius.zero,
      ));

    if (dashArray != null) {
      canvas.drawPath(
        dashPath(_rectPath, dashArray: dashArray!),
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
        targetLineColor: Color.lerp(targetLineColor, endValue.targetLineColor, t) ?? endValue.targetLineColor,
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t) ?? endValue.lineWidth,
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        targetAreaFillColor: Color.lerp(targetAreaFillColor, endValue.targetAreaFillColor, t),
        targetAreaRadius: BorderRadius.lerp(targetAreaRadius, endValue.targetAreaRadius, t),
        areaPadding: EdgeInsets.lerp(areaPadding, endValue.areaPadding, t)!,
        targetMin: lerpDouble(targetMin, endValue.targetMin, t) ?? endValue.targetMin,
        targetMax: lerpDouble(targetMax, endValue.targetMax, t) ?? endValue.targetMax,
        colorOverTarget: Color.lerp(colorOverTarget, endValue.colorOverTarget, t) ?? endValue.colorOverTarget,
      );
    }

    return this;
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.symmetric(horizontal: lineWidth / 2);
  }
}
