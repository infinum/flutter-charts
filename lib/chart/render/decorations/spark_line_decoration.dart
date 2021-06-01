part of charts_painter;

/// Sparkline (Line graph) is considered to be just a decoration.
/// You need to use [BarGeometryPainter] or [BubbleGeometryPainter] in combination.
/// They can be transparent or be used to show values of the graph
class SparkLineDecoration extends DecorationPainter {
  /// Constructor for sparkline decoration
  SparkLineDecoration({
    this.id,
    this.fill = false,
    bool smoothPoints = false,
    this.lineWidth = 1.0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.lineArrayIndex = 0,
  }) : _smoothPoints = smoothPoints ? 1.0 : 0.0;

  SparkLineDecoration._lerp({
    this.id,
    this.fill = false,
    double smoothPoints = 0.0,
    this.lineWidth = 1.0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.lineArrayIndex = 0,
  }) : _smoothPoints = smoothPoints;

  /// Is line or fill, line will have [lineWidth], setting
  /// [fill] to true will ignore [lineWidth]
  final bool fill;

  /// Is sparkline curve smooth (bezier) or lines
  bool get smoothPoints => _smoothPoints > 0.5;

  /// If od sparkline, with different ID's you can have more [SparkLineDecoration]
  /// on same data with different settings. (ex. One to fill and another for just line)
  final String? id;
  final double _smoothPoints;

  /// Set sparkline width
  final double lineWidth;

  /// Set sparkline color
  final Color lineColor;

  /// Set sparkline start position.
  /// This value ranges from 0.0 - 1.0.
  ///
  /// 0.0 means that start position is right most point of the item,
  /// 1.0 means left most point.
  ///
  /// By default this is set to 0.5, so points are located in center of each [ChartItem]
  final double startPosition;

  /// Gradient color to take.
  ///
  /// Gradient is added as shader, [lineColor] can be used to change how shader is shown
  final Gradient? gradient;

  /// Index of list in items, this is used if there are multiple lists in the chart
  ///
  /// By default this will show first list and value will be 0
  final int lineArrayIndex;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = lineColor
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final _size = state.defaultPadding.deflateSize(size);
    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = _size.height / _maxValue;

    final _positions = <Offset>[];

    final _listSize = state.data.listSize;

    final _itemWidth = _size.width / _listSize;

    if (gradient != null) {
      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(Rect.fromPoints(Offset.zero, Offset(_size.width, -_size.height)));
    }

    state.data.items[lineArrayIndex].asMap().forEach((key, value) {
      if (fill && key == 0) {
        _positions.add(Offset(_size.width * (key / _listSize) + _itemWidth * startPosition, 0.0));
      }

      _positions.add(Offset(_size.width * (key / _listSize) + _itemWidth * startPosition,
          -((value.max ?? 0.0) - state.data.minValue) * scale));

      if (fill && state.data.items[lineArrayIndex].length - 1 == key) {
        _positions.add(Offset(_size.width * (key / _listSize) + _itemWidth * startPosition, 0.0));
      }
    });

    final _path = _getPoints(_positions, fill);

    canvas.save();
    canvas.translate(state.defaultPadding.left + state.defaultMargin.left, _size.height + state.defaultMargin.top);

    canvas.drawPath(_path, _paint);

    canvas.restore();
  }

  /// Smooth out points and return path in turn
  /// Smoothing is done with quadratic bezier
  Path _getPoints(List<Offset> points, bool fill) {
    final _points = fill ? points.getRange(1, points.length - 1).toList() : points;

    final _path = Path();
    if (fill) {
      _path.moveTo(_points[0].dx, 0.0);
      _path.lineTo(_points[0].dx, _points[0].dy);
      _path.lineTo(_points.first.dx, _points.first.dy);
    } else {
      _path.moveTo(_points[0].dx, _points[0].dy);
      _path.lineTo(_points.first.dx, _points.first.dy);
    }

    for (var i = 0; i < _points.length - 1; i++) {
      final _p1 = _points[i % _points.length];
      final _p2 = _points[(i + 1) % _points.length];
      final controlPointX = _p1.dx + ((_p2.dx - _p1.dx) / 2) * _smoothPoints;
      final _mid = (_p1 + _p2) / 2;
      final _firstLerpValue = lerpDouble(_mid.dx, controlPointX, _smoothPoints) ?? 0.0;
      final _secondLerpValue = lerpDouble(_mid.dy, _p2.dy, _smoothPoints) ?? 0.0;

      _path.cubicTo(controlPointX, _p1.dy, _firstLerpValue, _secondLerpValue, _p2.dx, _p2.dy);

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
    if (endValue is SparkLineDecoration) {
      return SparkLineDecoration._lerp(
        fill: t > 0.5 ? endValue.fill : fill,
        id: endValue.id,
        smoothPoints: lerpDouble(_smoothPoints, endValue._smoothPoints, t)!,
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t)!,
        startPosition: lerpDouble(startPosition, endValue.startPosition, t)!,
        lineColor: Color.lerp(lineColor, endValue.lineColor, t)!,
        gradient: Gradient.lerp(gradient, endValue.gradient, t),
        lineArrayIndex: endValue.lineArrayIndex,
      );
    }

    return this;
  }

  @override
  bool isSameType(DecorationPainter other) {
    if (other is SparkLineDecoration) {
      if (id != null && other.id != null) {
        return id == other.id && lineArrayIndex == other.lineArrayIndex;
      }

      return lineArrayIndex == other.lineArrayIndex;
    }

    return false;
  }
}
