part of charts_painter;

/// Item painter, use [barPainter] or [bubblePainter].
/// Custom painter can also be added by extending [GeometryPainter]
typedef ChartGeometryPainter<T> = GeometryPainter<T> Function(ChartItem<T?> item, ChartState state);

/// Get color for current item value
typedef ColorForValue = Color Function(Color defaultColor, double? value, [double? min]);

/// Get color gor current item key (multiple lists)
typedef ColorForKey = Color Function(ChartItem item, int index);

/// Options for drawing the items
/// Need to provide [ChartGeometryPainter]
///
/// Extend this to make your custom options if needed. For example see [BarItemOptions] or [BubbleItemOptions]
class ItemOptions {
  /// Default constructor for ItemOptions
  /// It's recommended to make/use custom item options for custom painters.
  const ItemOptions({
    required this.geometryPainter,
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.maxBarWidth,
    this.minBarWidth,
    this.color = Colors.red,
    this.colorForValue,
    this.colorForKey,
  });

  /// Item padding, if [minBarWidth] and [padding] are more then available space
  /// [padding] will get ignored
  final EdgeInsets padding;

  /// Multi value chart padding, this will `group` values with same index from different lists
  /// use to make space between index changes in multi value charts
  final EdgeInsets multiValuePadding;

  /// Define color for value, this allows different colors for different values
  final Color color;

  /// Generate item color from current value of the item
  final ColorForValue? colorForValue;

  /// Generate item color from index of list it came from, this is for multiple values only.
  final ColorForKey? colorForKey;

  /// Max width of item in the chart
  final double? maxBarWidth;

  /// Min width of item in the chart
  final double? minBarWidth;

  /// Geometry
  final ChartGeometryPainter geometryPainter;

  /// Animate to next [ItemOptions] state
  /// When making custom [ItemOptions] make sure to override this return custom painter
  /// with all available options, otherwise changes in options won't be animated
  ItemOptions animateTo(ItemOptions endValue, double t) {
    final _itemColor = Color.lerp(color, endValue.color, t) ?? Colors.red;
    final _itemPadding = EdgeInsets.lerp(padding, endValue.padding, t) ?? EdgeInsets.zero;
    final _itemMultiValuePadding = EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t) ?? EdgeInsets.zero;

    return ItemOptions(
      color: _itemColor,
      colorForKey: ColorForKeyLerp.lerp(this, endValue, t),
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: _itemPadding,
      multiValuePadding: _itemMultiValuePadding,
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      geometryPainter: t > 0.5 ? endValue.geometryPainter : geometryPainter,
    );
  }

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

    if (colorForKey != null) {
      return colorForKey?.call(item, index) ?? color;
    }

    return _getColorForValue(item.max, item.min);
  }

  Color _getColorForValue(double? max, [double? min]) {
    if (colorForValue != null) {
      return colorForValue?.call(color, max, min) ?? color;
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

    return (Color? defaultColor, double? value, [double? min]) {
      final _aColor = a._getColorForValue(value, min);
      final _bColor = b._getColorForValue(value, min);

      return Color.lerp(_aColor, _bColor, t) ?? _bColor;
    };
  }
}

/// Lerp [ColorForKey] function to get color for key in animation
class ColorForKeyLerp {
  /// Make new function that will return lerp color based on [a.colorForKey] and [b.colorForKey]
  static ColorForKey? lerp(ItemOptions a, ItemOptions b, double t) {
    if (a.colorForKey == null && b.colorForKey == null) {
      return null;
    }

    return (ChartItem item, int index) {
      final _aColor = a.getItemColor(item, index);
      final _bColor = b.getItemColor(item, index);

      return Color.lerp(_aColor, _bColor, t) ?? _bColor;
    };
  }
}
