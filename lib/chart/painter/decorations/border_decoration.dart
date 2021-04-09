part of charts_painter;

/// Paints border around the whole chart
class BorderDecoration extends DecorationPainter {
  /// Makes border decoration around the chart
  BorderDecoration({
    double? borderWidth,
    Border? sidesWidth,
    this.borderPadding = EdgeInsets.zero,
    this.color = Colors.black,
    bool endWithChart = false,
  })  : assert(borderWidth == null || sidesWidth == null, 'Can\'t use `borderWidth` and `width`!'),
        assert(endWithChart || borderPadding == EdgeInsets.zero),
        _endWithChart = endWithChart ? 1.0 : 0.0,
        _borderWidth = sidesWidth ?? Border.all(width: borderWidth ?? 2.0);

  BorderDecoration._lerp({
    Border? borderWidth,
    this.borderPadding = EdgeInsets.zero,
    this.color = Colors.black,
    double? endWithChart,
  })  : _endWithChart = endWithChart,
        _borderWidth = borderWidth;

  /// Set additional padding to border
  final EdgeInsets? borderPadding;

  /// Color for border, individual side colors can be set with [_borderWidth] otherwise this color
  /// is used as fallback
  final Color color;

  final Border? _borderWidth;
  final double? _endWithChart;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color;

    canvas.save();

    canvas.translate((state.defaultPadding.left + state.defaultMargin.left) * _endWithChart!,
        (state.defaultPadding.top + state.defaultMargin.top) * _endWithChart!);
    size = (state.defaultPadding * _endWithChart!).deflateSize(size);

    final _height =
        size.height + (state.defaultMargin.vertical * (1 - _endWithChart!)) + _borderWidth!.dimensions.vertical / 2;
    final _width =
        size.width + (state.defaultMargin.horizontal * (1 - _endWithChart!)) - _borderWidth!.dimensions.horizontal;

    _paint.strokeWidth = _borderWidth!.top.width;
    _paint.color = _borderWidth?.top.color ?? color;
    _drawLine(
        canvas,
        Offset(-borderPadding!.left, -_borderWidth!.top.width / 2 - borderPadding!.top),
        Offset(_width + _borderWidth!.dimensions.horizontal + borderPadding!.horizontal,
            -_borderWidth!.top.width / 2 - borderPadding!.top),
        _paint);

    _paint.strokeWidth = _borderWidth!.right.width;
    _paint.color = _borderWidth?.right.color ?? color;
    _drawLine(
        canvas,
        Offset(_width + (_borderWidth!.right.width / 2) + _borderWidth!.dimensions.horizontal + borderPadding!.right,
            -_borderWidth!.top.width - borderPadding!.top),
        Offset(_width + (_borderWidth!.right.width / 2) + _borderWidth!.dimensions.horizontal + borderPadding!.right,
            _height),
        _paint);

    _paint.strokeWidth = _borderWidth!.bottom.width;
    _paint.color = _borderWidth?.bottom.color ?? color;

    _drawLine(canvas, Offset(_width + _borderWidth!.dimensions.horizontal, _height - (_borderWidth!.bottom.width / 2)),
        Offset(-borderPadding!.left, _height - (_borderWidth!.bottom.width / 2)), _paint);

    _paint.strokeWidth = _borderWidth!.left.width;
    _paint.color = _borderWidth?.left.color ?? color;
    _drawLine(
        canvas,
        Offset(-_borderWidth!.left.width / 2 - borderPadding!.left, _height),
        Offset(-_borderWidth!.left.width / 2 - borderPadding!.left, -_borderWidth!.top.width - borderPadding!.top),
        _paint);

    canvas.restore();
  }

  void _drawLine(Canvas canvas, Offset p1, Offset p2, Paint p) {
    if (p.strokeWidth == 0.0) {
      return;
    }

    canvas.drawLine(p1, p2, p);
  }

  @override
  EdgeInsets? marginNeeded() {
    return borderPadding;
  }

  @override
  EdgeInsets paddingNeeded() {
    return _borderWidth!.dimensions.resolve(TextDirection.ltr);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is BorderDecoration) {
      return BorderDecoration._lerp(
        borderWidth: Border.lerp(_borderWidth, endValue._borderWidth, t),
        color: Color.lerp(color, endValue.color, t)!,
        borderPadding: EdgeInsets.lerp(borderPadding, endValue.borderPadding, t),
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t),
      );
    }

    return this;
  }
}
