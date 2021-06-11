part of charts_painter;

class ChartItemRenderer<T> extends LeafRenderObjectWidget {
  ChartItemRenderer(this.item, this.state, {this.arrayKey = 0});

  final ChartItem<T?> item;
  final ChartState<T?> state;
  final int arrayKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartItem(state, item, key: arrayKey);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderChartItem<T?> renderObject) {
    renderObject
      ..state = state
      ..key = arrayKey
      ..item = item;
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

    final _stack = 1 - _state.behaviour._multiValueStacked;

    final _stackWidth = size.width -
        (_state.itemOptions.multiValuePadding.horizontal / max(1, _state.data.stackSize * _stack)) * _stack;

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