part of flutter_charts;

class HorizontalAxisDecoration extends DecorationPainter {
  HorizontalAxisDecoration({
    this.showValues = false,
    bool endWithChart = false,
    this.showTopValue = false,
    this.valuesAlign = TextAlign.end,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.horizontalAxisUnit,
    this.valueAxisStep = 1.0,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart ? 1.0 : 0.0;

  HorizontalAxisDecoration._lerp({
    this.showValues = false,
    double endWithChart = 0.0,
    this.showTopValue = false,
    this.valuesAlign = TextAlign.end,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.horizontalAxisUnit,
    this.valueAxisStep = 1.0,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart;

  bool get endWithChart => _endWithChart > 0.5;
  final double _endWithChart;

  final bool showValues;
  final TextAlign valuesAlign;
  final bool showTopValue;

  final String horizontalAxisUnit;

  final Color gridColor;
  final double gridWidth;
  final double valueAxisStep;

  final TextStyle legendFontStyle;

  String _longestText;

  @override
  void initDecoration(ChartState state) {
    if (showValues) {
      final _maxValue = state.maxValue - state.minValue;
      _longestText = '${(_maxValue + state.minValue).toInt()}';

      if (_longestText.length < (horizontalAxisUnit?.length ?? 0.0)) {
        _longestText = horizontalAxisUnit;
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = gridColor
      ..strokeWidth = gridWidth;

    canvas.save();
    canvas.translate(0.0 + state.defaultMargin.left, size.height + state.defaultMargin.top);

    final _maxValue = state.maxValue - state.minValue;
    final _size = (state.defaultPadding * _endWithChart).deflateSize(size);
    final scale = _size.height / _maxValue;

    for (int i = 0; i <= _maxValue / valueAxisStep; i++) {
      canvas.drawLine(
        Offset(0.0, -valueAxisStep * i * scale),
        Offset(_size.width, -valueAxisStep * i * scale),
        _paint,
      );

      if (!showValues) {
        continue;
      }

      String _text;

      if (!showTopValue && i == _maxValue / valueAxisStep) {
        _text = null;
      } else {
        _text = '${(valueAxisStep * i + state.minValue).toInt()}';
      }

      if (_text == null) {
        continue;
      }

      final _textPainter = TextPainter(
        text: TextSpan(
          text: _text,
          style: legendFontStyle.copyWith(color: state?.options?.axisLegendTextColor ?? Colors.grey),
        ),
        textAlign: valuesAlign,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(
          maxWidth: state?.defaultPadding?.right ?? 0.0,
          minWidth: state?.defaultPadding?.right ?? 0.0,
        );

      _textPainter.paint(
          canvas,
          Offset(size.width - (state?.defaultPadding?.right ?? 0.0),
              -valueAxisStep * i * scale - (_textPainter.height * 1.1)));
    }

    _setUnitValue(canvas, size, state, scale);

    canvas.restore();
  }

  void _setUnitValue(Canvas canvas, Size size, ChartState state, double scale) {
    if (horizontalAxisUnit == null) {
      return;
    }

    final _textPainter = TextPainter(
      text: TextSpan(
        text: horizontalAxisUnit,
        style: legendFontStyle.copyWith(color: state?.options?.axisLegendTextColor ?? Colors.grey),
      ),
      textAlign: valuesAlign,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: state?.defaultPadding?.right ?? 0.0,
        minWidth: state?.defaultPadding?.right ?? 0.0,
      );

    _textPainter.paint(canvas, Offset(size.width - (state?.defaultPadding?.right ?? 0.0), _textPainter.height));
  }

  double textWidth(String text, TextStyle style) {
    final TextPainter textPainter =
        TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.only(top: showValues && showTopValue ? 28.0 : 0.0);
  }

  @override
  EdgeInsets paddingNeeded() {
    final _textWidth = textWidth(_longestText, legendFontStyle);
    return EdgeInsets.only(right: _textWidth);
  }

  @override
  HorizontalAxisDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is HorizontalAxisDecoration) {
      return HorizontalAxisDecoration._lerp(
        showValues: t < 0.5 ? showValues : endValue.showValues,
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t),
        showTopValue: t < 0.5 ? showTopValue : endValue.showTopValue,
        valuesAlign: t < 0.5 ? valuesAlign : endValue.valuesAlign,
        gridColor: Color.lerp(gridColor, endValue.gridColor, t),
        gridWidth: lerpDouble(gridWidth, endValue.gridWidth, t),
        valueAxisStep: lerpDouble(valueAxisStep, endValue.valueAxisStep, t),
        legendFontStyle: TextStyle.lerp(legendFontStyle, endValue.legendFontStyle, t),
        horizontalAxisUnit: t > 0.5 ? endValue.horizontalAxisUnit : horizontalAxisUnit,
      );
    }

    return this;
  }
}
