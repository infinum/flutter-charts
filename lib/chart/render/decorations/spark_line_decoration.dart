part of charts_painter;

/// Sparkline (Line graph) is considered to be just a decoration.
/// You need to use [BarGeometryPainter] or [BubbleGeometryPainter] in combination.
/// They can be transparent or be used to show values of the graph
class SparkLineDecoration extends DecorationPainter {
  /// Constructor for sparkline decoration
  SparkLineDecoration({
    this.id,
    this.fill = false,
    @Deprecated('Use pathBuilder instead') bool smoothPoints = false,
    PathBuilder? pathBuilder,
    this.lineWidth = 1.0,
    double lineShift = 0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.sectionIndex = 0,
    this.dashArray,
    bool stretchLine = false,
  })  : _stretchLine = stretchLine ? 1.0 : 0.0,
        lineShift = lineWidth.clamp(-1, 1),
        pathBuilder = pathBuilder ?? (smoothPoints ? CubicBezierPathBuilder() : DefaultPathBuilder());

  SparkLineDecoration._lerp({
    this.id,
    this.fill = false,
    required this.pathBuilder,
    this.lineWidth = 1.0,
    this.lineShift = 0,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.sectionIndex = 0,
    required this.dashArray,
    double stretchLine = 0.0,
  }) : _stretchLine = stretchLine;

  /// Is line or fill, line will have [lineWidth], setting
  /// [fill] to true will ignore [lineWidth]
  final bool fill;

  /// If od sparkline, with different ID's you can have more [SparkLineDecoration]
  /// on same data with different settings. (ex. One to fill and another for just line)
  final String? id;
  final PathBuilder pathBuilder;

  /// Dashed array for showing lines, if this is not set the line is solid
  final List<double>? dashArray;

  /// Set sparkline width
  final double lineWidth;

  /// Set sparkline line shift
  /// By default strokes are painted in the center of the line.
  /// This value can be used to shift the line up or down.
  ///
  /// 0.0 means that line is painted in the center of the line.
  /// 1.0 means that line is painted on the bottom of the line.
  /// -1.0 means that line is painted on the top of the line.
  ///
  /// By default this is set to 0.0, so lines are painted in the center of the line.
  final double lineShift;

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
  final int? sectionIndex;

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    final _size = (state.defaultPadding + state.defaultMargin).deflateSize(constraints.biggest);
    return _size;
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    return Offset(
        state.defaultPadding.left + state.defaultMargin.left, state.defaultPadding.top + state.defaultMargin.top);
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = lineColor
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = size.height / _maxValue;

    final _listSize = state.data.listSize;
    final _itemWidth = size.width / _listSize;

    final items = sectionIndex != null
        ? state.data.sections[sectionIndex!].items
        : state.data.sections.expand((element) => element.items).toList();
    final _maxValueForKey = items.fold(0.0, (double previousValue, element) {
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

    final sections = sectionIndex != null ? [state.data.sections[sectionIndex!]] : state.data.sections;
    final paths = sections.map(
      (section) {
        final _positions = <Offset>[];
        section.items.asMap().forEach((index, value) {
          final _stretchPosition = _stretchLine * (index / (section.items.length - 1));
          final _fixedPosition = (1 - _stretchLine) * startPosition;

          final _position = _itemWidth * (_stretchPosition + _fixedPosition + section.offset);

          if (fill && index == 0) {
            _positions.add(Offset(_position, 0.0));
          }

          _positions.add(
              Offset(_itemWidth * index + _position, size.height - ((value.max ?? 0.0) - state.data.minValue) * scale));

          if (fill && section.items.length - 1 == index) {
            _positions.add(Offset(_itemWidth * index + _position, 0.0));
          }
        });

        return pathBuilder.build(_positions, size, fill);
      },
    );

    for (final path in paths) {
      final shiftedPath = fill ? path : path.shift(Offset(0.0, (lineWidth / 2) * lineShift));

      if (!fill && dashArray != null) {
        canvas.drawPath(dashPath(shiftedPath, dashArray: dashArray!), _paint);
      } else {
        canvas.drawPath(shiftedPath, _paint);
      }
    }
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SparkLineDecoration) {
      return SparkLineDecoration._lerp(
          fill: t > 0.5 ? endValue.fill : fill,
          id: endValue.id,
          pathBuilder: pathBuilder.lerp(endValue.pathBuilder, t),
          lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t) ?? 0.0,
          lineShift: lerpDouble(lineShift, endValue.lineShift, t)!,
          startPosition: lerpDouble(startPosition, endValue.startPosition, t)!,
          lineColor: Color.lerp(lineColor, endValue.lineColor, t)!,
          gradient: Gradient.lerp(gradient, endValue.gradient, t),
          sectionIndex: endValue.sectionIndex,
          dashArray: endValue.dashArray,
          stretchLine: lerpDouble(_stretchLine, endValue._stretchLine, t)!);
    }

    return this;
  }

  @override
  bool isSameType(DecorationPainter other) {
    if (other is SparkLineDecoration) {
      if (id != null && other.id != null) {
        return id == other.id && sectionIndex == other.sectionIndex;
      }

      return sectionIndex == other.sectionIndex;
    }

    return false;
  }
}
