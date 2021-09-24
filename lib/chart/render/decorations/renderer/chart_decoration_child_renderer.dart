part of charts_painter;

class ChartDecorationChildRenderer<T> extends SingleChildRenderObjectWidget {
  ChartDecorationChildRenderer(this.chartState, this.decorationPainter, Widget child, {Key? key})
      : super(key: key, child: child);

  final ChartState<T?> chartState;
  final DecorationPainter decorationPainter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartDecorationChildren<T>(chartState, decorationPainter);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderChartDecorationChildren renderObject) {
    renderObject
      ..chartState = chartState
      ..item = decorationPainter;

    renderObject.markNeedsLayout();
  }
}

class _RenderChartDecorationChildren<T> extends RenderShiftedBox {
  _RenderChartDecorationChildren(this._chartState, this._decoration) : super(null);

  DecorationPainter _decoration;
  set item(DecorationPainter decoration) {
    if (decoration != _decoration) {
      _decoration = decoration;
      markNeedsPaint();
    }
  }

  DecorationPainter get item => _decoration;

  ChartState<T?> _chartState;
  set chartState(ChartState<T?> chartState) {
    if (chartState != _chartState) {
      _chartState = chartState;
      markNeedsPaint();
    }
  }

  ChartState<T?> get chartState => _chartState;

  double get _defaultSize => 0;

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
    final _size = constraints.biggest;
    final childParentData = child?.parentData as BoxParentData;
    final offset = _decoration.applyPaintTransform(_chartState, _size);
    childParentData.offset = offset;

    return _decoration.layoutSize(constraints, _chartState);
  }

  @override
  void performLayout() {
    child?.layout(
        BoxConstraints(
          minHeight: 0.0,
          maxHeight: constraints.minHeight,
          minWidth: 0.0,
          maxWidth: constraints.minWidth,
        ),
        parentUsesSize: true);

    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _decoration.draw(canvas, size, _chartState);

    canvas.restore();

    /// --------------------------------------------

    child?.paint(context, offset);
  }
}
