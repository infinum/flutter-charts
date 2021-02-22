part of flutter_charts;

/// Item painter, use [barPainter] or [barPainter].
/// Custom painter can also be added by extending [GeometryPainter]
typedef ChartGeometryPainter<T> = GeometryPainter<T> Function(ChartItem<T> item, ChartState state);

/// Get color for current item value
typedef ColorForValue = Color Function(Color defaultColor, double value, [double min]);
/// Get color gor current item key (multiple lists)
typedef ColorForKey = Color Function(ChartItem item, int index);

/// Options for drawing the items
/// Need to provide [ChartGeometryPainter]
class ItemOptions {
  const ItemOptions({
    @required this.geometryPainter,
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.maxBarWidth,
    this.minBarWidth,
    this.color = Colors.red,
    this.colorForValue,
    this.colorForKey,
  });

  final EdgeInsets padding;
  final EdgeInsets multiValuePadding;

  /// Define color for value, this allows different colors for different values
  final Color color;
  final ColorForValue colorForValue;
  final ColorForKey colorForKey;

  /// Max width of bar in the chart
  final double maxBarWidth;
  final double minBarWidth;

  /// Geometry
  final ChartGeometryPainter geometryPainter;

  ItemOptions animateTo(ItemOptions endValue, double t) {
    return ItemOptions(
      color: Color.lerp(color, endValue.color, t),
      colorForKey: ColorForKeyLerp.lerp(this, endValue, t),
      colorForValue: ColorForValueLerp.lerp(this, endValue, t),
      padding: EdgeInsets.lerp(padding, endValue.padding, t),
      multiValuePadding: EdgeInsets.lerp(multiValuePadding, endValue.multiValuePadding, t),
      maxBarWidth: lerpDouble(maxBarWidth, endValue.maxBarWidth, t),
      minBarWidth: lerpDouble(minBarWidth, endValue.minBarWidth, t),
      geometryPainter: t > 0.5 ? endValue.geometryPainter : geometryPainter,
    );
  }

  Color getItemColor(ChartItem item, int index) {
    if (item == null) {
      return color;
    }

    if (colorForKey != null) {
      return colorForKey(item, index);
    }

    return _getColorForValue(item.max, item.min);
  }

  Color _getColorForValue(double max, [double min]) {
    if (colorForValue != null) {
      return colorForValue(color, max, min);
    }

    return color;
  }

  Paint getPaintForItem(ChartItem item, Size size, int key) {
    return Paint()..color = getItemColor(item, key);
  }
}

class ColorForValueLerp {
  static ColorForValue lerp(ItemOptions a, ItemOptions b, double t) {
    if (a.colorForValue == null && b.colorForValue == null) {
      return null;
    }

    return (Color defaultColor, double value, [double min]) {
      final Color _aColor = a._getColorForValue(value, min);
      final Color _bColor = b._getColorForValue(value, min);

      return Color.lerp(_aColor, _bColor, t);
    };
  }
}

class ColorForKeyLerp {
  static ColorForKey lerp(ItemOptions a, ItemOptions b, double t) {
    if (a.colorForKey == null && b.colorForKey == null) {
      return null;
    }

    return (ChartItem item, int index) {
      final Color _aColor = a.getItemColor(item, index);
      final Color _bColor = b.getItemColor(item, index);

      return Color.lerp(_aColor, _bColor, t);
    };
  }
}
