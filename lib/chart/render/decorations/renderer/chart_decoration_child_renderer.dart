part of charts_painter;

class ChartDecorationChildRenderer<T> extends SingleChildRenderObjectWidget {
  ChartDecorationChildRenderer(
      this.chartState, this.decorationPainter, Widget child,
      {Key? key})
      : super(key: key, child: child);

  final ChartState<T?> chartState;
  final DecorationPainter decorationPainter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartDecorationChildren<T>(chartState, decorationPainter);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderChartDecorationChildren renderObject) {
    renderObject
      ..chartState = chartState
      ..item = decorationPainter;

    renderObject.markNeedsLayout();
  }
}

class _RenderChartDecorationChildren<T> extends RenderShiftedBox {
  _RenderChartDecorationChildren(this._chartState, this._decoration,
      [RenderBox? child])
      : super(child);

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

  Size _computeSize(
      {required BoxConstraints constraints,
      required ChildLayouter layoutChild}) {
    if (child != null) {
      final childSize = layoutChild(child!, constraints);
      final double width = max(childSize.width, _defaultSize);
      final double height = max(childSize.height, _defaultSize);
      return constraints.constrain(Size(width, height));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      return _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild,
      );
    }

    return _decoration.layoutSize(constraints, _chartState);
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );

    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;
      final _difference = Offset(
          ((constraints.biggest.width - _chartState.defaultMargin.horizontal) /
                  _chartState.data.listSize) -
              size.width,
          0.0);

      final offset =
          _decoration.applyPaintTransform(_chartState, constraints.biggest) +
              (_difference / 2);
      childParentData.offset =
          Alignment.center.alongOffset(size - child!.size as Offset) + offset;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;
      context.paintChild(child!, childParentData.offset + offset);
    }

    final _canvas = context.canvas;

    final _position =
        _decoration.applyPaintTransform(_chartState, constraints.biggest);
    _canvas.save();
    _canvas.translate(_position.dx, _position.dy);
    _decoration.draw(context.canvas, size, _chartState);
    _canvas.restore();
  }
}
