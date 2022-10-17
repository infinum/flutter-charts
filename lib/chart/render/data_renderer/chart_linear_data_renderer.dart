part of charts_painter;

/// Align chart data items in linear fashion. Meaning X axis cannot be changed. X axis becomes the index of current item
/// height of the item is defined by item max or min value.
class ChartLinearDataRenderer<T> extends ChartDataRenderer<T> {
  ChartLinearDataRenderer(this.chartState, List<Widget> children, {Key? key})
      : super(key: key, children: children);

  final ChartState<T?> chartState;

  @override
  _ChartLinearItemRenderer<T?> createRenderObject(BuildContext context) {
    return _ChartLinearItemRenderer<T?>(chartState);
  }

  @override
  void updateRenderObject(
      BuildContext context, _ChartLinearItemRenderer<T?> renderObject) {
    renderObject.chartState = chartState;
    renderObject.markNeedsLayout();
  }
}

class ChartItemData extends ContainerBoxParentData<RenderBox> {}

class _ChartLinearItemRenderer<T> extends ChartItemRenderer<T>
    with
        ContainerRenderObjectMixin<RenderBox, ChartItemData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChartItemData> {
  _ChartLinearItemRenderer(ChartState<T?> chartState) : super(chartState);

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
    final _listSize = _chartState.data.listSize;
    final _itemSize = Size(_size.width, _size.height);

    /// Final usable space for one item in the chart
    final _itemWidth = _itemSize.width / _listSize;
    final _offset = (parentData as BoxPaneParentData).offset;

    // Calculate with of current item, height is calculated in [GeometryPainter] so we can just hand
    // columns with offset and width to the child.
    void _setLeafChildPosition(_RenderLeafChartItem<T> child) {
      final childParentData = child.parentData! as ChartItemData;

      childParentData.offset =
          _offset + Offset(_itemWidth * (childCount[child.key] ?? 0), 0.0);
      final innerConstraints = BoxConstraints(
        maxWidth: _itemWidth,
        maxHeight: _size.height,
      );

      child.layout(innerConstraints, parentUsesSize: true);
    }

    // In case you want to show child for ChartItem then we need to constrain it's height as well
    // this will make sure that widget takes exactly the size we give it.
    void _setWidgetChildPosition(_RenderChildChartItem<T> child) {
      final childParentData = child.parentData! as ChartItemData;

      final _maxValue = chartState.data.maxValue - chartState.data.minValue;
      final _verticalMultiplier = _size.height / max(1, _maxValue);

      childParentData.offset = _offset +
          Offset(_itemWidth * (childCount[child.key] ?? 0),
              _size.height - ((child.item.max ?? 0.0) * _verticalMultiplier));

      // Get all necessary calculations for ChartItem for layout and position of the child.
      // Size is used to constrain the child of ChartItem.
      var bottomPaddingHeight = 0.0;
      final _stack =
          1 - chartState.itemOptionsBuilder(child.key)._multiValueStacked;
      final _stackSize = max(1.0, (chartState.data.stackSize) * _stack);
      final _stackWidth = _itemWidth / _stackSize;

      // Handle stack data strategy.
      if (chartState.data.dataStrategy is StackDataStrategy) {
        final _itemIndex = childCount[child.key] ?? 0;

        if (child.key + 1 < chartState.data.stackSize) {
          bottomPaddingHeight =
              chartState.data.items[child.key + 1][_itemIndex].max ?? 0.0;
        }
      }

      final innerConstraints = BoxConstraints.tightFor(
        width: _stackWidth,
        height: (child.item.max ?? 0.0) * _verticalMultiplier -
            bottomPaddingHeight * _verticalMultiplier,
      );

      child.layout(innerConstraints, parentUsesSize: true);
    }

    while (child != null) {
      final childParentData = child.parentData! as ChartItemData;
      if (child is _RenderLeafChartItem<T>) {
        _setLeafChildPosition(child);

        final key = child.key;

        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
        childCount[key] = (childCount[key] ?? 0).toInt() + 1;
      } else if (child is _RenderChildChartItem<T>) {
        _setWidgetChildPosition(child);

        final key = child.key;

        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
        childCount[key] = (childCount[key] ?? 0).toInt() + 1;
      }
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
