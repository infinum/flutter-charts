part of charts_painter;

class ChartLinearDataRenderer<T> extends ChartDataRenderer<T> {
  ChartLinearDataRenderer(this.chartState, {Key? key})
      : super(key: key, children: [
          ...chartState.items
              .mapIndexed(
                (key, items) => items.map((e) => LeafChartItemRenderer(e, chartState, arrayKey: key)).toList(),
              )
              .expand((element) => element)
              .toList(),
        ]);

  final ChartState<T?> chartState;

  @override
  _ChartLinearItemRenderer<T?> createRenderObject(BuildContext context) {
    return _ChartLinearItemRenderer<T?>(chartState);
  }

  @override
  void updateRenderObject(BuildContext context, _ChartLinearItemRenderer<T?> renderObject) {
    renderObject.chartState = chartState;
    renderObject.markNeedsLayout();
  }
}

class ChartItemData extends ContainerBoxParentData<RenderBox> {}

class _ChartLinearItemRenderer<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ChartItemData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChartItemData> {
  _ChartLinearItemRenderer(this._chartState);

  ChartState<T?> _chartState;
  ChartState<T?> get chartState => _chartState;
  set chartState(ChartState<T?> state) {
    if (_chartState != state) {
      _chartState = state;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ChartItemData) {
      child.parentData = ChartItemData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    // TODO: implement computeMinIntrinsicWidth
    return super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    // TODO: implement computeMaxIntrinsicWidth
    return super.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    // TODO: implement computeMinIntrinsicHeight
    return super.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    // TODO: implement computeMaxIntrinsicHeight
    return super.computeMaxIntrinsicHeight(width);
  }

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final _size = constraints.deflate(chartState.defaultPadding + chartState.defaultMargin).biggest;
    final childParentData = parentData! as BoxParentData;
    childParentData.offset = Offset(chartState.defaultPadding.left + chartState.defaultMargin.left,
        chartState.defaultPadding.top + chartState.defaultMargin.top);

    return _size;
  }

  @override
  void performLayout() {
    var childCount = <int, int>{};
    var child = firstChild;
    final _size = computeDryLayout(constraints);
    final _listSize = _chartState.data.listSize;
    final _itemSize = Size(_size.width, _size.height);

    /// Final usable space for one item in the chart
    final _itemWidth = _itemSize.width / _listSize;

    while (child != null && child is _RenderLeafChartItem<T>) {
      final childParentData = child.parentData! as ChartItemData;
      childParentData.offset = Offset(_itemWidth * (childCount[child.key] ?? 0), childParentData.offset.dy);
      final innerConstraints = BoxConstraints(
        maxWidth: _itemWidth,
        maxHeight: _size.height,
      );

      final key = child.key;

      child.layout(innerConstraints, parentUsesSize: true);
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
      childCount[key] = (childCount[key] ?? 0).toInt() + 1;
    }

    size = _size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as ChartItemData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }
}
