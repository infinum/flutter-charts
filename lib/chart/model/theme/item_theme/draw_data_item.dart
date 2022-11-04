part of charts_painter;

/// Data needed for drawing on the canvas
///
/// Use subclasses [BarItem], [BubbleItem]
abstract class DrawDataItem extends Equatable {
  const DrawDataItem({Color? color, this.gradient, BorderSide? border})
      : color = color ?? Colors.black,
        border = border ?? BorderSide.none;

  /// Set solid color to chart items
  final Color color;

  /// Set gradient color to chart items
  final Gradient? gradient;

  /// Set border to chart items
  final BorderSide border;

  Paint getPaint(Size size) {
    var _paint = Paint();
    _paint.color = color;

    if (gradient != null) {
      // Compiler complains that gradient could be null. But unless if fails us that will never be null.
      _paint.shader = gradient!.createShader(
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    return _paint;
  }
}
