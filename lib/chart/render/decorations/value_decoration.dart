part of charts_painter;

typedef ValueFromItem = double Function(ChartItem item);

double defaultValueForItem(ChartItem item) => item.max ?? 0.0;

typedef LabelFromItem = String Function(ChartItem item);

/// Draw value of the items on them.
/// Use this only as [ChartState.foregroundDecorations] in order to be visible at all locations
/// Exact alignment can be set with [alignment]
class ValueDecoration extends DecorationPainter {
  /// Constructor for values decoration
  ValueDecoration({
    this.textStyle,
    this.alignment = Alignment.topCenter,
    this.valueArrayIndex = 0,
    this.valueGenerator = defaultValueForItem,
    this.labelGenerator,
  });

  /// Style for values to use
  final TextStyle? textStyle;

  /// Alignment of the text based on item
  final Alignment alignment;

  final ValueFromItem valueGenerator;

  /// Generate a custom label that is used.
  ///
  /// By default it will display the output from [valueGenerator] parsed to an int
  final LabelFromItem? labelGenerator;

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
        valueGenerator: endValue.valueGenerator,
      );
    }
    return this;
  }

  @override
  bool isSameType(DecorationPainter other) {
    if (other is ValueDecoration) {
      return other.valueGenerator == valueGenerator;
    }

    return false;
  }

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    assert(state.data.stackSize > valueArrayIndex,
        'Value key is not in the list!\nCheck the `valueKey` you are passing.');
  }

  void _paintText(Canvas canvas, Size size, ChartItem item, double width,
      double verticalMultiplier, double minValue) {
    final _itemMaxValue = valueGenerator(item);

    final _maxValuePainter = ValueDecoration.makeTextPainter(
      labelGenerator?.call(item) ?? '${_itemMaxValue.toInt()}',
      width,
      textStyle,
    );

    _maxValuePainter.paint(
      canvas,
      Offset(
        width * alignment.x,
        size.height -
            _itemMaxValue * verticalMultiplier +
            minValue * verticalMultiplier -
            _maxValuePainter.height * 0.5 +
            (_maxValuePainter.height * alignment.y),
      ),
    );
  }

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    final _size = (state.defaultPadding + state.defaultMargin)
        .deflateSize(constraints.biggest);
    return _size;
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    return Offset(state.defaultPadding.left + state.defaultMargin.left,
        state.defaultPadding.top + state.defaultMargin.top);
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _maxValue = state.data.maxValue - state.data.minValue;
    final _verticalMultiplier = size.height / _maxValue;

    final _listSize = state.data.listSize;
    final _itemWidth = size.width / _listSize;

    state.data.items[valueArrayIndex].asMap().forEach((index, value) {
      canvas.save();
      canvas.translate(
        index * _itemWidth,
        0.0,
      );
      _paintText(canvas, Size(index * _itemWidth, size.height), value,
          _itemWidth, _verticalMultiplier, state.data.minValue);
      canvas.restore();
    });
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
