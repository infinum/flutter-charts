part of charts_painter;

class ChartItemRenderer<T> extends LeafRenderObjectWidget {
  ChartItemRenderer(this.item, this.state, {this.arrayKey = 0});

  final ChartItem<T> item;
  final ChartState<T> state;
  final int arrayKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartItem(state, item, key: arrayKey);
  }
}

class _RenderChartItem<T> extends RenderBox {
  _RenderChartItem(this._state, this._item, {int? key}) : _key = key ?? 0;

  int _key;

  int get key => _key;
  set key(int key) {
    if (key != _key) {
      _key = key;
      markNeedsPaint();
    }
  }

  ChartItem<T> _item;
  set item(ChartItem<T> item) {
    if (item != _item) {
      _item = item;
      markNeedsPaint();
    }
  }

  ChartItem<T> get item => _item;

  ChartState _state;
  set itemOptions(ChartState itemOptions) {
    if (itemOptions != _state) {
      _state = itemOptions;
      markNeedsPaint();
    }
  }

  ChartState get itemOptions => _state;

  double get _defaultSize => _state.itemOptions.minBarWidth ?? 0;

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
    final _scrollableItemWidth = max(_state.itemOptions.minBarWidth ?? 0.0, _state.itemOptions.maxBarWidth ?? 0.0);

    final _listSize = _state.data.listSize;

    final _size = Size(
        constraints.maxWidth +
            (constraints.maxWidth - ((_scrollableItemWidth + _state.itemOptions.padding.horizontal) * _listSize)) *
                _state.behaviour._isScrollable,
        constraints.maxHeight);

    /// Default chart padding (this is to make place for legend and any other decorations that are inserted)
    final _paddingSize = _state.defaultMargin.deflateSize(_size);

    /// Final usable size for chart
    final _deflatedSize = _state.defaultPadding.deflateSize(_paddingSize);

    /// Final usable space for one item in the chart
    final _itemWidth = _deflatedSize.width / _listSize;

    var size = min(_itemWidth, constraints.maxHeight);
    if (size.isInfinite) {
      size = _defaultSize;
    }

    return constraints.constrain(Size(size, _deflatedSize.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final _stack = 1 - _state.behaviour._multiValueStacked;

    final _stackWidth =
        (_state.itemOptions.multiValuePadding.horizontal / max(1, _state.data.stackSize * _stack)) * _stack;

    // Use item painter from ItemOptions to draw the item on the chart
    final _item = _state.itemOptions.geometryPainter(item, _state);

    // Draw the item on selected position
    _item.draw(
      canvas,
      Size(size.width, -size.height),
      _state.itemOptions.getPaintForItem(_item.item, Size(_stackWidth, size.height), key),
    );

    canvas.restore();
  }
}
