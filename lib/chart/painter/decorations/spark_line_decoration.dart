part of flutter_charts;

/// Sparkline (Line graph) is considered to be just a decoration.
/// You need to use [BarPainter] or [BubblePainter] in combination.
/// They can be transparent or be used to show values of the graph
class SparkLineDecoration<T> extends DecorationPainter {
  SparkLineDecoration({
    this.items,
    this.id,
    this.fill = false,
    bool smoothPoints = false,
    this.lineWidth = 1.0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
  }) : _smoothPoints = smoothPoints ? 1.0 : 0.0;

  SparkLineDecoration._lerp({
    this.items,
    this.id,
    this.fill = false,
    double smoothPoints = 0.0,
    this.lineWidth = 1.0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
  }) : _smoothPoints = smoothPoints;

  final bool fill;

  bool get smoothPoints => _smoothPoints > 0.5;

  final String id;
  final double _smoothPoints;

  final double lineWidth;
  final Color lineColor;

  final double startPosition;
  final Gradient gradient;

  List<ChartItem<T>> items;

  @override
  void initDecoration(ChartState state) {
    if(state is ChartState<T>) {
      items ??= state.items.values.toList();
    }
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

    final List<Offset> _positions = <Offset>[];

    final _itemWidth = _size.width / items.length;

    if (gradient != null) {
      _paint.shader = gradient.createShader(Rect.fromPoints(
          Offset(state.defaultPadding.left, state.defaultPadding.bottom), Offset(_size.width, _size.height)));
    }

    for (int _index = 0; _index < items.length; _index++) {
      final _item = items[_index];

      if (fill && _index == 0) {
        _positions.add(Offset(_size.width * (_index / items.length) + _itemWidth * startPosition, 0.0));
      }
      _positions.add(Offset(_size.width * (_index / items.length) + _itemWidth * startPosition, -_item.max * scale));
      if (fill && _index == items.length - 1) {
        _positions.add(Offset(_size.width * (_index / items.length) + _itemWidth * startPosition, 0.0));
      }
    }

    final Path _path = _getPoints(_positions, fill);

    canvas.save();
    canvas.translate(state.defaultMargin.left, _size.height + state.defaultMargin.top);

    canvas.drawPath(_path, _paint);

    canvas.restore();
  }

  /// Smooth out points and return path in turn
  /// Smoothing is done with quadratic bezier
  Path _getPoints(List<Offset> points, bool fill) {
    final List<Offset> _points = fill ? points.getRange(1, points.length - 1).toList() : points;

    final Path _path = Path();
    if (fill) {
      _path.moveTo(_points[0].dx, 0.0);
      _path.lineTo(_points[0].dx, _points[0].dy);
      _path.lineTo(_points.first.dx, _points.first.dy);
    } else {
      _path.moveTo(_points[0].dx, _points[0].dy);
      _path.lineTo(_points.first.dx, _points.first.dy);
    }

    for (int i = 0; i < _points.length - 1; i++) {
      final Offset _p1 = _points[i % _points.length];
      final Offset _p2 = _points[(i + 1) % _points.length];
      final double controlPointX = _p1.dx + ((_p2.dx - _p1.dx) / 2) * _smoothPoints;
      // _path.quadraticBezierTo(_p1.dx, _p1.dy, _mid.dx, _mid.dy);
      final Offset _mid = (_p1 + _p2) / 2;
      _path.cubicTo(controlPointX, _p1.dy, lerpDouble(_mid.dx, controlPointX, _smoothPoints),
          lerpDouble(_mid.dy, _p2.dy, _smoothPoints), _p2.dx, _p2.dy);

      if (i == _points.length - 2) {
        _path.lineTo(_p2.dx, _p2.dy);
        if (fill) {
          _path.lineTo(_p2.dx, 0.0);
        }
      }
    }

    return _path;
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SparkLineDecoration<T>) {
      return SparkLineDecoration._lerp(
        fill: t > 0.5 ? endValue.fill : fill,
        id: endValue.id,
        smoothPoints: lerpDouble(_smoothPoints, endValue._smoothPoints, t),
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        startPosition: lerpDouble(startPosition, endValue.startPosition, t),
        lineColor: Color.lerp(lineColor, endValue.lineColor, t),
        items: ChartItemsLerp().lerpValues<T>(items.asMap(), endValue.items.asMap(), t).values.toList(),
        gradient: Gradient.lerp(gradient, endValue.gradient, t),
      );
    }

    return this;
  }

  @override
  bool isEqual(DecorationPainter other) {
    if (other is SparkLineDecoration) {
      if (id != null && other.id != null) {
        return id == other.id;
      }
    }

    return runtimeType == other.runtimeType;
  }
}
