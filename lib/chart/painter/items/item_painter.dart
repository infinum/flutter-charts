part of flutter_charts;

/// Item painter for charts
abstract class ItemPainter {
  ItemPainter(this.item, this.state);

  final ChartState state;
  final ChartItem item;

  /// Draw [ChartItem] on the canvas.
  /// Canvas with item size is passed, item's padding and margin need to be calculated
  /// This is to allow more flexibility for more custom items if needed
  ///
  /// Use [paint] for drawing item to canvas, this allows us to change colors of the item
  /// from [ChartPainter]
  void draw(Canvas canvas, Size size, Paint paint);

  double itemWidth(Size size) => max(state.itemOptions.minBarWidth ?? 0.0,
      min(state.itemOptions.maxBarWidth ?? double.infinity, size.width - state.itemOptions.padding.horizontal));
}
