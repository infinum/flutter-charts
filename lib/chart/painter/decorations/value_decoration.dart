part of flutter_charts;

class ValueDecoration extends DecorationPainter {
  ValueDecoration({
    this.textStyle,
    this.alignment = Alignment.topCenter,
    this.valueKey = 0,
  });

  final TextStyle textStyle;
  final Alignment alignment;
  final int valueKey;

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is ValueDecoration) {
      return ValueDecoration(
        textStyle: TextStyle.lerp(textStyle, endValue.textStyle, t),
        alignment: Alignment.lerp(alignment, endValue.alignment, t),
        valueKey: endValue.valueKey,
      );
    }
    return this;
  }

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    assert(state.items.length > valueKey, 'Value key is not in the list!\nCheck the `valueKey` you are passing.');
  }

  void _paintText(Canvas canvas, Size size, ChartItem item, double width, double verticalMultiplier, double minValue) {
    final _maxValuePainter = ValueDecoration.makeTextPainter(
      '${item.max.toInt()}',
      width,
      textStyle,
    );

    _maxValuePainter.paint(
      canvas,
      Offset(
        width * alignment.x,
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

    final int _listSize = state.items.fold(0, (previousValue, element) => max(previousValue, element.length));
    final _itemWidth = _size.width / _listSize;

    canvas.save();
    canvas.translate((state?.defaultPadding?.left ?? 0.0) + state.defaultMargin.left - _itemWidth,
        size.height + state.defaultMargin.top);

    state.items[valueKey].forEach((value) {
      final _index = state.items[valueKey].indexOf(value);

      // canvas.save();
      canvas.translate(
        _itemWidth,
        0.0,
      );
      _paintText(canvas, Size(_index * _itemWidth, _size.height), value, _itemWidth, _verticalMultiplier, _minValue);
      // canvas.restore();
    });

    canvas.restore();
  }

  /// Get default text painter with set [value]
  /// Helper for [_paintText]
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
