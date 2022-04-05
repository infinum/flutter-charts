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
    this.dashArray,
    bool stretchLine = false,
  })  : _smoothPoints = smoothPoints ? 1.0 : 0.0,
        _stretchLine = stretchLine ? 1.0 : 0.0;

  SparkLineDecoration._lerp({
    this.id,
    this.fill = false,
    double smoothPoints = 0.0,
    this.lineWidth = 1.0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.lineArrayIndex = 0,
    this.dashArray,
    double stretchLine = 0.0,
  })  : _smoothPoints = smoothPoints,
        _stretchLine = stretchLine;

  /// Is line or fill, line will have [lineWidth], setting
  /// [fill] to true will ignore [lineWidth]
  final bool fill;

  /// Is sparkline curve smooth (bezier) or lines
  bool get smoothPoints => _smoothPoints > 0.5;

  /// If od sparkline, with different ID's you can have more [SparkLineDecoration]
  /// on same data with different settings. (ex. One to fill and another for just line)
  final String? id;
  final double _smoothPoints;

  /// Dashed array for showing lines, if this is not set the line is solid
  final List<double>? dashArray;

  /// Set sparkline width
  final double lineWidth;

  /// Set sparkline color
  final Color lineColor;

  final double _stretchLine;

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
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    final _size = (state.defaultPadding + state.defaultMargin)
        .deflateSize(constraints.biggest);
    return _size;
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    return Offset(state.defaultPadding.left + state.defaultMargin.left,
        state.defaultPadding.top + state.defaultMargin.top);
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = lineColor
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = size.height / _maxValue;

    final _positions = <Offset>[];

    final _listSize = state.data.listSize;

    final _itemWidth = size.width / _listSize;

    final _maxValueForKey = state.data.items[lineArrayIndex].fold(0.0,
        (double previousValue, element) {
      if (previousValue < (element.max ?? element.min ?? 0)) {
        return (element.max ?? element.min ?? 0);
      }

      return previousValue;
    });

    if (gradient != null) {
      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(
        Rect.fromLTWH(
          0.0,
          size.height - (_maxValueForKey * scale),
          size.width,
          _maxValueForKey * scale,
        ),
        textDirection: TextDirection.ltr,
      );
    }

    state.data.items[lineArrayIndex].asMap().forEach((key, value) {
      final _stretchPosition = _stretchLine * (key / (_listSize - 1));
      final _fixedPosition = (1 - _stretchLine) * startPosition;

      final _position = _itemWidth * (_stretchPosition + _fixedPosition);

      if (fill && key == 0) {
        _positions.add(Offset(_itemWidth * key + _position, 0.0));
      }

      _positions.add(Offset(_itemWidth * key + _position,
          size.height - ((value.max ?? 0.0) - state.data.minValue) * scale));

      if (fill && state.data.items[lineArrayIndex].length - 1 == key) {
        _positions.add(Offset(_itemWidth * key + _position, 0.0));
      }
    });

    final _path = _getPoints(_positions, fill, size);

    if (dashArray != null) {
      canvas.drawPath(dashPath(_path, dashArray: dashArray!), _paint);
    } else {
      canvas.drawPath(_path, _paint);
    }
  }

  /// Smooth out points and return path in turn
  /// Smoothing is done with quadratic bezier
  Path _getPoints(List<Offset> points, bool fill, Size size) {
    final _points =
        fill ? points.getRange(1, points.length - 1).toList() : points;

    final _path = Path();
    if (fill) {
      _path.moveTo(_points[0].dx, size.height);
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
      final _firstLerpValue =
          lerpDouble(_mid.dx, controlPointX, _smoothPoints) ?? size.height;
      final _secondLerpValue =
          lerpDouble(_mid.dy, _p2.dy, _smoothPoints) ?? size.height;

      _path.cubicTo(controlPointX, _p1.dy, _firstLerpValue, _secondLerpValue,
          _p2.dx, _p2.dy);

      if (i == _points.length - 2) {
        _path.lineTo(_p2.dx, _p2.dy);
        if (fill) {
          _path.lineTo(_p2.dx, size.height);
        }
      }
    }

    return _path;
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SparkLineDecoration) {
      final _smoothPointsLerp =
          lerpDouble(_smoothPoints, endValue._smoothPoints, t) ?? 0.0;
      final _lineWidthLerp =
          lerpDouble(lineWidth, endValue.lineWidth, t) ?? 0.0;

      return SparkLineDecoration._lerp(
          fill: t > 0.5 ? endValue.fill : fill,
          id: endValue.id,
          smoothPoints: _smoothPointsLerp,
          lineWidth: _lineWidthLerp,
          startPosition: lerpDouble(startPosition, endValue.startPosition, t)!,
          lineColor: Color.lerp(lineColor, endValue.lineColor, t)!,
          gradient: Gradient.lerp(gradient, endValue.gradient, t),
          lineArrayIndex: endValue.lineArrayIndex,
          stretchLine: lerpDouble(_stretchLine, endValue._stretchLine, t)!);
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
