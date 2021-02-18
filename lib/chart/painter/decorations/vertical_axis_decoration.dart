part of flutter_charts;

typedef AxisValueFromIndex = String Function(int index);

enum VerticalLegendPosition {
  top,
  bottom,
}

class VerticalAxisDecoration extends DecorationPainter {
  VerticalAxisDecoration({
    this.showGrid = true,
    this.showValues = false,
    bool endWithChart = false,
    this.valuesAlign = TextAlign.center,
    this.valuesPadding = EdgeInsets.zero,
    this.axisValueFromIndex = defaultAxisValue,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.dashArray,
    this.itemAxisStep = 1,
    this.verticalLegendPosition = VerticalLegendPosition.bottom,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart ? 1.0 : 0.0;

  VerticalAxisDecoration._lerp({
    this.showGrid = true,
    this.showValues = false,
    double endWithChart = 0.0,
    this.valuesAlign = TextAlign.center,
    this.valuesPadding = EdgeInsets.zero,
    this.axisValueFromIndex = defaultAxisValue,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.dashArray,
    this.itemAxisStep = 1,
    this.verticalLegendPosition = VerticalLegendPosition.bottom,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  }) : _endWithChart = endWithChart;

  bool get endWithChart => _endWithChart > 0.5;
  final double _endWithChart;

  final List<double> dashArray;

  final bool showGrid;
  final bool showValues;
  final TextAlign valuesAlign;
  final EdgeInsets valuesPadding;

  final Color gridColor;
  final double gridWidth;
  final double itemAxisStep;

  final VerticalLegendPosition verticalLegendPosition;
  final TextStyle legendFontStyle;

  final AxisValueFromIndex axisValueFromIndex;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state.defaultPadding.deflateSize(size) ?? size;
    final int _listSize = state.data.listSize;
    final _itemWidth = (_size.width - gridWidth) / _listSize;

    final _paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = gridWidth;

    canvas.save();
    canvas.translate(
      (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left,
      size.height + state.defaultMargin.top,
    );

    final gridPath = Path();

    for (int i = 0; i <= _listSize / itemAxisStep; i++) {
      if (showGrid) {
        final _showValuesBottom = showValues ? (state.defaultMargin.bottom * (1 - _endWithChart)) : gridWidth;
        final _showValuesTop = -size.height - (showValues ? (state.defaultMargin.top * (1 - _endWithChart)) : 0.0);

        gridPath.moveTo(_itemWidth * i * itemAxisStep + gridWidth / 2, _showValuesBottom);
        gridPath.lineTo(_itemWidth * i * itemAxisStep + gridWidth / 2, _showValuesTop);
      }

      if (!showValues || i == _listSize / itemAxisStep) {
        continue;
      }

      String _text;

      try {
        _text = axisValueFromIndex((itemAxisStep * i).toInt());
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
            _itemWidth * i * itemAxisStep + (valuesPadding?.left ?? 0.0),
            verticalLegendPosition == VerticalLegendPosition.top
                ? -size.height - _textPainter.height - (valuesPadding?.bottom ?? 0.0)
                : _textPainter.height - _textPainter.height + (valuesPadding?.top ?? 0.0)),
      );
    }

    if (dashArray != null) {
      canvas.drawPath(dashPath(gridPath, dashArray: CircularIntervalList(dashArray)), _paint);
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
    final _isBottom = verticalLegendPosition == VerticalLegendPosition.bottom;

    return EdgeInsets.only(
      bottom: _isBottom ? _value : 0.0,
      top: !_isBottom ? _value : 0.0,
    );
  }

  @override
  EdgeInsets paddingNeeded() {
    return valuesPadding ?? EdgeInsets.zero;
  }

  @override
  VerticalAxisDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is VerticalAxisDecoration) {
      return VerticalAxisDecoration._lerp(
        gridColor: Color.lerp(gridColor, endValue.gridColor, t),
        gridWidth: lerpDouble(gridWidth, endValue.gridWidth, t),
        itemAxisStep: lerpDouble(itemAxisStep, endValue.itemAxisStep, t),
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t),
        valuesPadding: EdgeInsets.lerp(valuesPadding, endValue.valuesPadding, t),
        showGrid: t > 0.5 ? endValue.showGrid : showGrid,
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        showValues: t > 0.5 ? endValue.showValues : showValues,
        valuesAlign: t > 0.5 ? endValue.valuesAlign : valuesAlign,
        axisValueFromIndex: t > 0.5 ? endValue.axisValueFromIndex : axisValueFromIndex,
        verticalLegendPosition: t > 0.5 ? endValue.verticalLegendPosition : verticalLegendPosition,
        legendFontStyle: TextStyle.lerp(legendFontStyle, endValue.legendFontStyle, t),
      );
    }

    return this;
  }
}
