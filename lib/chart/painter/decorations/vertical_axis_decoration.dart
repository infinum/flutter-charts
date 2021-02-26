part of charts_painter;

typedef AxisValueFromIndex = String Function(int index);

/// Position of legend in [VerticalAxisDecoration]
enum VerticalLegendPosition {
  /// Show vertical axis above the chart
  top,

  /// Show vertical axis below the chart
  bottom,
}

/// Decoration for drawing vertical lines on the chart, decoration can add vertical axis legend
///
/// This can be used if you don't need anything from [HorizontalAxisDecoration], otherwise you might
/// consider using [GridDecoration]
class VerticalAxisDecoration extends DecorationPainter {
  /// Constructor for vertical axis decoration
  VerticalAxisDecoration({
    this.showLines = true,
    this.showValues = false,
    bool endWithChart = false,
    this.valuesAlign = TextAlign.center,
    this.valuesPadding = EdgeInsets.zero,
    this.valueFromIndex = defaultAxisValue,
    this.lineColor = Colors.grey,
    this.lineWidth = 1.0,
    this.dashArray,
    this.axisStep = 1,
    this.legendPosition = VerticalLegendPosition.bottom,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart ? 1.0 : 0.0;

  VerticalAxisDecoration._lerp({
    this.showLines = true,
    this.showValues = false,
    double endWithChart = 0.0,
    this.valuesAlign = TextAlign.center,
    this.valuesPadding = EdgeInsets.zero,
    this.valueFromIndex = defaultAxisValue,
    this.lineColor = Colors.grey,
    this.lineWidth = 1.0,
    this.dashArray,
    this.axisStep = 1,
    this.legendPosition = VerticalLegendPosition.bottom,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart;

  /// This decoration can continue beyond padding set by [ChartState]
  /// setting this to true will stop drawing on padding, and will end
  /// at same place where the chart will end
  ///
  /// This does not apply to axis legend text, text can still be shown on the padding part
  bool get endWithChart => _endWithChart > 0.5;
  final double _endWithChart;

  /// Dashed array for showing lines, if this is not set the line is solid
  final List<double> dashArray;

  /// Show vertical lines
  final bool showLines;

  /// Show axis legend values
  final bool showValues;

  /// Align text on the axis legend
  final TextAlign valuesAlign;

  /// Padding for the values in the axis legend
  final EdgeInsets valuesPadding;

  /// Set color to paint horizontal lines with
  final Color lineColor;

  /// Set line width
  final double lineWidth;

  /// Step for lines
  final double axisStep;

  /// Position of vertical legend
  /// Default: [VerticalLegendPosition.bottom]
  /// Can be [VerticalLegendPosition.bottom] or [VerticalLegendPosition.top]
  final VerticalLegendPosition legendPosition;

  /// Text style for axis legend
  final TextStyle legendFontStyle;

  /// Generate vertical axis legend from index steps
  final AxisValueFromIndex valueFromIndex;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state.defaultPadding.deflateSize(size) ?? size;
    final _listSize = state.data.listSize;
    final _itemWidth = (_size.width - lineWidth) / _listSize;

    final _paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    canvas.save();
    canvas.translate(
      (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left,
      size.height + state.defaultMargin.top,
    );

    final gridPath = Path();

    for (var i = 0; i <= _listSize / axisStep; i++) {
      if (showLines) {
        final _showValuesBottom = showValues
            ? (state.defaultMargin.bottom * (1 - _endWithChart))
            : lineWidth;
        final _showValuesTop = -size.height -
            (showValues
                ? (state.defaultMargin.top * (1 - _endWithChart))
                : 0.0);

        gridPath.moveTo(
            _itemWidth * i * axisStep + lineWidth / 2, _showValuesBottom);
        gridPath.lineTo(
            _itemWidth * i * axisStep + lineWidth / 2, _showValuesTop);
      }

      if (!showValues || i == _listSize / axisStep) {
        continue;
      }

      String _text;

      try {
        _text = valueFromIndex((axisStep * i).toInt());
      } catch (e) {
        /// Invalid value, index out of range can happen here.
      }

      if (_text == null) {
        continue;
      }

      final _textPainter = TextPainter(
        text: TextSpan(
          text: _text,
          style: legendFontStyle,
        ),
        textAlign: valuesAlign,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(
          maxWidth: _itemWidth,
          minWidth: _itemWidth,
        );

      _textPainter.paint(
        canvas,
        Offset(
            _itemWidth * i * axisStep + (valuesPadding?.left ?? 0.0),
            legendPosition == VerticalLegendPosition.top
                ? -size.height -
                    _textPainter.height -
                    (valuesPadding?.bottom ?? 0.0)
                : _textPainter.height -
                    _textPainter.height +
                    (valuesPadding?.top ?? 0.0)),
      );
    }

    if (dashArray != null) {
      canvas.drawPath(
          dashPath(gridPath, dashArray: CircularIntervalList(dashArray)),
          _paint);
    } else {
      canvas.drawPath(gridPath, _paint);
    }
    canvas.restore();
  }

  @override
  EdgeInsets marginNeeded() {
    if (!showValues) {
      return EdgeInsets.zero;
    }

    final _value = legendFontStyle.fontSize + (valuesPadding?.vertical ?? 0.0);
    final _isBottom = legendPosition == VerticalLegendPosition.bottom;

    return EdgeInsets.only(
      bottom: _isBottom ? _value : 0.0,
      top: !_isBottom ? _value : 0.0,
    );
  }

  @override
  VerticalAxisDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is VerticalAxisDecoration) {
      return VerticalAxisDecoration._lerp(
        lineColor: Color.lerp(lineColor, endValue.lineColor, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        axisStep: lerpDouble(axisStep, endValue.axisStep, t),
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t),
        valuesPadding:
            EdgeInsets.lerp(valuesPadding, endValue.valuesPadding, t),
        showLines: t > 0.5 ? endValue.showLines : showLines,
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        showValues: t > 0.5 ? endValue.showValues : showValues,
        valuesAlign: t > 0.5 ? endValue.valuesAlign : valuesAlign,
        valueFromIndex: t > 0.5 ? endValue.valueFromIndex : valueFromIndex,
        legendPosition: t > 0.5 ? endValue.legendPosition : legendPosition,
        legendFontStyle:
            TextStyle.lerp(legendFontStyle, endValue.legendFontStyle, t),
      );
    }

    return this;
  }
}
