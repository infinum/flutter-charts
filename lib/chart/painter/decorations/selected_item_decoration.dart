part of flutter_charts;

/// Show selected item in Cupertino style (Health app)
class CupertinoSelectedPainter extends DecorationPainter {
  CupertinoSelectedPainter(this.selectedIndex);

  final int selectedIndex;

  void _drawText(Canvas canvas, Size size, double width, double totalWidth, ChartState state) {
    final _maxValuePainter = ItemPainter.makeTextPainter(
      state.items[selectedIndex].max.toStringAsFixed(2),
      width,
      TextStyle(
        fontSize: 28.0,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      hasMaxWidth: false,
    );

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
              Offset(
                width / 2 - _maxValuePainter.width / 2,
                size.height,
              ),
              Offset(
                width / 2 + _maxValuePainter.width / 2,
                size.height - _maxValuePainter.height,
              )),
          Radius.circular(8.0),
        ).inflate(4),
        Paint()..color = Colors.grey);

    _maxValuePainter.paint(
      canvas,
      Offset(
        width / 2 - _maxValuePainter.width / 2,
        size.height - _maxValuePainter.height,
      ),
    );
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    if (selectedIndex == null || state.items.length <= selectedIndex || selectedIndex.isNegative) {
      return;
    }

    final _size = state?.defaultPadding?.deflateSize(size) ?? size;
    final _itemWidth = _size.width / state.items.length;

    // Save, and translate the canvas so [0,0] is top left of item at [index] position
    canvas.save();
    canvas.translate(
      (state?.defaultPadding?.left ?? 0.0) + (_itemWidth * selectedIndex) + state.defaultMargin.left,
      size.height + state.defaultMargin.top + state.defaultPadding.top,
    );

    _drawItem(canvas, Size(_itemWidth, -size.height), state);
    _drawText(canvas, Size(_itemWidth, -size.height), _itemWidth, size.width, state);

    // Restore canvas
    canvas.restore();
  }

  void _drawItem(Canvas canvas, Size size, ChartState state) {
    final _padding = state?.itemOptions?.padding ?? EdgeInsets.zero;

    final _itemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0,
        min(state?.itemOptions?.maxBarWidth ?? double.infinity, size.width - _padding.horizontal));

    final _size = 2.0;

    ChartItem _item = state.items[selectedIndex];
    // If item is empty, or it's max value is below chart's minValue then don't draw it.
    // minValue can be below 0, this will just ensure that animation is drawn correctly.
    if (_item.isEmpty || _item.max < state?.minValue) {
      return;
    }

    canvas.drawRect(
      Rect.fromPoints(
        Offset(
          _padding.left + _itemWidth / 2 - _size / 2,
          0.0,
        ),
        Offset(
          _padding.left + _itemWidth / 2 + _size / 2,
          size.height,
        ),
      ),
      Paint()..color = Colors.grey,
    );

    canvas.drawRect(
      Rect.fromPoints(Offset(0.0, 0.0), Offset(size.width, size.height)),
      Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..blendMode = BlendMode.srcOver,
    );
  }

  @override
  EdgeInsets marginNeeded() {
    return const EdgeInsets.only(top: 36.0);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is CupertinoSelectedPainter) {
      return CupertinoSelectedPainter(
        endValue.selectedIndex,
        // lerpDouble(selectedIndex?.toDouble(), endValue.selectedIndex?.toDouble(), t)?.round(),
      );
    }

    return this;
  }
}
