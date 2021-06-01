part of charts_painter;

class ChartDataRenderer<T> extends MultiChildRenderObjectWidget {
  ChartDataRenderer(this.chartState, {Key? key})
      : super(key: key, children: [
          ...chartState.data.items
              .mapIndexed(
                (key, items) => items.map((e) => ChartItemRenderer(e, chartState, arrayKey: key)).toList(),
              )
              .expand((element) => element)
              .toList(),
        ]);

  final ChartState<T?> chartState;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ChartItemRenderer<T?>(chartState);
  }
}

class ChartItemData extends ContainerBoxParentData<RenderBox> {}

class _ChartItemRenderer<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ChartItemData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChartItemData> {
  _ChartItemRenderer(this._chartState);

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
  Size computeDryLayout(BoxConstraints constraints) {
    // TODO: implement computeDryLayout
    return super.computeDryLayout(constraints);
  }

  @override
  void performLayout() {
    var childCount = 0;
    var child = firstChild;
    while (child != null) {
      childCount++;

      final childParentData = child.parentData! as ChartItemData;
      childParentData.offset =
          Offset((constraints.maxWidth / _chartState.data.listSize) * (childCount - 1), childParentData.offset.dy);
      final innerConstraints = BoxConstraints(
        maxWidth: constraints.maxWidth,
        minHeight: constraints.maxHeight,
        maxHeight: constraints.maxHeight,
      );

      child.layout(innerConstraints);
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    size = constraints.biggest;
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
