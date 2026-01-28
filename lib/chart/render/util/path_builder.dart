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
