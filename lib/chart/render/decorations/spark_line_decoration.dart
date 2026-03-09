part of charts_painter;

/// Sparkline (Line graph) is considered to be just a decoration.
/// You need to use [BarGeometryPainter] or [BubbleGeometryPainter] in combination.
/// They can be transparent or be used to show values of the graph
class SparkLineDecoration<T> extends DecorationPainter<T> {
  /// Constructor for sparkline decoration
  SparkLineDecoration({
    this.id,
    this.fill = false,
    @Deprecated('Use pathBuilder instead') bool smoothPoints = false,
    PathBuilder? pathBuilder,
    this.lineWidth = 1.0,
    this.lineColor = Colors.red,
    double startPosition = 0.5,
    this.gradient,
    this.sectionIndex = 0,
    this.dashArray,
    this.strokeCap = StrokeCap.butt,
    this.clipToBounds = true,
    bool stretchLine = false,
    this.animatable = true,
    this.lerpOverrides = const {},
  })  : _stretchLine = stretchLine ? 1.0 : 0.0,
        startPosition = startPosition.clamp(0.0, 1.0),
        pathBuilder = pathBuilder ?? (smoothPoints ? CubicBezierPathBuilder() : DefaultPathBuilder());

  SparkLineDecoration._lerp({
    required this.id,
    required this.fill,
    required this.pathBuilder,
    required this.lineWidth,
    required this.lineColor,
    required this.startPosition,
    required this.gradient,
    required this.sectionIndex,
    required this.dashArray,
    required this.strokeCap,
    required this.clipToBounds,
    required double stretchLine,
    required this.animatable,
    required this.lerpOverrides,
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

  @override
  final bool clipToBounds;

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

  @override
  final bool animatable;

  /// Lerp overrides for the decoration.
  ///
  /// This is used to override the default lerp function for a specific property.
  ///
  /// For example, if you want to animate the line color, you can add a lerp override for the lineColor property.
  ///
  /// ```dart
  /// lerpOverrides: {
  ///   'lineColor': ValueLerpOverride(lerpFunction: (a, b, t) => Color.lerp(a, b, t) ?? b),
  /// }
  /// ```
  final Map<String, ValueLerpOverride> lerpOverrides;

  /// Index of list in items, this is used if there are multiple lists in the chart
  ///
  /// By default this will show first list and value will be 0
  final int? sectionIndex;

  @override
  Size layoutSize(BoxConstraints constraints, ChartState<T> state) {
    final _size = (state.defaultPadding + state.defaultMargin).deflateSize(constraints.biggest);
    return _size;
  }

  @override
  Offset applyPaintTransform(ChartState<T> state, Size size) {
    return Offset(
        state.defaultPadding.left + state.defaultMargin.left, state.defaultPadding.top + state.defaultMargin.top);
  }

  @override
  void draw(Canvas canvas, Size size, ChartState<T> state) {
    final _paint = Paint();

    if (fill) {
      _paint.style = PaintingStyle.fill;
    } else {
      _paint
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = strokeCap;
    }

    final _maxValue = state.data.maxValue - state.data.minValue;
    final scale = _maxValue == 0 ? 1 : size.height / _maxValue;

    final _listSize = state.data.animatedListSize;
    if (_listSize <= 0) {
      return;
    }
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
      final left = sectionIndex == null ? 0.0 : state.data.sections[sectionIndex!]._offset * _itemWidth;
      final top = (state.data.maxValue - _maxValueForKey) * scale;

      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(
        Rect.fromLTWH(left, top, width, height),
        textDirection: TextDirection.ltr,
      );
    } else {
      _paint.color = lineColor;
    }

    final sections = sectionIndex != null ? [state.data.sections[sectionIndex!]] : state.data.sections;
    final paths = sections.map(
      (section) {
        final _positions = section.items.mapIndexed((index, value) {
          final _stretchPosition = _stretchLine * (index / (section.items.length - 1));
          final _fixedPosition = (1 - _stretchLine) * startPosition;

          final _position = _itemWidth * (_stretchPosition + _fixedPosition + section._offset);

          return Offset(
            _itemWidth * index + _position,
            size.height - ((value.max ?? 0.0) - state.data.minValue) * scale,
          );
        }).toList();

        return pathBuilder.build(_positions, size: size, encapsulate: fill, clipBottom: clipToBounds);
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

  R _animate<R>(
    String key,
    R value,
    R endValue,
    double t,
    R Function(R, R, double) defaultLerpFunction,
  ) {
    final lerpOverride = lerpOverrides[key]?._accepts(value, endValue);
    if (lerpOverride == null) {
      return animatable ? defaultLerpFunction(value, endValue, t) : endValue;
    }

    return lerpOverride.lerpFunction(value, endValue, t);
  }

  @override
  DecorationPainter<T> animateTo(DecorationPainter<T> endValue, double t) {
    if (endValue is SparkLineDecoration<T>) {
      return SparkLineDecoration<T>._lerp(
        fill: t > 0.5 ? endValue.fill : fill,
        id: endValue.id,
        pathBuilder: _animate(
          'pathBuilder',
          pathBuilder,
          endValue.pathBuilder,
          t,
          (a, b, t) => a.lerp(b, t),
        ),
        lineWidth: _animate<double>(
          'lineWidth',
          lineWidth,
          endValue.lineWidth,
          t,
          (a, b, t) => lerpDouble(a, b, t) ?? b,
        ),
        startPosition: _animate<double>(
          'startPosition',
          startPosition,
          endValue.startPosition,
          t,
          (a, b, t) => lerpDouble(a, b, t) ?? b,
        ),
        lineColor: _animate<Color>(
          'lineColor',
          lineColor,
          endValue.lineColor,
          t,
          (a, b, t) => Color.lerp(a, b, t) ?? b,
        ),
        strokeCap: endValue.strokeCap,
        gradient: _animate<Gradient?>(
          'gradient',
          gradient,
          endValue.gradient,
          t,
          (a, b, t) => Gradient.lerp(a, b, t) ?? b,
        ),
        sectionIndex: endValue.sectionIndex,
        dashArray: endValue.dashArray,
        // Clipping mode should switch immediately to avoid half-animation clipping artifacts.
        clipToBounds: endValue.clipToBounds,
        stretchLine: _animate<double>(
          'stretchLine',
          _stretchLine,
          endValue._stretchLine,
          t,
          (a, b, t) => lerpDouble(a, b, t) ?? b,
        ),
        animatable: endValue.animatable,
        lerpOverrides: endValue.lerpOverrides,
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

class ValueLerpOverride<T> {
  ValueLerpOverride({
    required this.lerpFunction,
  });

  final T Function(T, T, double) lerpFunction;

  /// Check if types intended to call this lerp function are compatible.
  ///
  /// Needed because of Dart's type system and generics limitations.
  ValueLerpOverride<R>? _accepts<R>(R start, R end) {
    if (start is! T || end is! T) {
      return null;
    }

    return ValueLerpOverride<R>(lerpFunction: (a, b, t) {
      return lerpFunction(a as T, b as T, t) as R;
    });
  }
}
