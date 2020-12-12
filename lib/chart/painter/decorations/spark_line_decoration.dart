part of flutter_charts;

/// Sparkline (Line graph) is considered to be just a decoration.
/// You need to use [BarPainter] or [BubblePainter] in combination.
/// They can be transparent or be used to show values of the graph
class SparkLineDecoration extends DecorationPainter {
  SparkLineDecoration({
    this.fill = false,
    this.smoothPoints = false,
    this.lineWidth = 1.0,
    this.lineColor = Colors.blue,
    this.startPosition = 0.5,
  });

  final bool fill;
  final bool smoothPoints;
  final double lineWidth;
  final Color lineColor;

  final double startPosition;

  List<ChartItem> _items;

  @override
  void initDecoration(ChartState state) {
    _items = state.items;
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = lineColor
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final _size = state?.defaultPadding?.deflateSize(size) ?? size;
    final _maxValue = state.maxValue - state.minValue;
    final scale = _size.height / _maxValue;
    final _padding = state?.itemOptions?.padding ?? EdgeInsets.zero;
    final _itemWidth = _size.width / state.items.length;

    canvas.save();
    canvas.translate(_padding.left + state.defaultMargin.left, _size.height + state.defaultMargin.top);
    final List<Offset> _positions = <Offset>[];

    for (int _index = 0; _index < state.items.length; _index++) {
      final _item = _items[_index];

      if (fill && _index == 0) {
        _positions.add(Offset(_size.width * (_index / _items.length) + _itemWidth * startPosition, 0.0));
      }
      _positions.add(Offset(_size.width * (_index / _items.length) + _itemWidth * startPosition, -_item.max * scale));
      if (fill && _index == _items.length - 1) {
        _positions.add(Offset(_size.width * (_index / _items.length) + _itemWidth * startPosition, 0.0));
      }
    }

    final Path _path = Path();

    if (fill) {
      _positions.forEach((element) {
        _path.lineTo(element.dx, element.dy);
      });
    } else {
      _positions.forEach((element) {
        if (_positions.first == element) {
          _path.moveTo(element.dx, element.dy);
        } else {
          _path.lineTo(element.dx, element.dy);
        }
      });
    }

    canvas.drawPath(_path, _paint);

    canvas.restore();
  }

  /// Smooth out points and return path in turn
  /// Smoothing is done with quadratic bezier
  Path _smoothPoints(List<Offset> points) {
    final Path _path = Path();
    Offset _mid = (points[0] + points[1]) / 2;

    _path.moveTo(_mid.dx, _mid.dy);
    for (int i = 0; i < points.length - 2; i++) {
      final Offset _p1 = points[(i + 1) % points.length];
      final Offset _p2 = points[(i + 2) % points.length];
      _mid = (_p1 + _p2) / 2;
      _path.quadraticBezierTo(_p1.dx, _p1.dy, _mid.dx, _mid.dy);
    }

    return _path;
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SparkLineDecoration) {
      return SparkLineDecoration(
        fill: t > 0.5 ? endValue.fill : fill,
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        startPosition: lerpDouble(startPosition, endValue.startPosition, t),
        lineColor: Color.lerp(lineColor, endValue.lineColor, t),
      ).._items = ChartItemsLerp().lerpValues(_items, endValue._items, t);
    }

    return this;
  }
}
