part of flutter_charts;

typedef AxisValueFromIndex = String Function(int index);

String defaultAxisValue(int index) => '$index';

class VerticalAxisDecoration extends DecorationPainter {
  VerticalAxisDecoration({
    this.showGrid = true,
    this.showValues = false,
    this.endWithChart = false,
    this.valuesAlign = TextAlign.center,
    this.valuesPadding = EdgeInsets.zero,
    this.axisValueFromIndex = defaultAxisValue,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.itemAxisStep = 1,
    this.legendFontStyle = const TextStyle(fontSize: 13.0),
  });

  final bool showGrid;
  final bool showValues;
  final bool endWithChart;
  final TextAlign valuesAlign;
  final EdgeInsets valuesPadding;

  final Color gridColor;
  final double gridWidth;
  final double itemAxisStep;

  final TextStyle legendFontStyle;

  final AxisValueFromIndex axisValueFromIndex;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state?.defaultPadding?.deflateSize(size) ?? size;
    final _itemWidth = (_size.width - 0.0) / state.items.length;

    final _paint = Paint()
      ..color = gridColor
      ..strokeWidth = gridWidth;

    canvas.save();
    canvas.translate(
      (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left,
      size.height + state.defaultMargin.top,
    );

    for (int i = 0; i <= state.items.length / itemAxisStep; i++) {
      if (showGrid) {
        canvas.drawLine(
          Offset(_itemWidth * i * itemAxisStep, (!endWithChart && showValues) ? 24.0 : 0.0),
          Offset(_itemWidth * i * itemAxisStep, -size.height),
          _paint,
        );
      }

      if (!showValues || i == state.items.length / itemAxisStep) {
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
          style: legendFontStyle.copyWith(color: state?.options?.axisLegendTextColor ?? Colors.grey),
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
        Offset(_itemWidth * i * itemAxisStep + (valuesPadding?.left ?? 0.0),
            _textPainter.height + (valuesPadding?.top ?? 0.0)),
      );
    }
    canvas.restore();
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.only(bottom: showValues ? 48.0 : 0.0);
  }

  @override
  VerticalAxisDecoration animateTo(DecorationPainter endValue, double t) {
    if (endValue is VerticalAxisDecoration) {
      return VerticalAxisDecoration(
        gridColor: Color.lerp(gridColor, endValue.gridColor, t),
        gridWidth: lerpDouble(gridWidth, endValue.gridWidth, t),
        itemAxisStep: lerpDouble(itemAxisStep, endValue.itemAxisStep, t),
        showGrid: t > 0.5 ? endValue.showGrid : showGrid,
        showValues: t > 0.5 ? endValue.showValues : showValues,
        valuesAlign: t > 0.5 ? endValue.valuesAlign : valuesAlign,
        axisValueFromIndex: t > 0.5 ? endValue.axisValueFromIndex : axisValueFromIndex,
        legendFontStyle: TextStyle.lerp(legendFontStyle, endValue.legendFontStyle, t),
      );
    }

    return this;
  }
}
