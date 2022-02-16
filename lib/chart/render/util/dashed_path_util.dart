part of charts_painter;

/// Creates a new path that is drawn from the segments of `source`.
///
/// Dash intervals are controled by the `dashArray` - see [RepeatingIntervalList]
/// for examples.
///
/// `dashOffset` specifies an initial starting point for the dashing.
///
/// Passing a `source` that is an empty path will return an empty path.
Path dashPath(
  Path source, {
  required List<double> dashArray,
}) {
  final dest = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    var _index = 0;
    while (distance < metric.length) {
      final len = dashArray[_index % dashArray.length];
      if (_index % 2 == 0) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      _index++;
    }
  }

  return dest;
}
