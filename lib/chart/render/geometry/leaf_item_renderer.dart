part of charts_painter;

class LeafChartItemRenderer<T> extends LeafRenderObjectWidget {
  LeafChartItemRenderer(this.item, this.state, {this.arrayKey = 0});

  final ChartItem<T?> item;
  final ChartState<T?> state;
  final int arrayKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLeafChartItem(state, item, key: arrayKey);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLeafChartItem<T?> renderObject) {
    renderObject
      ..state = state
      ..key = arrayKey
      ..item = item;

    renderObject.markNeedsLayout();
  }
}

class _RenderLeafChartItem<T> extends RenderBox {
  _RenderLeafChartItem(this._state, this._item, {int? key}) : _key = key ?? 0;

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
  set state(ChartState state) {
    if (state != _state) {
      _state = state;
      markNeedsPaint();
    }
  }

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
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final _stack = 1 - _state.itemOptions._multiValueStacked;
    final _stackSize = max(1, _state.data.stackSize * _stack);

    final _multiPadding = _state.itemOptions.multiValuePadding.horizontal * _stackSize * _stack;

    final _stackWidth = (size.width - _multiPadding - _state.itemOptions.padding.horizontal) / _stackSize;

    canvas.translate(
        _state.itemOptions.multiValuePadding.left * _stack +
            _state.itemOptions.padding.left +
            _stackWidth * key * _stack +
            ((_state.itemOptions.multiValuePadding.horizontal * key * _stack)),
        0.0);

    // Use item painter from ItemOptions to draw the item on the chart
    final _item = _state.itemOptions.geometryPainter(item, _state);

    // Draw the item on selected position
    _item.draw(
      canvas,
      Size(_stackWidth, size.height),
      _state.itemOptions.getPaintForItem(_item.item, Size(_stackWidth, size.height), key),
    );

    canvas.restore();
  }
}
