part of charts_painter;

abstract class PathBuilder {
  Path build(
    List<Offset> points, {
    required Size size,
    required bool encapsulate,
    required bool clipBottom,
  });
  PathBuilder lerp(PathBuilder other, double t);
}

class DefaultPathBuilder implements PathBuilder {
  const DefaultPathBuilder();

  @override
  PathBuilder lerp(PathBuilder other, double t) {
    if (other is DefaultPathBuilder) {
      return const DefaultPathBuilder();
    }

    // When transitioning from a straight line to a smooth path, gradually
    // increase the smoothing factor so the line doesn't "jump" to the new
    // shape immediately.
    if (other is SmoothCubicBezierPathBuilder) {
      return SmoothCubicBezierPathBuilder._withFactor(t);
    }

    if (other is CubicBezierPathBuilder) {
      return CubicBezierPathBuilder.lerp(lerp: t);
    }

    return other;
  }

  @override
  Path build(List<Offset> points, {required Size size, required bool encapsulate, required bool clipBottom}) {
    final _path = Path();

    if (points.isEmpty) {
      return _path;
    }

    if (encapsulate) {
      _path.moveTo(points.first.dx, clipBottom ? size.height : Rect.largest.height);
      _path.lineTo(points.first.dx, points.first.dy);
    } else {
      _path.moveTo(points.first.dx, points.first.dy);
      _path.lineTo(points.first.dx, points.first.dy);
    }

    for (final point in points) {
      _path.lineTo(point.dx, point.dy);
    }

    if (encapsulate) {
      _path.lineTo(points.last.dx, clipBottom ? size.height : Rect.largest.height);
    }

    return _path;
  }
}

class CubicBezierPathBuilder implements PathBuilder {
  const CubicBezierPathBuilder() : _lerp = 1.0;

  const CubicBezierPathBuilder.lerp({required double lerp}) : _lerp = lerp;

  final double _lerp;

  @override
  PathBuilder lerp(PathBuilder other, double t) {
    if (other is DefaultPathBuilder) {
      return CubicBezierPathBuilder.lerp(lerp: lerpDouble(_lerp, 0, t) ?? 0);
    }

    return other;
  }

  @override
  Path build(List<Offset> points, {required Size size, required bool encapsulate, required bool clipBottom}) {
    final _path = Path();
    if (encapsulate) {
      _path.moveTo(points[0].dx, clipBottom ? size.height : Rect.largest.height);
      _path.lineTo(points[0].dx, points[0].dy);
      _path.lineTo(points.first.dx, points.first.dy);
    } else {
      _path.moveTo(points[0].dx, points[0].dy);
      _path.lineTo(points.first.dx, points.first.dy);
    }

    for (var i = 0; i < points.length - 1; i++) {
      final _p1 = points[i % points.length];
      final _p2 = points[(i + 1) % points.length];
      final controlPointX = _p1.dx + ((_p2.dx - _p1.dx) / 2) * _lerp;
      final _mid = (_p1 + _p2) / 2;
      final _firstLerpValue = lerpDouble(_mid.dx, controlPointX, _lerp) ?? size.height;
      final _secondLerpValue = lerpDouble(_mid.dy, _p2.dy, _lerp) ?? size.height;

      _path.cubicTo(controlPointX, _p1.dy, _firstLerpValue, _secondLerpValue, _p2.dx, _p2.dy);

      if (i == points.length - 2) {
        _path.lineTo(_p2.dx, _p2.dy);
        if (encapsulate) {
          _path.lineTo(_p2.dx, clipBottom ? size.height : Rect.largest.height);
        }
      }
    }

    return _path;
  }
}

class SmoothCubicBezierPathBuilder implements PathBuilder {
  const SmoothCubicBezierPathBuilder({this.maxError = 2.0}) : _smoothFactor = 1.0;

  const SmoothCubicBezierPathBuilder._withFactor(this._smoothFactor, [this.maxError = 2.0]);

  /// Maximum allowed distance (in logical pixels) from any original point to
  /// the simplified path. Fewer points are kept when this is larger.
  final double maxError;

  /// How strong the smoothing effect is.
  ///
  /// 0.0 – behaves like a straight line (DefaultPathBuilder)
  /// 1.0 – fully smoothed.
  final double _smoothFactor;

  @override
  PathBuilder lerp(PathBuilder other, double t) {
    if (other is SmoothCubicBezierPathBuilder) {
      return SmoothCubicBezierPathBuilder._withFactor(
        lerpDouble(_smoothFactor, other._smoothFactor, t) ?? other._smoothFactor,
        t > 0.5 ? other.maxError : maxError,
      );
    }

    if (other is DefaultPathBuilder) {
      return SmoothCubicBezierPathBuilder._withFactor(
        lerpDouble(_smoothFactor, 0.0, t) ?? 0.0,
        maxError,
      );
    }

    if (other is CubicBezierPathBuilder) {
      return SmoothCubicBezierPathBuilder._withFactor(
        lerpDouble(_smoothFactor, 0.0, t) ?? 0.0,
        maxError,
      );
    }

    return other;
  }

  List<double> _slopes(List<Offset> points) {
    final pointCount = points.length;
    final slopes = List<double>.filled(pointCount - 1, 0);

    for (int index = 0; index < pointCount - 1; index++) {
      slopes[index] = (points[index + 1].dy - points[index].dy) / (points[index + 1].dx - points[index].dx);
    }
    return slopes;
  }

  List<double> _tangents(List<Offset> points) {
    final slopes = _slopes(points);
    final pointCount = points.length;
    final tangents = List<double>.filled(pointCount, 0);

    tangents[0] = 0;
    tangents[pointCount - 1] = 0;

    for (int index = 1; index < pointCount - 1; index++) {
      if (slopes[index - 1] * slopes[index] <= 0) {
        tangents[index] = 0; // slope sign change
      } else {
        tangents[index] = (slopes[index - 1] + slopes[index]) / 2;
      }
    }

    // Scale all tangents with smoothing factor so we can smoothly interpolate
    // between a straight line (_smoothFactor = 0) and the fully smoothed
    // version (_smoothFactor = 1).
    if (_smoothFactor != 1.0) {
      for (var i = 0; i < tangents.length; i++) {
        tangents[i] *= _smoothFactor;
      }
    }

    return tangents;
  }

  /// Ramer–Douglas–Peucker: fewest points such that every original point is
  /// within [maxError] of the simplified path.
  List<Offset> _simplifyPoints(List<Offset> points) {
    if (points.length <= 2) {
      return points;
    }
    final epsilon2 = maxError * maxError;
    return _rdp(points, 0, points.length - 1, epsilon2);
  }

  List<Offset> _rdp(List<Offset> points, int start, int end, double epsilon2) {
    if (end <= start + 1) {
      return [points[start], points[end]];
    }
    final a = points[start];
    final b = points[end];
    final ab = Offset(b.dx - a.dx, b.dy - a.dy);
    final abLen2 = ab.dx * ab.dx + ab.dy * ab.dy;

    double dmax2 = 0;
    int split = start + 1;
    for (int i = start + 1; i < end; i++) {
      final p = points[i];
      final ap = Offset(p.dx - a.dx, p.dy - a.dy);
      double dist2;
      if (abLen2 == 0) {
        dist2 = ap.dx * ap.dx + ap.dy * ap.dy;
      } else {
        final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / abLen2).clamp(0.0, 1.0);
        final q = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
        final dq = Offset(p.dx - q.dx, p.dy - q.dy);
        dist2 = dq.dx * dq.dx + dq.dy * dq.dy;
      }
      if (dist2 > dmax2) {
        dmax2 = dist2;
        split = i;
      }
    }

    if (dmax2 <= epsilon2) {
      return [points[start], points[end]];
    }
    final left = _rdp(points, start, split, epsilon2);
    final right = _rdp(points, split, end, epsilon2);
    return [...left.sublist(0, left.length - 1), ...right];
  }

  @override
  Path build(List<Offset> points, {required Size size, required bool encapsulate, required bool clipBottom}) {
    if (points.length < 2) {
      return Path();
    }
    // Simplify to fewest points such that error at each original point is < maxError.
    final simplifiedPoints = _simplifyPoints(points);
    return _buildPathFromPoints(
      simplifiedPoints,
      size: size,
      encapsulate: encapsulate,
      clipBottom: clipBottom,
    );
  }

  Path _buildPathFromPoints(
    List<Offset> points, {
    required Size size,
    required bool encapsulate,
    required bool clipBottom,
  }) {
    final path = Path();

    if (encapsulate) {
      path.moveTo(points.first.dx, clipBottom ? size.height : Rect.largest.height);
      path.lineTo(points.first.dx, points.first.dy);
    } else {
      path.moveTo(points.first.dx, points.first.dy);
    }

    final tangents = _tangents(points);

    for (int index = 0; index < points.length - 1; index++) {
      final startPoint = points[index];
      final endPoint = points[index + 1];
      final deltaX = endPoint.dx - startPoint.dx;

      final controlPoint1 = Offset(
        startPoint.dx + deltaX / 3,
        startPoint.dy + tangents[index] * deltaX / 3,
      );

      final controlPoint2 = Offset(
        endPoint.dx - deltaX / 3,
        endPoint.dy - tangents[index + 1] * deltaX / 3,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        endPoint.dx,
        endPoint.dy,
      );
    }

    if (encapsulate) {
      path.lineTo(
        points.last.dx,
        clipBottom ? size.height : Rect.largest.height,
      );
    }

    return path;
  }
}
