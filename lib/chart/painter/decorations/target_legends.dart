part of flutter_charts;

/// Show decoration for target area below.
/// This decoration will show circle with dashed border, and text to right of it,
/// it will be placed on bottom left corner of the charts.
class TargetAreaLegendDecoration extends DecorationPainter {
  TargetAreaLegendDecoration({
    this.dashArray,
    this.lineWidth,
    this.areaColor,
    this.areaCircleSize = 16.0,
    this.borderColor,
    this.legendDescription,
    this.legendStyle,
    this.padding = const EdgeInsets.all(24.0),
  });

  final List<double> dashArray;
  final double lineWidth;

  final Color borderColor;
  final Color areaColor;
  final double areaCircleSize;

  final String legendDescription;
  final TextStyle legendStyle;

  final EdgeInsets padding;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _areaPaint = Paint()..color = areaColor ?? Colors.grey;
    final _borderPaint = Paint()
      ..color = borderColor ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth ?? 1.0;

    canvas.save();
    canvas.translate(0.0 + state.defaultMargin.left, size.height + state.defaultMargin.top);

    final _textPainter = TextPainter(
      text: TextSpan(
        text: legendDescription,
        style: legendStyle,
      ),
      textAlign: TextAlign.start,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: size.width,
        minWidth: size.width,
      );

    _textPainter.paint(
        canvas,
        Offset(areaCircleSize + padding.left + state?.defaultPadding?.left ?? 0.0,
            _textPainter.height + 8.0 + padding.top));

    final _path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(areaCircleSize + state?.defaultPadding?.left ?? 0.0,
            _textPainter.height + 8.0 + padding.top + areaCircleSize / 2),
        width: areaCircleSize,
        height: areaCircleSize,
      ));

    canvas.drawCircle(
        Offset(areaCircleSize + state?.defaultPadding?.left ?? 0.0,
            _textPainter.height + 8.0 + padding.top + areaCircleSize / 2),
        areaCircleSize / 2,
        _areaPaint);

    canvas.drawPath(
      dashPath(_path, dashArray: CircularIntervalList(dashArray)),
      _borderPaint,
    );

    canvas.restore();
  }

  @override
  EdgeInsets marginNeeded() {
    return const EdgeInsets.only(bottom: 32.0);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is TargetAreaLegendDecoration) {
      return TargetAreaLegendDecoration(
        dashArray: endValue.dashArray,
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        areaColor: Color.lerp(areaColor, endValue.areaColor, t),
        areaCircleSize: lerpDouble(areaCircleSize, endValue.areaCircleSize, t),
        borderColor: Color.lerp(borderColor, endValue.borderColor, t),
        legendDescription: endValue.legendDescription,
        legendStyle: TextStyle.lerp(legendStyle, endValue.legendStyle, t),
        padding: EdgeInsets.lerp(padding, endValue.padding, t),
      );
    }

    return this;
  }
}

/// Show text on the left side of the chart, this text will be at
/// [TargetLineDecoration] or at max value of [TargetAreaDecoration].
///
/// Text will be rotated 90 CCW
class TargetLineLegendDecoration extends DecorationPainter {
  TargetLineLegendDecoration({
    this.legendDescription,
    this.legendStyle,
    this.padding = const EdgeInsets.all(24.0),
  });

  final String legendDescription;
  final TextStyle legendStyle;

  final EdgeInsets padding;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _maxValue = state.maxValue - state.minValue;
    final scale = size.height / _maxValue;
    final _minValue = state.minValue * scale;
    final _target = state.itemOptions.targetMax ?? state.itemOptions.targetMin ?? 0.0;

    canvas.save();
    canvas.translate(
        state?.defaultPadding?.left ?? 0.0 + state.defaultMargin.left, size.height + state.defaultMargin.top);

    final _textPainter = TextPainter(
      text: TextSpan(
        text: legendDescription,
        style: legendStyle,
      ),
      textAlign: TextAlign.start,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: size.width,
      );

    canvas.translate(
        state?.defaultPadding?.left ?? 0.0 + padding.left, -scale * _target + _minValue + _textPainter.width);
    canvas.rotate(pi * 1.5);

    _textPainter.paint(
      canvas,
      Offset.zero,
    );

    canvas.restore();
  }

  @override
  EdgeInsets marginNeeded() {
    return const EdgeInsets.only(left: 32.0);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is TargetLineLegendDecoration) {
      return TargetLineLegendDecoration(
        legendStyle: TextStyle.lerp(legendStyle, endValue.legendStyle, t),
        legendDescription: endValue.legendDescription,
        padding: EdgeInsets.lerp(padding, endValue.padding, t),
      );
    }

    return this;
  }
}
