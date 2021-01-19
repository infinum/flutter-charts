part of flutter_charts;

class BorderDecoration extends DecorationPainter {
  BorderDecoration({
    double width,
    EdgeInsets borderWidth,
    this.color = Colors.black,
  })  : assert(width == null || borderWidth == null, 'Can\'t use `borderWidth` and `width`!'),
        _borderWidth = borderWidth ?? EdgeInsets.all(width ?? 2.0);

  final EdgeInsets _borderWidth;
  final Color color;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color;

    canvas.save();

    canvas.translate(0.0 + state.defaultPadding.left + state.defaultMargin.left, state.defaultMargin.top);
    size = state.defaultPadding.deflateSize(size);

    _paint.strokeWidth = _borderWidth.top;
    canvas.drawLine(Offset.zero, Offset(size.width, 0.0), _paint);

    _paint.strokeWidth = _borderWidth.right;
    canvas.drawLine(Offset(size.width, -(_borderWidth.top / 2)),
        Offset(size.width, size.height + (_borderWidth.bottom / 2)), _paint);

    _paint.strokeWidth = _borderWidth.bottom;
    canvas.drawLine(Offset(size.width, size.height), Offset(0.0, size.height), _paint);

    _paint.strokeWidth = _borderWidth.left;
    canvas.drawLine(Offset(0.0, size.height + (_borderWidth.bottom / 2)), Offset(0.0, -(_borderWidth.top / 2)), _paint);

    canvas.restore();
  }

  @override
  EdgeInsets marginNeeded() {
    return _borderWidth;
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is BorderDecoration) {
      return BorderDecoration(
        borderWidth: EdgeInsets.lerp(_borderWidth, endValue._borderWidth, t),
        color: Color.lerp(color, endValue.color, t),
      );
    }

    return this;
  }
}
