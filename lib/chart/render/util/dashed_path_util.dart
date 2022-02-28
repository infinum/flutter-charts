part of charts_painter;

/// Creates a new path that is drawn from the segments of `source`.
/// Passing a `source` that is an empty path will return an empty path.
Path dashPath(
  Path source, {
  required List<double> dashArray,
}) {
  final dest = Path();

  // Get dashed path for this [PathMetric]
  Path _pathFromMetrics(PathMetric metric) {
    final _path = Path();
    var distance = 0.0;
    var _index = 0;

    while (distance < metric.length) {
      final len = dashArray[_index % dashArray.length];
      if (_index % 2 == 0) {
        _path.addPath(
            metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      _index++;
    }

    return _path;
  }

  source.computeMetrics().forEach((metric) {
    dest.addPath(_pathFromMetrics(metric), Offset.zero);
  });

  return dest;
}
