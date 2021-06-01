part of charts_painter;

class ChartDecorationRenderer<T> extends LeafRenderObjectWidget {
  ChartDecorationRenderer(this.chartState, this.decorationPainter);

  final ChartState<T?> chartState;
  final DecorationPainter decorationPainter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartDecoration<T>(chartState, decorationPainter);
  }
}

class _RenderChartDecoration<T> extends RenderBox {
  _RenderChartDecoration(this._chartState, this._decoration);

  DecorationPainter _decoration;
  set item(DecorationPainter item) {
    if (item != _decoration) {
      _decoration = item;
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
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(Size(constraints.maxWidth, constraints.maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, 0.0);
    _decoration.draw(canvas, size, _chartState);

    canvas.restore();
  }
}
