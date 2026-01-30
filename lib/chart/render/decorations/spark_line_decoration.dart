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
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.sectionIndex = 0,
    this.dashArray,
    this.strokeCap = StrokeCap.butt,
    bool stretchLine = false,
  })  : _stretchLine = stretchLine ? 1.0 : 0.0,
        pathBuilder = pathBuilder ?? (smoothPoints ? CubicBezierPathBuilder() : DefaultPathBuilder());

  SparkLineDecoration._lerp({
    this.id,
    this.fill = false,
    required this.pathBuilder,
    required this.lineWidth,
    this.lineColor = Colors.red,
    this.startPosition = 0.5,
    this.gradient,
    this.sectionIndex = 0,
    required this.dashArray,
    required this.strokeCap,
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

  /// Set sparkline stroke cap.
  final StrokeCap strokeCap;

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
      ..strokeWidth = lineWidth
      ..strokeCap = strokeCap;

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
      final width = sectionIndex == null ? size.width : state.data.sections[sectionIndex!].items.length * _itemWidth;
      final height = size.height - (state.data.maxValue - _maxValueForKey) * scale;
      final left = sectionIndex == null ? 0.0 : state.data.sections[sectionIndex!].offset * _itemWidth;
      final top = (state.data.maxValue - _maxValueForKey) * scale;

      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(
        Rect.fromLTWH(left, top, width, height),
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

          _positions.add(
              Offset(_itemWidth * index + _position, size.height - ((value.max ?? 0.0) - state.data.minValue) * scale));
        });

        return pathBuilder.build(_positions, size, fill);
      },
    );

    for (final path in paths) {
      if (!fill && dashArray != null) {
        canvas.drawPath(dashPath(path, dashArray: dashArray!), _paint);
      } else {
        canvas.drawPath(path, _paint);
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
        startPosition: lerpDouble(startPosition, endValue.startPosition, t)!,
        lineColor: Color.lerp(lineColor, endValue.lineColor, t)!,
        strokeCap: endValue.strokeCap,
        gradient: Gradient.lerp(gradient, endValue.gradient, t),
        sectionIndex: endValue.sectionIndex,
        dashArray: endValue.dashArray,
        stretchLine: lerpDouble(_stretchLine, endValue._stretchLine, t)!,
      );
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
