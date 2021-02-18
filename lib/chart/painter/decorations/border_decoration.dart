part of flutter_charts;

/// Paints border around the whole chart
class BorderDecoration extends DecorationPainter {
  BorderDecoration({
    double borderWidth,
    EdgeInsets sidesWidth,
    this.borderPadding = EdgeInsets.zero,
    this.color = Colors.black,
    bool endWithChart = false,
  })  : assert(borderWidth == null || sidesWidth == null, 'Can\'t use `borderWidth` and `width`!'),
        assert(endWithChart || borderPadding == EdgeInsets.zero),
        _endWithChart = endWithChart ? 1.0 : 0.0,
        _borderWidth = sidesWidth ?? EdgeInsets.all(borderWidth ?? 2.0);

  BorderDecoration._lerp({
    EdgeInsets borderWidth,
    this.borderPadding = EdgeInsets.zero,
    this.color = Colors.black,
    double endWithChart,
  })  : _endWithChart = endWithChart,
        _borderWidth = borderWidth;

  final EdgeInsets borderPadding;
  final Color color;

  final EdgeInsets _borderWidth;
  final double _endWithChart;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color;

    canvas.save();

    canvas.translate((state.defaultPadding.left + state.defaultMargin.left) * _endWithChart,
        state.defaultPadding.top + (state.defaultMargin.top) * _endWithChart);
    size = (state.defaultPadding * _endWithChart).deflateSize(size);

    final _height = size.height + (state.defaultMargin.vertical * (1 - _endWithChart)) + _borderWidth.vertical / 2;
    final _width = size.width + (state.defaultMargin.horizontal * (1 - _endWithChart)) - _borderWidth.horizontal;

    _paint.strokeWidth = _borderWidth.top;
    drawLine(
        canvas,
        Offset(-borderPadding.left, -_borderWidth.top / 2 - borderPadding.top),
        Offset(_width + _borderWidth.horizontal + borderPadding.horizontal, -_borderWidth.top / 2 - borderPadding.top),
        _paint);

    _paint.strokeWidth = _borderWidth.right;
    drawLine(
        canvas,
        Offset(_width + (_borderWidth.right / 2) + _borderWidth.horizontal + borderPadding.right,
            -_borderWidth.top - borderPadding.top),
        Offset(_width + (_borderWidth.right / 2) + _borderWidth.horizontal + borderPadding.right, _height),
        _paint);

    _paint.strokeWidth = _borderWidth.bottom;
    drawLine(canvas, Offset(_width + _borderWidth.horizontal, _height - (_borderWidth.bottom / 2)),
        Offset(-borderPadding.left, _height - (_borderWidth.bottom / 2)), _paint);

    _paint.strokeWidth = _borderWidth.left;
    drawLine(canvas, Offset(-_borderWidth.left / 2 - borderPadding.left, _height),
        Offset(-_borderWidth.left / 2 - borderPadding.left, -_borderWidth.top - borderPadding.top), _paint);

    canvas.restore();
  }

  void drawLine(Canvas canvas, Offset p1, Offset p2, Paint p) {
    if (p.strokeWidth == 0.0) {
      return;
    }

    // canvas.drawLine(p1, p2, p);
    canvas.drawRect(Rect.fromPoints(p1, p2), p);
  }

  @override
  EdgeInsets marginNeeded() {
    return borderPadding;
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is BorderDecoration) {
      return BorderDecoration._lerp(
        borderWidth: EdgeInsets.lerp(_borderWidth, endValue._borderWidth, t),
        color: Color.lerp(color, endValue.color, t),
        borderPadding: EdgeInsets.lerp(borderPadding, endValue.borderPadding, t),
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t),
      );
    }

    return this;
  }
}
