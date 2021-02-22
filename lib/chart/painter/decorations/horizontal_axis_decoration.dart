part of flutter_charts;

/// Position of legend in [HorizontalAxisDecoration]
enum HorizontalLegendPosition {
  /// Show axis legend at the start of the chart
  start,

  /// Show legend at the end of the decoration
  end,
}

typedef AxisValueFromValue = String Function(int value);
String defaultAxisValue(int index) => '$index';

class HorizontalAxisDecoration extends DecorationPainter {
  HorizontalAxisDecoration({
    this.showValues = false,
    bool endWithChart = false,
    this.showTopValue = false,
    this.showGrid = true,
    this.valuesAlign = TextAlign.end,
    this.valuesPadding = EdgeInsets.zero,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.horizontalAxisUnit,
    this.dashArray,
    this.axisValue = defaultAxisValue,
    this.axisStep = 1.0,
    this.legendPosition = HorizontalLegendPosition.end,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart ? 1.0 : 0.0;

  HorizontalAxisDecoration._lerp({
    this.showValues = false,
    double endWithChart = 0.0,
    this.showTopValue = false,
    this.showGrid = true,
    this.valuesAlign = TextAlign.end,
    this.valuesPadding = EdgeInsets.zero,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.horizontalAxisUnit,
    this.axisStep = 1.0,
    this.dashArray,
    this.axisValue = defaultAxisValue,
    this.legendPosition = HorizontalLegendPosition.end,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart;

  bool get endWithChart => _endWithChart > 0.5;
  final double _endWithChart;

  final List<double> dashArray;
  final bool showValues;
  final TextAlign valuesAlign;
  final EdgeInsets valuesPadding;
  final bool showTopValue;
  final HorizontalLegendPosition legendPosition;
  final AxisValueFromValue axisValue;

  final String horizontalAxisUnit;

  final bool showGrid;
  final Color gridColor;
  final double gridWidth;
  final double axisStep;

  final TextStyle legendFontStyle;

  String _longestText;

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    if (showValues) {
      _longestText = axisValue.call(state.data.maxValue.toInt()).toString();

      if (_longestText.length < (horizontalAxisUnit?.length ?? 0.0)) {
        _longestText = horizontalAxisUnit;
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = gridWidth;

    canvas.save();
    canvas.translate(0.0 + state.defaultMargin.left, size.height + state.defaultMargin.top - state.defaultPadding.top);

    final _maxValue = state.data.maxValue - state.data.minValue;
    final _size = (state.defaultPadding * _endWithChart).deflateSize(size);
    final scale = _size.height / _maxValue;

    final gridPath = Path();

    for (int i = 0; i <= _maxValue / axisStep; i++) {
      if (showGrid) {
        gridPath.moveTo(_endWithChart * state.defaultPadding.left, -axisStep * i * scale + gridWidth / 2);
        gridPath.lineTo(_size.width, -axisStep * i * scale + gridWidth / 2);
      }

      if (!showValues) {
        continue;
      }

      String _text;

      if (!showTopValue && i == _maxValue / axisStep) {
        _text = null;
      } else {
        final _defaultValue = (axisStep * i + state.data.minValue).toInt();
        final _value = axisValue.call(_defaultValue);
        _text = _value.toString();
      }

      if (_text == null) {
        continue;
      }

      final _textWidth = textWidth(_longestText, legendFontStyle);
      final _textPainter = TextPainter(
        text: TextSpan(
          text: _text,
          style: legendFontStyle,
        ),
        textAlign: valuesAlign,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(
          maxWidth: _textWidth,
          minWidth: _textWidth,
        );

      final _positionEnd =
          (size.width - (state?.defaultMargin?.right ?? 0.0)) - _textPainter.width - (valuesPadding?.right ?? 0.0);
      final _positionStart = (state?.defaultMargin?.left ?? 0.0) + (valuesPadding?.left ?? 0.0);

      _textPainter.paint(
          canvas,
          Offset(legendPosition == HorizontalLegendPosition.end ? _positionEnd : _positionStart,
              -axisStep * i * scale - (_textPainter.height + (valuesPadding?.bottom ?? 0.0))));
    }

    if (dashArray != null) {
      canvas.drawPath(dashPath(gridPath, dashArray: CircularIntervalList(dashArray)), _paint);
    } else {
      canvas.drawPath(gridPath, _paint);
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
        style: legendFontStyle,
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
        TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout();
    return textPainter.size.width;
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.only(
      top: showValues && showTopValue ? legendFontStyle?.fontSize ?? 13.0 : 0.0,
      bottom: gridWidth,
    );
  }

  @override
  EdgeInsets paddingNeeded() {
    final _textWidth = textWidth(_longestText, legendFontStyle) + (valuesPadding?.horizontal ?? 0.0);
    final _isEnd = legendPosition == HorizontalLegendPosition.end;

    return EdgeInsets.only(
      right: _isEnd ? _textWidth : 0.0,
      left: _isEnd ? 0.0 : _textWidth,
    );
  }

  @override
  HorizontalAxisDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is HorizontalAxisDecoration) {
      return HorizontalAxisDecoration._lerp(
        showValues: t < 0.5 ? showValues : endValue.showValues,
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t),
        showTopValue: t < 0.5 ? showTopValue : endValue.showTopValue,
        valuesAlign: t < 0.5 ? valuesAlign : endValue.valuesAlign,
        valuesPadding: EdgeInsets.lerp(valuesPadding, endValue.valuesPadding, t),
        gridColor: Color.lerp(gridColor, endValue.gridColor, t),
        gridWidth: lerpDouble(gridWidth, endValue.gridWidth, t),
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        axisStep: lerpDouble(axisStep, endValue.axisStep, t),
        legendFontStyle: TextStyle.lerp(legendFontStyle, endValue.legendFontStyle, t),
        horizontalAxisUnit: t > 0.5 ? endValue.horizontalAxisUnit : horizontalAxisUnit,
        legendPosition: t > 0.5 ? endValue.legendPosition : legendPosition,
        axisValue: t > 0.5 ? endValue.axisValue : axisValue,
        showGrid: t > 0.5 ? endValue.showGrid : showGrid,
      );
    }

    return this;
  }
}
