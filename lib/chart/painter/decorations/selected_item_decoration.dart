part of charts_painter;

/// Show selected item in Cupertino style (Health app)
class SelectedItemDecoration extends DecorationPainter {
  /// Constructor for selected item decoration
  SelectedItemDecoration(
    this.selectedItem, {
    this.selectedColor = Colors.red,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.textSize = 28.0,
    this.animate = false,
    this.selectedArrayIndex = 0,
  });

  /// Index of selected item
  final int? selectedItem;

  /// Color of selected indicator and text background
  final Color selectedColor;

  /// Color for selected item, this color is shown as overlay, use with alpha!
  final Color backgroundColor;

  /// Should [selectedItem] animate from one item to next
  final bool animate;

  /// Color of selected item text
  final Color textColor;

  /// Size for selected item text
  final double textSize;

  /// Index of list whose data to show
  /// By default it will use first list to this value will be `0`
  final int selectedArrayIndex;

  @override
  void initDecoration(ChartState state) {
    super.initDecoration(state);
    assert(state.data.stackSize > selectedArrayIndex,
        'Selected key is not in the list!\nCheck the `selectedKey` you are passing.');
  }

  void _drawText(Canvas canvas, Size size, double width, double totalWidth, ChartState state) {
    final _item = selectedItem;
    if (_item == null) {
      return;
    }

    final _selectedItem = state.data.items[selectedArrayIndex][_item];

    final _maxValuePainter = ValueDecoration.makeTextPainter(
      _selectedItem.max?.toStringAsFixed(2) ?? '',
      width,
      TextStyle(
        fontSize: textSize,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      hasMaxWidth: false,
    );

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
              Offset(
                width / 2 - _maxValuePainter.width / 2,
                size.height - textSize * 1.2,
              ),
              Offset(
                width / 2 + _maxValuePainter.width / 2,
                size.height - textSize * 0.2,
              )),
          const Radius.circular(8.0),
        ).inflate(4),
        Paint()..color = selectedColor);

    _maxValuePainter.paint(
      canvas,
      Offset(
        width / 2 - _maxValuePainter.width / 2,
        size.height - textSize * 1.3,
      ),
    );
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _listSize = state.data.listSize;
    final _item = selectedItem;

    if (_item == null || _listSize <= _item || _item.isNegative) {
      return;
    }

    final _size = state.defaultPadding.deflateSize(size);
    final _itemWidth = _size.width / _listSize;

    // Save, and translate the canvas so [0,0] is top left of item at [index] position
    canvas.save();
    canvas.translate(
      state.defaultPadding.left + (_itemWidth * _item) + state.defaultMargin.left,
      size.height + state.defaultMargin.top + state.defaultPadding.top,
    );

    _drawItem(canvas, Size(_itemWidth, -size.height), state);
    _drawText(canvas, Size(_itemWidth, -size.height), _itemWidth, size.width, state);

    // Restore canvas
    canvas.restore();
  }

  void _drawItem(Canvas canvas, Size size, ChartState state) {
    final _itemWidth = max(state.itemOptions.minBarWidth ?? 0.0,
        min(state.itemOptions.maxBarWidth ?? double.infinity, size.width - state.itemOptions.padding.horizontal));

    const _size = 2.0;
    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = size.height / _maxValue;

    final _selectedItem = selectedItem;
    if (_selectedItem == null) {
      return;
    }

    final _item = state.data.items[selectedArrayIndex][_selectedItem];

    final _itemMaxValue = _item.max ?? 0.0;
    final _itemMinValue = _item.min ?? 0.0;
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (_item.isEmpty || _itemMaxValue < state.data.minValue) {
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
            _itemMinValue * scale,
          ),
        ),
        Paint()..color = selectedColor,
      );
    }

    canvas.drawRect(
      Rect.fromPoints(
        Offset(
          state.itemOptions.padding.left + _itemWidth / 2 - _size / 2,
          _itemMaxValue * scale,
        ),
        Offset(
          state.itemOptions.padding.left + _itemWidth / 2 + _size / 2,
          size.height - textSize * 0.2,
        ),
      ),
      Paint()..color = selectedColor,
    );

    canvas.drawRect(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      Paint()
        ..color = backgroundColor
        ..blendMode = BlendMode.overlay,
    );
  }

  @override
  EdgeInsets marginNeeded() {
    return EdgeInsets.only(top: textSize * 1.3);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SelectedItemDecoration) {
      return SelectedItemDecoration(
        animate
            ? (lerpDouble(selectedItem?.toDouble(), endValue.selectedItem?.toDouble(), t) ?? 0).round()
            : endValue.selectedItem,
        selectedColor: Color.lerp(selectedColor, endValue.selectedColor, t) ?? endValue.selectedColor,
        backgroundColor: Color.lerp(backgroundColor, endValue.backgroundColor, t) ?? endValue.backgroundColor,
        textColor: Color.lerp(textColor, endValue.textColor, t) ?? endValue.textColor,
        textSize: lerpDouble(textSize, endValue.textSize, t) ?? endValue.textSize,
        animate: endValue.animate,
        selectedArrayIndex: endValue.selectedArrayIndex,
      );
    }

    return this;
  }
}
