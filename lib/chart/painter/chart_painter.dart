part of charts_painter;

/// Custom painter for charts
class _ChartPainter extends CustomPainter {
  const _ChartPainter(this.state);

  final ChartState state;

  final bool _debugBoundary = false;

  @override
  void paint(Canvas canvas, Size size) {
    if (_debugBoundary) {
      canvas.drawRect(
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)).inflate(2),
          Paint()
            ..color = Colors.red.withOpacity(0.4)
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke);

      canvas.drawRect(
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)), Paint()..color = Colors.red.withOpacity(0.1));
    }

    final _scrollableItemWidth = max(state.itemOptions.minBarWidth ?? 0.0, state.itemOptions.maxBarWidth ?? 0.0);

    final _listSize = state.data.listSize;

    size = Size(
        size.width +
            (size.width - ((_scrollableItemWidth + state.itemOptions.padding!.horizontal) * _listSize)) *
                state.behaviour._isScrollable,
        size.height);

    /// Default chart padding (this is to make place for legend and any other decorations that are inserted)
    final _paddingSize = state.defaultMargin.deflateSize(size);

    /// Final usable size for chart
    final _size = state.defaultPadding.deflateSize(_paddingSize);

    /// Final usable space for one item in the chart
    final _itemWidth = _size.width / _listSize;

    void _drawDecoration(DecorationPainter decoration) => decoration.draw(canvas, _paddingSize, state);

    // First draw background decorations
    state.backgroundDecorations.forEach(_drawDecoration);

    final _stack = 1 - state.behaviour._multiValueStacked;
    final _width = _itemWidth / max(1, state.data.stackSize * _stack);

    final _stackWidth = _width -
        ((state.itemOptions.multiValuePadding?.horizontal ?? 0.0) / max(1, state.data.stackSize * _stack)) * _stack;

    // Save, and translate the canvas so [0,0] is top left of the first item
    canvas.save();
    canvas.translate(
      state.defaultPadding.left + state.defaultMargin.left - _stackWidth,
      size.height - (state.defaultMargin.bottom + state.defaultPadding.bottom),
    );

    List.generate(_listSize, (index) {
      state.data.items.asMap().forEach((key, value) {
        if (value.length <= index) {
          // We don't have item at this position (in this list)
          return;
        }

        final item = value[index];

        // Use item painter from ItemOptions to draw the item on the chart
        final _item = state.itemOptions.geometryPainter(item, state);

        final _shouldStack = (key == 0) ? _stack : 0.0;
        // Go to next value only if we are not in the stack, or if this is the first item in the stack
        canvas.translate(
            ((state.itemOptions.multiValuePadding?.left ?? 0.0) * _shouldStack) + _stackWidth * (key != 0 ? _stack : 1),
            0.0);

        // Draw the item on selected position
        _item.draw(
          canvas,
          Size(_stackWidth, -_size.height),
          state.itemOptions.getPaintForItem(_item.item, Size(_stackWidth, -_size.height), key),
        );

        final _shouldStackLast = (key == state.data.stackSize - 1) ? _stack : 0.0;
        canvas.translate((state.itemOptions.multiValuePadding?.right ?? 0.0) * _shouldStackLast, 0.0);
      });
    });

    // Restore canvas
    canvas.restore();

    // End with drawing all foreground decorations
    state.foregroundDecorations.forEach(_drawDecoration);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return false;
  }
}
