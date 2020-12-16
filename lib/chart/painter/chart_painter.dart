part of flutter_charts;

class ChartPainter extends CustomPainter {
  ChartPainter(this.state)
      : _items = state.items.asMap(),
        assert(state.itemOptions.itemPainter != null, 'You need to provide item painter!');

  final ChartState state;
  final Map<int, ChartItem> _items;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // canvas.drawRect(
    //   Rect.fromPoints(
    //     Offset.zero,
    //     Offset(size.width, size.height)
    //   ),
    //   Paint()..color = Colors.red.withOpacity(0.3)
    // );

    if (state.behaviour.isScrollable) {
      final _shouldScroll =
          (state.itemOptions.minBarWidth + state.itemOptions.padding.horizontal) * state.items.length > size.width;

      if (_shouldScroll) {
        size = Size(
            (state.itemOptions.minBarWidth + state.itemOptions.padding.horizontal) * state.items.length, size.height);
      }

      if (state.behaviour.scrollController.hasClients) {
        canvas.translate(state.behaviour.scrollController.offset, 0.0);
      }
    }

    /// Default chart padding (this is to make place for legend and any other decorations that are inserted)
    final _paddingSize = state.defaultMargin.deflateSize(size);

    /// Final usable size for chart
    final _size = state?.defaultPadding?.deflateSize(_paddingSize) ?? _paddingSize;

    /// Final usable space for one item in the chart
    final _itemWidth = _size.width / state.items.length;

    // First draw background decorations
    state.backgroundDecorations.forEach((decoration) => decoration.draw(canvas, _paddingSize, state));

    // Draw all chart items
    _items.forEach((index, element) {
      // Use item painter from ItemOptions to draw the item on the chart
      final _item = state.itemOptions.itemPainter(element, state);

      // Save, and translate the canvas so [0,0] is top left of item at [index] position
      canvas.save();
      canvas.translate(
        (state?.defaultPadding?.left ?? 0.0) + (_itemWidth * index) + state.defaultMargin.left,
        _size.height + state.defaultMargin.top + state.defaultPadding.top,
      );

      // Draw the item on selected position
      _item.draw(canvas, Size(_itemWidth, -_size.height), Paint()..color = state.itemOptions.getItemColor(_item.item));

      // Restore canvas
      canvas.restore();
    });

    // End with drawing all foreground decorations
    state.foregroundDecorations.forEach((decoration) => decoration.draw(canvas, _paddingSize, state));

    canvas.restore();
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
