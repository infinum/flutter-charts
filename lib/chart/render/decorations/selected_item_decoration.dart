part of charts_painter;

/// Show selected item in Cupertino style (Health app)
class SelectedItemDecoration extends DecorationPainter {
  /// Constructor for selected item decoration
  SelectedItemDecoration(
    this.selectedItem, {
    this.selectedColor = Colors.red,
    this.backgroundColor = Colors.grey,
    this.selectedStyle = const TextStyle(fontSize: 13.0),
    this.animate = false,
    bool showText = true,
    this.showOnTop = true,
    this.selectedArrayIndex = 0,
    this.child,
    this.topMargin = 0.0,
  }) : showText = showText && (child == null);

  /// Index of selected item
  final int? selectedItem;

  /// Color of selected indicator and text background
  final Color selectedColor;

  /// Color for selected item, this color is shown as overlay, use with alpha!
  final Color backgroundColor;

  /// Should [selectedItem] animate from one item to next
  final bool animate;

  final bool showText;

  final bool showOnTop;

  /// Color of selected item text
  final TextStyle selectedStyle;

  final Widget? child;
  final double topMargin;

  /// Index of list whose data to show
  /// By default it will use first list to this value will be `0`
  final int selectedArrayIndex;

  @override
  Widget getRenderer(ChartState state) {
    if (child != null) {
      return ChartDecorationChildRenderer(
        state,
        this,
        child!,
      );
    }

    return super.getRenderer(state);
  }

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    assert(state.data.stackSize > selectedArrayIndex,
        'Selected key is not in the list!\nCheck the `selectedKey` you are passing.');
  }

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    final _listSize = state.data.listSize;
    final _itemWidth =
        constraints.deflate(state.defaultMargin).maxWidth / _listSize;

    return Size(
      _itemWidth,
      constraints.deflate(state.defaultMargin - marginNeeded()).maxHeight,
    );
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    final _width =
        (size.width - state.defaultMargin.horizontal) / state.data.listSize;

    final selectedItem = this.selectedItem;
    if (selectedItem != null) {
      final _selectedItemMax =
          state.data.items[selectedArrayIndex][selectedItem].max ?? 0.0;
      final _selectedItemMin =
          state.data.items[selectedArrayIndex][selectedItem].min ?? 0.0;

      final _maxValue = state.data.maxValue - state.data.minValue;
      final _height = size.height - marginNeeded().vertical;
      final scale = _height / _maxValue;

      return Offset(
          state.defaultMargin.left + _width * selectedItem,
          showOnTop
              ? (state.defaultMargin - marginNeeded()).top
              : size.height -
                  ((_selectedItemMax -
                          (min(_selectedItemMin, state.data.minValue))) *
                      scale));
    }

    return Offset.zero;
  }

  void _drawText(
      Canvas canvas, Size size, double totalWidth, ChartState state) {
    final _item = selectedItem;
    if (_item == null) {
      return;
    }
    final width = size.width;
    final _selectedItem = state.data.items[selectedArrayIndex][_item];

    final _maxValuePainter = ValueDecoration.makeTextPainter(
      _selectedItem.max?.toStringAsFixed(2) ?? '',
      width,
      selectedStyle,
      hasMaxWidth: false,
    );
    final _itemWidth = max(
        state.itemOptions.minBarWidth ?? 0.0,
        min(state.itemOptions.maxBarWidth ?? double.infinity,
            size.width - state.itemOptions.padding.horizontal));

    const _size = 2.0;
    final _maxValue = state.data.maxValue - state.data.minValue;
    final _height = size.height - marginNeeded().vertical;
    final scale = _height / _maxValue;

    final _itemMaxValue = _selectedItem.max ?? 0.0;
    final _itemMinValue = _selectedItem.min ?? 0.0;
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (_selectedItem.isEmpty || _itemMaxValue < state.data.minValue) {
      return;
    }

    if (_itemMinValue != 0.0) {
      canvas.drawRect(
        Rect.fromPoints(
          Offset(
            state.itemOptions.padding.left + _itemWidth / 2 - _size / 2,
            0.0,
          ),
          Offset(
            state.itemOptions.padding.left + _itemWidth / 2 + _size / 2,
            (_itemMaxValue - _itemMinValue) * scale,
          ),
        ),
        Paint()..color = selectedColor,
      );
    }

    if (showOnTop) {
      _drawLine(canvas, size, state);
    }

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
              Offset(
                width / 2 - _maxValuePainter.width / 2,
                ((size.height -
                            ((_itemMaxValue -
                                    (min(_itemMinValue, state.data.minValue))) *
                                scale) -
                            (selectedStyle.fontSize ?? 0.0) * 1.4) *
                        (showOnTop ? 0 : 1)) +
                    ((showOnTop ? 1 : 0) *
                        (selectedStyle.fontSize ?? 0.0) *
                        1.4),
              ),
              Offset(
                width / 2 + _maxValuePainter.width / 2,
                ((size.height -
                            ((_itemMaxValue -
                                    (min(_itemMinValue, state.data.minValue))) *
                                scale) -
                            (selectedStyle.fontSize ?? 0.0) * 0.4) *
                        (showOnTop ? 0 : 1)) +
                    ((showOnTop ? 1 : 0) *
                        (selectedStyle.fontSize ?? 0.0) *
                        0.4),
              )),
          const Radius.circular(8.0),
        ).inflate(4),
        Paint()..color = selectedColor);

    _maxValuePainter.paint(
      canvas,
      Offset(
        width / 2 - _maxValuePainter.width / 2,
        ((size.height -
                    ((_itemMaxValue -
                            (min(_itemMinValue, state.data.minValue))) *
                        scale) -
                    (selectedStyle.fontSize ?? 0.0) * 1.4) *
                (showOnTop ? 0 : 1)) +
            ((showOnTop ? 1 : 0) * (selectedStyle.fontSize ?? 0.0) * 0.4),
      ),
    );
  }

  void _drawLine(Canvas canvas, Size size, ChartState state) {
    final _item = selectedItem;
    if (_item == null) {
      return;
    }
    final _selectedItem = state.data.items[selectedArrayIndex][_item];

    final _itemWidth = max(
        state.itemOptions.minBarWidth ?? 0.0,
        min(state.itemOptions.maxBarWidth ?? double.infinity,
            size.width - state.itemOptions.padding.horizontal));

    const _size = 2.0;
    final _maxValue = state.data.maxValue - state.data.minValue;
    final _height = size.height - marginNeeded().vertical;
    final scale = _height / _maxValue;

    final _itemMaxValue = _selectedItem.max ?? 0.0;
    final _itemMinValue = _selectedItem.min ?? 0.0;

    canvas.drawRect(
      Rect.fromPoints(
        Offset(
          state.itemOptions.padding.left + _itemWidth / 2 - _size / 2,
          (selectedStyle.fontSize ?? 0.0) * 1.4,
        ),
        Offset(
          state.itemOptions.padding.left + _itemWidth / 2 + _size / 2,
          size.height -
              ((_itemMaxValue - (min(_itemMinValue, state.data.minValue))) *
                  scale),
        ),
      ),
      Paint()..color = selectedColor,
    );
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    if (child != null) {
      return;
    }

    final _listSize = state.data.listSize;
    final _item = selectedItem;

    if (_item == null || _listSize <= _item || _item.isNegative) {
      return;
    }
    _drawItem(canvas, size, state);
    if (showText) {
      _drawText(canvas, size, size.width, state);
    }

    // Restore canvas
    canvas.restore();
  }

  void _drawItem(Canvas canvas, Size size, ChartState state) {
    canvas.drawRect(
      Rect.fromPoints(
          Offset(0.0, marginNeeded().top), Offset(size.width, size.height)),
      Paint()
        ..color = backgroundColor
        ..blendMode = BlendMode.overlay,
    );
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.only(
        top: showOnTop
            ? (showText
                ? (selectedStyle.fontSize ?? 0) * 1.8
                : child != null
                    ? topMargin
                    : 0.0)
            : 0.0);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SelectedItemDecoration) {
      return SelectedItemDecoration(
        animate
            ? (lerpDouble(selectedItem?.toDouble(),
                        endValue.selectedItem?.toDouble(), t) ??
                    0)
                .round()
            : endValue.selectedItem,
        selectedColor: Color.lerp(selectedColor, endValue.selectedColor, t) ??
            endValue.selectedColor,
        backgroundColor:
            Color.lerp(backgroundColor, endValue.backgroundColor, t) ??
                endValue.backgroundColor,
        selectedStyle:
            TextStyle.lerp(selectedStyle, endValue.selectedStyle, t) ??
                endValue.selectedStyle,
        animate: endValue.animate,
        selectedArrayIndex: endValue.selectedArrayIndex,
        showOnTop: t < 0.5 ? showOnTop : endValue.showOnTop,
        showText: t < 0.5 ? showText : endValue.showText,
        child: t < 0.5 ? child : endValue.child,
        topMargin: lerpDouble(topMargin, endValue.topMargin, t) ?? 0.0,
      );
    }

    return this;
  }
}
