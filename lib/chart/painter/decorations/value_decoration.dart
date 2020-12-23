part of flutter_charts;

class ValueDecoration extends DecorationPainter {
  ValueDecoration({
    this.textStyle,
    this.alignment = Alignment.topCenter,
  });

  ChartState state;

  final TextStyle textStyle;
  final Alignment alignment;

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is ValueDecoration) {
      return ValueDecoration(
        textStyle: TextStyle.lerp(textStyle, endValue.textStyle, t),
        alignment: Alignment.lerp(alignment, endValue.alignment, t),
      );
    }
    return this;
  }

  @override
  void initDecoration(ChartState state) {
    this.state = state;
  }

  void paintText(Canvas canvas, Size size, ChartItem item, double width, double verticalMultiplier, double minValue) {
    final _padding = state?.itemOptions?.padding;

    final _maxValuePainter = ValueDecoration.makeTextPainter(
      '${item.max.toInt()}',
      width,
      textStyle,
    );

    _maxValuePainter.paint(
      canvas,
      Offset(
        (_padding?.left ?? 0.0) + (width * alignment.x * 0.4),
        -item.max * verticalMultiplier -
            minValue -
            _maxValuePainter.height * 0.2 +
            (_maxValuePainter.height * alignment.y),
      ),
    );
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state.defaultPadding.deflateSize(size) ?? size;
    final _maxValue = state.maxValue - state.minValue;
    final _verticalMultiplier = _size.height / _maxValue;
    final _minValue = state.minValue * _verticalMultiplier;

    final _itemWidth = _size.width / state.items.length;

    state.items.forEach((key, value) {
      canvas.save();
      canvas.translate(
        (state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left + _itemWidth * key,
        size.height + state.defaultMargin.top,
      );
      paintText(canvas, Size(key * _itemWidth, _size.height), value, _itemWidth, _verticalMultiplier, _minValue);
      canvas.restore();
    });
  }

  /// Get default text painter with set [value]
  /// Helper for [paintText]
  static TextPainter makeTextPainter(String value, double width, TextStyle style, {bool hasMaxWidth = true}) {
    final _painter = TextPainter(
      text: TextSpan(
        text: value,
        style: style,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    if (hasMaxWidth) {
      _painter.layout(
        maxWidth: width,
        minWidth: width,
      );
    } else {
      _painter.layout(
        minWidth: width,
      );
    }

    return _painter;
  }
}
