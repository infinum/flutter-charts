import 'dart:math' as math;
import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sample evenly along [path] by arc length and return the sampled points.
List<Offset> _samplePath(Path path, {double step = 0.5}) {
  final samples = <Offset>[];
  for (final metric in path.computeMetrics()) {
    for (double d = 0; d < metric.length; d += step) {
      final tangent = metric.getTangentForOffset(d);
      if (tangent != null) samples.add(tangent.position);
    }
    final end = metric.getTangentForOffset(metric.length);
    if (end != null) samples.add(end.position);
  }
  return samples;
}

double _minDistance(Offset point, List<Offset> samples) {
  var best = double.infinity;
  for (final s in samples) {
    final d = (s - point).distance;
    if (d < best) best = d;
  }
  return best;
}

void main() {
  const size = Size(200, 100);
  const peak = [
    Offset(0, 40),
    Offset(40, 10),
    Offset(80, 80),
    Offset(120, 30),
    Offset(160, 60),
  ];

  group('SmoothCubicBezierPathBuilder', () {
    test('defaults to no simplification (maxError == 0)', () {
      expect(const SmoothCubicBezierPathBuilder().maxError, 0.0);
    });

    test('passes through every input point with default args', () {
      final path = const SmoothCubicBezierPathBuilder()
          .build(peak, size: size, encapsulate: false, clipBottom: false);
      final samples = _samplePath(path);

      for (final p in peak) {
        expect(_minDistance(p, samples), lessThan(1.0),
            reason: 'curve should pass through $p');
      }
    });

    test('never overshoots the input data range', () {
      final path = const SmoothCubicBezierPathBuilder()
          .build(peak, size: size, encapsulate: false, clipBottom: false);
      final samples = _samplePath(path);

      final inputMinY = peak.map((p) => p.dy).reduce(math.min);
      final inputMaxY = peak.map((p) => p.dy).reduce(math.max);
      final sampledMinY = samples.map((p) => p.dy).reduce(math.min);
      final sampledMaxY = samples.map((p) => p.dy).reduce(math.max);

      expect(sampledMinY, greaterThanOrEqualTo(inputMinY - 0.5));
      expect(sampledMaxY, lessThanOrEqualTo(inputMaxY + 0.5));
    });

    test('stays within neighbouring points on flat-then-spike data', () {
      // Mirrors the bug report: long flat plateau, a sharp spike, a dip below
      // the plateau and a short step. Uneven slopes on either side of a point
      // used to produce tangents that made the curve overshoot the frame.
      const spike = [
        Offset(0, 90),
        Offset(20, 90),
        Offset(40, 90),
        Offset(60, 90),
        Offset(80, 89),
        Offset(100, 5),
        Offset(110, 100),
        Offset(120, 98),
        Offset(140, 60),
        Offset(160, 60),
      ];
      final path = const SmoothCubicBezierPathBuilder()
          .build(spike, size: size, encapsulate: false, clipBottom: false);
      final samples = _samplePath(path, step: 0.25);

      // Between every pair of consecutive data points the curve must stay
      // within the y-range spanned by those two points (local monotonicity).
      for (var i = 0; i < spike.length - 1; i++) {
        final a = spike[i];
        final b = spike[i + 1];
        final lo = math.min(a.dy, b.dy) - 0.5;
        final hi = math.max(a.dy, b.dy) + 0.5;
        for (final s in samples) {
          if (s.dx < a.dx || s.dx > b.dx) continue;
          expect(s.dy, inInclusiveRange(lo, hi),
              reason: 'sample $s leaves the range of segment $a -> $b');
        }
      }
    });

    test('simplification is opt-in: maxError > 0 drops near-collinear points', () {
      // Middle point sits 3px off the straight chord between the endpoints.
      const points = [Offset(0, 0), Offset(50, 3), Offset(100, 0)];

      final kept = const SmoothCubicBezierPathBuilder()
          .build(points, size: size, encapsulate: false, clipBottom: false);
      expect(_minDistance(const Offset(50, 3), _samplePath(kept)), lessThan(1.0),
          reason: 'default (maxError 0) keeps the point');

      final dropped = const SmoothCubicBezierPathBuilder(maxError: 5.0)
          .build(points, size: size, encapsulate: false, clipBottom: false);
      expect(_minDistance(const Offset(50, 3), _samplePath(dropped)),
          greaterThan(1.0),
          reason: 'maxError 5 decimates the 3px-off point');
    });
  });
}
