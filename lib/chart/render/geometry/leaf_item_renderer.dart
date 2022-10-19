part of charts_painter;

/// Default renderer for all chart items. Renderers use different painters to paint themselves.
///
/// This is a [LeafRenderObjectWidget] meaning it cannot have any children.
/// All customization for this list items can be done with [BarItemOptions] or [BubbleItemOptions]
class LeafChartItemRenderer<T> extends LeafRenderObjectWidget {
  LeafChartItemRenderer(this.item, this.state, this.itemOptions,
      {this.listKey = 0, this.itemKey = 0, required this.chartDataItem});

  final ChartItem<T?> item;
  final ChartData<T?> state;
  final ItemOptions itemOptions;
  final ChartDataItem chartDataItem;
  final int listKey;
  final int itemKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLeafChartItem(
      state,
      itemOptions,
      item,
      listKey: listKey,
      itemKey: itemKey,
      chartDataItem: chartDataItem,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLeafChartItem<T?> renderObject) {
    renderObject
      ..state = state
      ..itemOptions = itemOptions
      ..listKey = listKey
      ..itemKey = itemKey
      ..chartDataItem = chartDataItem
      ..item = item;

    renderObject.markNeedsLayout();
  }
}

class _RenderLeafChartItem<T> extends RenderBox {
  _RenderLeafChartItem(
    this._state,
    this._itemOptions,
    this._item, {
    int? listKey,
    required int itemKey,
    required ChartDataItem chartDataItem,
  })  : _listKey = listKey ?? 0,
        _chartDataItem = chartDataItem,
        _itemKey = itemKey;

  int _listKey;

  int _itemKey;

  int get itemKey => _itemKey;

  set itemKey(int key) {
    if (key != _itemKey) {
      _itemKey = key;
      markNeedsPaint();
    }
  }

  ChartDataItem _chartDataItem;

  ChartDataItem get chartDataItem => _chartDataItem;

  set chartDataItem(ChartDataItem chartDataItem) {
    if (chartDataItem != _chartDataItem) {
      _chartDataItem = chartDataItem;
      markNeedsPaint();
    }
  }

  int get listKey => _listKey;

  set listKey(int key) {
    if (key != _listKey) {
      _listKey = key;
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

  ChartData _state;

  set state(ChartData state) {
    if (state != _state) {
      _state = state;
      markNeedsPaint();
    }
  }

  ItemOptions _itemOptions;

  set itemOptions(ItemOptions itemOptions) {
    if (itemOptions != _itemOptions) {
      _itemOptions = itemOptions;
      markNeedsPaint();
    }
  }

  double get _defaultSize => _itemOptions.minBarWidth ?? 0;

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

    final _stack = 1 - _itemOptions._multiValueStacked;
    final _stackSize = max(1, _state.stackSize * _stack);

    final _multiPadding = _itemOptions.multiValuePadding.horizontal * _stackSize * _stack;

    final _stackWidth = (size.width - _multiPadding - _itemOptions.padding.horizontal) / _stackSize;

    canvas.translate(
        _itemOptions.multiValuePadding.left * _stack +
            _itemOptions.padding.left +
            _stackWidth * listKey * _stack +
            ((_itemOptions.multiValuePadding.horizontal * listKey * _stack)),
        0.0);

    // Use item painter from ItemOptions to draw the item on the chart
    // _itemOptions is BubbleItemOptions && chartDataItem is BarItem
    final _itemPainter = _itemOptions.geometryPainter(
      item,
      _state,
      _itemOptions,
      chartDataItem,
    );

    // Draw the item on selected position
    _itemPainter.draw(canvas, Size(_stackWidth, size.height), Paint()..color = chartDataItem.color ?? Colors.black);

    canvas.restore();
  }
}
