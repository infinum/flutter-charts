part of charts_painter;

/// Item painter, use [barPainter] or [bubblePainter].
/// Custom painter can also be added by extending [GeometryPainter]
typedef ChartGeometryPainter<T> = GeometryPainter<T> Function(
    ChartItem<T?> item, ChartData data, ItemOptions itemOptions);

/// Get color for current item value
typedef ColorForValue<T> = Color Function(
    Color defaultColor, ChartItem<T> item);

/// Options for drawing the items
/// Need to provide [ChartGeometryPainter]
///
/// Extend this to make your custom options if needed. For example see [BarItemOptions] or [BubbleItemOptions]
abstract class ItemOptions {
  /// Default constructor for ItemOptions
  /// It's recommended to make/use custom item options for custom painters.
  const ItemOptions({
    required this.geometryPainter,
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.maxBarWidth,
    this.minBarWidth,
    this.startPosition = 0.5,
    this.color = Colors.red,
    this.colorForValue,
    bool multiItemStack = true,
  }) : _multiValueStacked = multiItemStack ? 1.0 : 0.0;

  const ItemOptions._lerp({
    required this.geometryPainter,
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.maxBarWidth,
    this.minBarWidth,
    this.startPosition = 0.5,
    this.color = Colors.red,
    this.colorForValue,
    double multiItemStack = 1.0,
  }) : _multiValueStacked = multiItemStack;

  /// Item padding, if [minBarWidth] and [padding] are more then available space
  /// [padding] will get ignored
  final EdgeInsets padding;

  /// Multi value chart padding, this will `group` values with same index from different lists
  /// use to make space between index changes in multi value charts
  final EdgeInsets multiValuePadding;
  final double _multiValueStacked;

  /// Define color for value, this allows different colors for different values
  final Color color;

  /// Generate item color from current value of the item
  final ColorForValue? colorForValue;

  /// Max width of item in the chart
  final double? maxBarWidth;

  /// Min width of item in the chart
  final double? minBarWidth;

  /// Set start position.
  /// This value ranges from 0.0 - 1.0.
  ///
  /// 0.0 means that start position is left most point of the item,
  /// 1.0 means right most point.
  ///
  /// By default this is set to 0.5, so items are located in center
  final double startPosition;

  /// Geometry
  final ChartGeometryPainter geometryPainter;

  /// Return true if multi item drawing is set to stack
  bool get multiValueStack => _multiValueStacked > 0.5;

  /// Animate to next [ItemOptions] state
  /// When making custom [ItemOptions] make sure to override this return custom painter
  /// with all available options, otherwise changes in options won't be animated
  ItemOptions animateTo(ItemOptions endValue, double t);

  /// Get current item color
  ///
  /// Order for getting item color is:
  /// 1. [item] is null then just [color] is returned.
  /// 2. [colorForKey] is set then return color we get from [colorForKey]
  /// 3. [colorForValue] is set then return color we get from [colorForValue]
  /// 4. both [colorForKey] and [colorForValue] are null then return [color]
  Color getItemColor(ChartItem? item, int index) {
    if (item == null) {
      return color;
    }

    return _getColorForValue(item);
  }

  Color _getColorForValue(ChartItem item) {
    if (colorForValue != null) {
      return colorForValue?.call(color, item) ?? color;
    }

    return color;
  }

  /// Get paint used to draw this item.
  Paint getPaintForItem(ChartItem item, Size size, int key) {
    return Paint()..color = getItemColor(item, key);
  }
}

/// Lerp [ColorForValue] function to get color in the animation
class ColorForValueLerp {
  /// Make new function that will return lerp color based on [a.colorForValue] and [b.colorForValue]
  static ColorForValue? lerp(ItemOptions a, ItemOptions b, double t) {
    if (a.colorForValue == null && b.colorForValue == null) {
      return null;
    }

    return (Color? defaultColor, ChartItem item) {
      final _aColor = a._getColorForValue(item);
      final _bColor = b._getColorForValue(item);

      return Color.lerp(_aColor, _bColor, t) ?? _bColor;
    };
  }
}
