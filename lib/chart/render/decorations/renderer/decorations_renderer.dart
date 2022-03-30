part of charts_painter;

class FixedDecorationsRenderer<T> extends MultiChildRenderObjectWidget {
  FixedDecorationsRenderer(List<DecorationPainter> fixedDecoration, this.chartState,
      {Key? key})
      : super(
            key: key,
            children:
                fixedDecoration.map((e) => e.getRenderer(chartState)).toList());

  final ChartState<T?> chartState;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _FixedDecorationRenderObject<T?>(chartState);
  }

  @override
  void updateRenderObject(
      BuildContext context, _FixedDecorationRenderObject<T?> renderObject) {
    renderObject.chartState = chartState;
    renderObject.markNeedsLayout();
  }
}

class _FixedDecorationRenderObject<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BoxPaneParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BoxPaneParentData> {
  _FixedDecorationRenderObject(this._chartState);

  ChartState<T?> _chartState;
  set chartState(ChartState<T?> state) {
    if (_chartState != state) {
      _chartState = state;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxPaneParentData) {
      child.parentData = BoxPaneParentData();
    }
  }

  @override
  void performLayout() {
    var child = firstChild;

    while (child != null) {
      final childParentData = child.parentData! as BoxPaneParentData;

      child.layout(constraints.loosen());
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as BoxPaneParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }
}
