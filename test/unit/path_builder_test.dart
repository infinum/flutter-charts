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
