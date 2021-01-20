part of flutter_charts;

/// Custom painter for charts
class ChartPainter extends CustomPainter {
  ChartPainter(this.state) : assert(state.itemPainter != null, 'You need to provide item painter!');

  final ChartState state;

  final bool _debugBoundary = false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    if (_debugBoundary) {
      canvas.drawRect(
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)), Paint()..color = Colors.red.withOpacity(0.3));
    }

    final _scrollableItemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0, state?.itemOptions?.maxBarWidth ?? 0.0);

    final int _listSize = state.items.values.fold(0, (previousValue, element) => max(previousValue, element.length));

    size = Size(
        size.width +
            (size.width - ((_scrollableItemWidth + state.itemOptions.padding.horizontal) * _listSize)) *
                state.behaviour._isScrollable,
        size.height);

    /// Default chart padding (this is to make place for legend and any other decorations that are inserted)
    final _paddingSize = state.defaultMargin.deflateSize(size);

    /// Final usable size for chart
    final _size = state?.defaultPadding?.deflateSize(_paddingSize) ?? _paddingSize;

    /// Final usable space for one item in the chart
    final _itemWidth = _size.width / _listSize;

    void _drawDecoration(DecorationPainter decoration) => decoration.draw(canvas, _paddingSize, state);

    // First draw background decorations
    state.backgroundDecorations.forEach(_drawDecoration);

    // Draw all chart items
    state.items.forEach((key, element) {
      element.asMap().forEach((index, item) {
        // Use item painter from ItemOptions to draw the item on the chart
        final _item = state.itemPainter(item, state);
        final _stack = 1 - state.behaviour._multiValueStacked;

        final _width = _itemWidth / max(1, state.items.length * _stack);
        final _position = _itemWidth * index + (key * _width * _stack);

        // Save, and translate the canvas so [0,0] is top left of item at [index] position
        canvas.save();
        canvas.translate(
          (state?.defaultPadding?.left ?? 0.0) + _position + state.defaultMargin.left,
          _size.height + state.defaultMargin.top + state.defaultPadding.top,
        );

        // Draw the item on selected position
        _item.draw(
            canvas, Size(_width, -_size.height), Paint()..color = state.itemOptions.getItemColor(_item.item, key));

        // Restore canvas
        canvas.restore();
      });
    });

    // End with drawing all foreground decorations
    state.foregroundDecorations.forEach(_drawDecoration);

    canvas.restore();
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
