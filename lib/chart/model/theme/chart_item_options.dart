part of flutter_charts;

typedef ColorForValue = Color Function(Color defaultColor, double value, [double min]);
typedef ColorForIndex = Color Function(ChartItem item, int index);

/// Options for chart item
/// [padding] This will accept only horizontal padding and will move item away
/// by padding value
/// [radius] BorderRadius for drawn chart bar items
/// [color] Color of bar item
///
/// [maxBarWidth] - Maximum width that bar can be, this width will be applied if there is room on the chart
/// [minBarWidth] - Minimum width that bar has to be, this will ignore padding of items if needed
///
/// [colorForValue] - Set item color based on value of the item
/// [colorForKey] - Set item color based on list it came from
///
/// You can define target values they have ability to color your chart item
/// different color if they missed the target.
class ChartItemOptions {
  const ChartItemOptions({
    this.padding = EdgeInsets.zero,
    this.multiValuePadding = EdgeInsets.zero,
    this.radius = BorderRadius.zero,
    this.color = Colors.red,
    this.maxBarWidth,
    this.minBarWidth,
    this.colorForValue,
    this.colorForKey,
  });

  final BorderRadius radius;
  final EdgeInsets padding;
  final EdgeInsets multiValuePadding;

  final Color color;

  /// Max width of bar in the chart
  final double maxBarWidth;
  final double minBarWidth;

  /// Define color for value, this allows different colors for different values
  final ColorForValue colorForValue;
  final ColorForIndex colorForKey;

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

  static ChartItemOptions lerp(ChartItemOptions a, ChartItemOptions b, double t) {
    return ChartItemOptions(
      padding: EdgeInsets.lerp(a.padding, b.padding, t),
      multiValuePadding: EdgeInsets.lerp(a.multiValuePadding, b.multiValuePadding, t),
      radius: BorderRadius.lerp(a.radius, b.radius, t),
      color: Color.lerp(a.color, b.color, t),
      maxBarWidth: lerpDouble(a.maxBarWidth, b.maxBarWidth, t),
      minBarWidth: lerpDouble(a.minBarWidth, b.minBarWidth, t),
      colorForValue: ColorForValueLerp.lerp(a, b, t),
      colorForKey: ColorForIndexLerp.lerp(a, b, t),
    );
  }
}

class ColorForValueLerp {
  static ColorForValue lerp(ChartItemOptions a, ChartItemOptions b, double t) {
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

class ColorForIndexLerp {
  static ColorForIndex lerp(ChartItemOptions a, ChartItemOptions b, double t) {
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
