part of charts_painter;

class ChartRenderer<T> extends MultiChildRenderObjectWidget {
  ChartRenderer(this.chartState, {Key? key})
      : super(key: key, children: [
          ...chartState.backgroundDecorations
              .map((e) => ChartDecorationRenderer(chartState, e, key: ValueKey(e.hashCode)))
              .toList(),
          ChartLinearDataRenderer(chartState),
          ...chartState.foregroundDecorations
              .map((e) => ChartDecorationRenderer(chartState, e, key: ValueKey(e.hashCode)))
              .toList(),
        ]);

  final ChartState<T?> chartState;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ChartRenderObject<T?>(chartState);
  }

  @override
  void updateRenderObject(BuildContext context, _ChartRenderObject<T?> renderObject) {
    renderObject.chartState = chartState;
  }
}

class BoxPaneParentData extends ContainerBoxParentData<RenderBox> {}

class _ChartRenderObject<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BoxPaneParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BoxPaneParentData> {
  _ChartRenderObject(this._chartState);

  ChartState<T?> _chartState;
  ChartState<T?> get chartState => _chartState;
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
  Size computeDryLayout(BoxConstraints constraints) {
    // TODO: implement computeDryLayout
    return super.computeDryLayout(constraints);
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
