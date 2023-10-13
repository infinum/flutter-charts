part of charts_painter;

/// Item painter for charts
/// Chart will slice the canvas and each item is painted has constraints (width / [itemWidth]) * height
abstract class GeometryPainter<T> {
  /// Default constructor for [GeometryPainter]
  GeometryPainter(this.item, this.data, this.itemOptions);

  /// Current data of the chart
  final ChartData<T?> data;
  final ItemOptions itemOptions;

  /// Current item being painted
  final ChartItem<T?> item;

  /// Draw [ChartItem] on the canvas.
  /// Canvas with item size is passed, item's padding and margin need to be calculated
  /// This is to allow more flexibility for more custom items if needed
  ///
  /// Use [paint] for drawing item to canvas, this allows us to change colors of the item
  /// from [_ChartPainter]
  void draw(Canvas canvas, Size size, Paint paint);

  /// Calculate item width based on current [Size] and [ChartState]
  double itemWidth(Size size) {
    return max(itemOptions.minBarWidth ?? 0.0,
        min(itemOptions.maxBarWidth ?? double.infinity, size.width));
  }
}
