part of charts_painter;

class ChartItemRenderer<T> extends LeafRenderObjectWidget {
  ChartItemRenderer(this.item, this.state);

  final ChartItem<T> item;
  final ChartState<T> state;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartItem(state, item);
  }
}

class _RenderChartItem<T> extends RenderBox {
  _RenderChartItem(this._itemOptions, this._item);

  ChartItem<T> _item;
  set item(ChartItem<T> item) {
    if (item != _item) {
      _item = item;
      markNeedsPaint();
    }
  }

  ChartItem<T> get item => _item;

  ChartState _itemOptions;
  set itemOptions(ChartState itemOptions) {
    if (itemOptions != _itemOptions) {
      _itemOptions = itemOptions;
      markNeedsPaint();
    }
  }

  ChartState get itemOptions => _itemOptions;

  double get _defaultSize => _itemOptions.itemOptions.minBarWidth ?? 0;

  @override
  double computeMinIntrinsicWidth(double height) => _defaultSize;

  @override
  double computeMaxIntrinsicWidth(double height) => _defaultSize;

  @override
  double computeMinIntrinsicHeight(double width) => _defaultSize;

  @override
  double computeMaxIntrinsicHeight(double width) => _defaultSize;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    double size = min(constraints.maxWidth, constraints.maxHeight);
    if (size.isInfinite) {
      size = _defaultSize;
    }
    return constraints.constrain(Size.square(size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final _scrollableItemWidth =
        max(_itemOptions.itemOptions.minBarWidth ?? 0.0, _itemOptions.itemOptions.maxBarWidth ?? 0.0);

    final _listSize = _itemOptions.data.listSize;

    Size _size = Size(
        size.width +
            (size.width - ((_scrollableItemWidth + _itemOptions.itemOptions.padding.horizontal) * _listSize)) *
                _itemOptions.behaviour._isScrollable,
        size.height);

    /// Default chart padding (this is to make place for legend and any other decorations that are inserted)
    final _paddingSize = _itemOptions.defaultMargin.deflateSize(_size);

    /// Final usable size for chart
    final _deflatedSize = _itemOptions.defaultPadding.deflateSize(_paddingSize);

    /// Final usable space for one item in the chart
    final _itemWidth = _deflatedSize.width / _listSize;

    final _stack = 1 - _itemOptions.behaviour._multiValueStacked;
    final _width = _itemWidth / max(1, _itemOptions.data.stackSize * _stack);

    final _stackWidth = _width -
        (_itemOptions.itemOptions.multiValuePadding.horizontal / max(1, _itemOptions.data.stackSize * _stack)) * _stack;

    List.generate(_listSize, (index) {
      _itemOptions.data.items.asMap().forEach((key, value) {
        if (value.length <= index) {
          // We don't have item at this position (in this list)
          return;
        }

        final item = value[index];

        // Use item painter from ItemOptions to draw the item on the chart
        final _item = _itemOptions.itemOptions.geometryPainter(item, _itemOptions);

        final _shouldStack = (key == 0) ? _stack : 0.0;
        // Go to next value only if we are not in the stack, or if this is the first item in the stack
        canvas.translate(
            (_itemOptions.itemOptions.multiValuePadding.left * _shouldStack) + _stackWidth * (key != 0 ? _stack : 1),
            0.0);

        // Draw the item on selected position
        _item.draw(
          canvas,
          Size(_stackWidth, _deflatedSize.height),
          _itemOptions.itemOptions.getPaintForItem(_item.item, Size(_stackWidth, _deflatedSize.height), key),
        );

        final _shouldStackLast = (key == _itemOptions.data.stackSize - 1) ? _stack : 0.0;
        canvas.translate(_itemOptions.itemOptions.multiValuePadding.right * _shouldStackLast, 0.0);
      });
    });
  }
}
