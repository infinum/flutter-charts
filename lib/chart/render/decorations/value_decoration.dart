part of charts_painter;

/// Draw value of the items on them.
/// Use this only as [ChartState.foregroundDecorations] in order to be visible at all locations
/// Exact alignment can be set with [alignment]
class ValueDecoration extends DecorationPainter {
  /// Constructor for values decoration
  ValueDecoration({
    this.textStyle,
    this.alignment = Alignment.topCenter,
    this.valueArrayIndex = 0,
  });

  /// Style for values to use
  final TextStyle? textStyle;

  /// Alignment of the text based on item
  final Alignment alignment;

  /// Index of list in items, this is used if there are multiple lists in the chart
  ///
  /// By default this will show first list and value will be 0
  final int valueArrayIndex;

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is ValueDecoration) {
      return ValueDecoration(
        textStyle: TextStyle.lerp(textStyle, endValue.textStyle, t),
        alignment: Alignment.lerp(alignment, endValue.alignment, t) ??
            endValue.alignment,
        valueArrayIndex: endValue.valueArrayIndex,
      );
    }
    return this;
  }

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    assert(state.data.stackSize > valueArrayIndex,
        'Value key is not in the list!\nCheck the `valueKey` you are passing.');
  }

  void _paintText(Canvas canvas, Size size, ChartItem item, double width,
      double verticalMultiplier, double minValue) {
    final _itemMaxValue = item.max ?? 0.0;

    final _maxValuePainter = ValueDecoration.makeTextPainter(
      '${_itemMaxValue.toInt()}',
      width,
      textStyle,
    );

    _maxValuePainter.paint(
      canvas,
      Offset(
        width * alignment.x,
        -_itemMaxValue * verticalMultiplier -
            minValue -
            _maxValuePainter.height * 0.2 +
            (_maxValuePainter.height * alignment.y),
      ),
    );
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _size = state.defaultPadding.deflateSize(size);
    final _maxValue = state.data.maxValue - state.data.minValue;
    final _verticalMultiplier = _size.height / _maxValue;
    final _minValue = state.data.minValue * _verticalMultiplier;

    final _listSize = state.data.listSize;
    final _itemWidth = _size.width / _listSize;

    canvas.save();
    canvas.translate(
        state.defaultPadding.left + state.defaultMargin.left - _itemWidth,
        size.height + state.defaultMargin.top);

    state.data.items[valueArrayIndex].asMap().forEach((index, value) {
      canvas.translate(
        _itemWidth,
        0.0,
      );
      _paintText(canvas, Size(index * _itemWidth, _size.height), value,
          _itemWidth, _verticalMultiplier, _minValue);
    });

    canvas.restore();
  }

  /// Get default text painter with set [value]
  /// Helper for [_paintText]
  static TextPainter makeTextPainter(
      String value, double width, TextStyle? style,
      {bool hasMaxWidth = true}) {
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
