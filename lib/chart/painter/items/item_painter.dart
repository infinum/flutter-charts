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

  /// Get default text painter with set [value]
  /// Helper for [paintText]
  static TextPainter makeTextPainter(String value, double width, TextStyle style, {bool hasMaxWidth = true}) {
    final _painter = TextPainter(
      text: TextSpan(
        text: value,
        style: style,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    if (hasMaxWidth) {
      _painter.layout(
        maxWidth: width,
        minWidth: width,
      );
    } else {
      _painter.layout(
        minWidth: width,
      );
    }

    return _painter;
  }
}
