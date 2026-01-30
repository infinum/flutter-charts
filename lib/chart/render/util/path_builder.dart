part of charts_painter;

abstract class PathBuilder {
  Path build(List<Offset> points, Size size, bool encapsulate);
  PathBuilder lerp(PathBuilder other, double t);
}

class DefaultPathBuilder implements PathBuilder {
  const DefaultPathBuilder();

  @override
  PathBuilder lerp(PathBuilder other, double t) {
    if (other is DefaultPathBuilder) {
      return DefaultPathBuilder();
    }

    return other;
  }

  @override
  Path build(List<Offset> points, Size size, bool encapsulate) {
    final _path = Path();

    if (points.isEmpty) {
      return _path;
    }

    if (encapsulate) {
      _path.moveTo(points.first.dx, size.height);
      _path.lineTo(points.first.dx, points.first.dy);
    } else {
      _path.moveTo(points.first.dx, points.first.dy);
      _path.lineTo(points.first.dx, points.first.dy);
    }

    for (final point in points) {
      _path.lineTo(point.dx, point.dy);
    }

    if (encapsulate) {
      _path.lineTo(points.last.dx, size.height);
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
  Path build(List<Offset> points, Size size, bool encapsulate) {
    final _path = Path();
    if (encapsulate) {
      _path.moveTo(points[0].dx, size.height);
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
          _path.lineTo(_p2.dx, size.height);
        }
      }
    }

    return _path;
  }
}

class SmoothCubicBezierPathBuilder implements PathBuilder {
  const SmoothCubicBezierPathBuilder() : _lerp = 1.0;

  const SmoothCubicBezierPathBuilder.lerp({required double lerp}) : _lerp = lerp;

  final double _lerp;

  @override
  PathBuilder lerp(PathBuilder other, double t) {
    if (other is DefaultPathBuilder) {
      return SmoothCubicBezierPathBuilder.lerp(lerp: lerpDouble(_lerp, 0, t) ?? 0);
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

    return tangents;
  }

  List<Offset> _simplifyPoints(List<Offset> points) {
    const double cosThreshold = 0.9962; // cos(5°)

    if (points.length < 3) {
      return points;
    }

    final result = <Offset>[points.first];

    for (int index = 1; index < points.length - 1; index++) {
      final previousPoint = points[index - 1];
      final currentPoint = points[index];
      final nextPoint = points[index + 1];

      final vector1 = currentPoint - previousPoint;
      final vector2 = nextPoint - currentPoint;

      final length1 = vector1.distance;
      final length2 = vector2.distance;
      if (length1 == 0 || length2 == 0) {
        result.add(currentPoint);
        continue;
      }

      final dot = (vector1.dx * vector2.dx + vector1.dy * vector2.dy) / (length1 * length2);

      // Preserve extrema
      final deltaY1 = currentPoint.dy - previousPoint.dy;
      final deltaY2 = nextPoint.dy - currentPoint.dy;
      final isExtremum = deltaY1 * deltaY2 < 0;

      final almostStraight = dot >= cosThreshold;

      if (almostStraight && !isExtremum) {
        // remove currentPoint
        continue;
      }

      result.add(currentPoint);
    }

    result.add(points.last);
    return result;
  }

  @override
  Path build(List<Offset> points, Size size, bool encapsulate) {
    final path = Path();

    if (points.length < 2) {
      return path;
    }

    final simplifiedPoints = _simplifyPoints(points);

    if (encapsulate) {
      path.moveTo(simplifiedPoints.first.dx, size.height);
      path.lineTo(simplifiedPoints.first.dx, simplifiedPoints.first.dy);
    } else {
      path.moveTo(simplifiedPoints.first.dx, simplifiedPoints.first.dy);
    }

    final tangents = _tangents(simplifiedPoints);

    for (int index = 0; index < simplifiedPoints.length - 1; index++) {
      final startPoint = simplifiedPoints[index];
      final endPoint = simplifiedPoints[index + 1];
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
      path.lineTo(simplifiedPoints.last.dx, size.height);
    }

    return path;
  }
}
