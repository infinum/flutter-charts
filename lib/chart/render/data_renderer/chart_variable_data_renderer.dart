part of charts_painter;

/// Align chart data items in linear fashion. Meaning X axis cannot be changed. X axis becomes the index of current item
/// height of the item is defined by item max or min value.
class ChartVariableDataRenderer<T> extends ChartDataRenderer<T> {
  ChartVariableDataRenderer(this.chartData, List<Widget> children, {Key? key})
      : super(key: key, children: children);

  final ChartData<T?> chartData;

  @override
  _ChartVariableItemRenderer<T?> createRenderObject(BuildContext context) {
    return _ChartVariableItemRenderer<T?>(chartData);
  }

  @override
  void updateRenderObject(
      BuildContext context, _ChartVariableItemRenderer<T?> renderObject) {
    renderObject.chartData = chartData;
    renderObject.markNeedsLayout();
  }
}

class _ChartVariableItemRenderer<T> extends ChartItemRenderer<T>
    with
        ContainerRenderObjectMixin<RenderBox, ChartItemData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChartItemData> {
  _ChartVariableItemRenderer(ChartData<T?> chartData) : super(chartData);

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ChartItemData) {
      child.parentData = ChartItemData();
    }
  }

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    var childCount = <int, int>{};
    var child = firstChild;
    final _size = computeDryLayout(constraints);
    final _listSize = _chartData.listSize;
    final _itemSize = Size(_size.width, _size.height);

    /// Final usable space for one item in the chart
    final _itemWidth = _itemSize.width / _listSize;
    final _offset = (parentData as BoxPaneParentData).offset;

    while (child != null && child is _RenderLeafChartItem<T>) {
      final childParentData = child.parentData! as ChartItemData;
      final _xOffset = child.item.xAxisMin ?? 0.0;

      childParentData.offset = _offset + Offset(_itemWidth * _xOffset, 0.0);
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
