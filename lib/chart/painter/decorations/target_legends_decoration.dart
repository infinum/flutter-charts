part of flutter_charts;

/// Show text on the left side of the chart, this text will be at
/// [TargetLineDecoration] or at max value of [TargetAreaDecoration].
///
/// Text will be rotated 90 CCW
class TargetLineLegendDecoration extends DecorationPainter {
  /// Target line legend constructor
  ///
  /// [legendDescription] and [legendStyle] are required
  TargetLineLegendDecoration({
    @required this.legendDescription,
    @required this.legendStyle,
    this.legendTarget = 0,
    this.padding = EdgeInsets.zero,
  }) : assert(legendStyle.fontSize != null, 'You must specify fontSize when using TargetLineLegendDecoration');

  /// Label to show at [target]
  final String legendDescription;

  /// Legend text style
  final TextStyle legendStyle;

  /// Label padding
  final EdgeInsets padding;

  /// Target value where to show the label
  final double legendTarget;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = size.height / _maxValue;
    final _minValue = state.data.minValue * scale;

    canvas.save();
    canvas.translate(state.defaultMargin.left, size.height + state.defaultMargin.top);

    size = state.defaultPadding.deflateSize(size);

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

    canvas.translate(-legendStyle.fontSize * 1.5, -scale * legendTarget + _minValue + _textPainter.width + padding.top);
    canvas.rotate(pi * 1.5);

    _textPainter.paint(
      canvas,
      Offset.zero,
    );

    canvas.restore();
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.only(left: legendStyle.fontSize * 2);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is TargetLineLegendDecoration) {
      return TargetLineLegendDecoration(
        legendStyle: TextStyle.lerp(legendStyle, endValue.legendStyle, t),
        legendDescription: endValue.legendDescription,
        padding: EdgeInsets.lerp(padding, endValue.padding, t),
        legendTarget: lerpDouble(legendTarget, endValue.legendTarget, t),
      );
    }

    return this;
  }
}
