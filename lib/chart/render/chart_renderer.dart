part of charts_painter;

/// Chart renderer will break up all chart data into it's own [ChartDataRenderer] that they use,
/// Along with adding all [FixedDecorationsRenderer]ers with their renderers.
///
/// [DecorationPainter] can override their renderer by overriding [FixedDecorationsRenderer.createRenderObject]
///
/// Chart data can change their renderer by specifying new renderer in [ChartState.dataRenderer]
class ChartRenderer<T> extends MultiChildRenderObjectWidget {
  ChartRenderer(this.chartState, {Key? key})
      : super(key: key, children: [
          DecorationsRenderer(chartState.backgroundDecorations, chartState),
          chartState.dataRenderer.call(chartState.data),
          DecorationsRenderer(chartState.foregroundDecorations, chartState),
        ]);

  final ChartState<T?> chartState;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ChartRenderObject<T?>(chartState);
  }

  @override
  void updateRenderObject(BuildContext context, _ChartRenderObject<T?> renderObject) {
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
      if (child is ChartItemRenderer) {
        final _size = constraints.deflate(_chartState.defaultPadding + _chartState.defaultMargin).biggest;
        childParentData.offset = Offset(_chartState.defaultPadding.left + _chartState.defaultMargin.left,
            _chartState.defaultPadding.top + _chartState.defaultMargin.top);

        child.layout(BoxConstraints.tight(_size));
      } else {
        child.layout(constraints.loosen());
      }

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
      context.paintChild(child, offset);
      child = childParentData.nextSibling;
    }
  }
}
