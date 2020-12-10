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

  /// How should [ChartItem] value be displayed on the item.
  /// This will be called if [ChartItemOptions.showValue] is set to true
  void paintText(Canvas canvas, Size size, ChartState state, double width, double verticalMultiplier, double minValue);

  /// Get default text painter with set [value]
  /// Helper for [paintText]
  static TextPainter makeTextPainter(Color textColor, String value, double width) {
    return TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: 14.0,
          color: textColor ?? Colors.grey,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: width,
        minWidth: width,
      );
  }
}
