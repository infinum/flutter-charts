part of charts_painter;

/// Empty geometry painter. Used if you don't want to use [DecorationPainter] to paint the items.
class _EmptyGeometryPainter<T> extends GeometryPainter<T> {
  /// Not used
  _EmptyGeometryPainter(
      ChartItem<T> item, ChartData<T?> data, ItemOptions itemOptions)
      : super(item, data, itemOptions);

  @override
  void draw(Canvas canvas, Size size, Paint paint) {}
}
