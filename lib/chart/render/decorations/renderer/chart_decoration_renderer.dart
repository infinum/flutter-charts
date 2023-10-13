part of charts_painter;

class ChartDecorationRenderer<T> extends LeafRenderObjectWidget {
  ChartDecorationRenderer(this.chartState, this.decorationPainter, {Key? key}) : super(key: key);

  final ChartState<T?> chartState;
  final DecorationPainter decorationPainter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartDecoration<T>(chartState, decorationPainter);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderChartDecoration renderObject) {
    renderObject
      ..chartState = chartState
      ..item = decorationPainter;

    renderObject.markNeedsLayout();
  }
}

class _RenderChartDecoration<T> extends RenderBox {
  _RenderChartDecoration(this._chartState, this._decoration);

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
    final childParentData = parentData! as BoxParentData;
    final offset = _decoration.applyPaintTransform(_chartState, _size);
    childParentData.offset = offset;

    return _decoration.layoutSize(constraints, _chartState);
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();

    // Clip out of bounds decorations
    canvas.translate(offset.dx, offset.dy);

    _decoration.draw(canvas, size, _chartState);

    canvas.restore();
  }
}
