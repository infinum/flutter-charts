part of charts_painter;

class ChartRenderer<T> extends MultiChildRenderObjectWidget {
  ChartRenderer(this.chartState, {Key? key})
      : super(key: key, children: [
          DecorationsRenderer(chartState.backgroundDecorations, chartState),
          ChartLinearDataRenderer(chartState),
          DecorationsRenderer(chartState.foregroundDecorations, chartState),
        ]);

  final ChartState<T?> chartState;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ChartRenderObject<T?>(chartState);
  }

  @override
  void updateRenderObject(
      BuildContext context, _ChartRenderObject<T?> renderObject) {
    renderObject.chartState = chartState;
    renderObject.markNeedsLayout();
  }
}

class BoxPaneParentData extends ContainerBoxParentData<RenderBox> {}

class _ChartRenderObject<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BoxPaneParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BoxPaneParentData> {
  _ChartRenderObject(this._chartState);

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
