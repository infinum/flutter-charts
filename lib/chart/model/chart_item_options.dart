part of flutter_charts;

typedef ChartItemPainter = ItemPainter Function(ChartItem item, ChartState state);

ItemPainter barItemPainter(ChartItem item, ChartState state) => BarPainter(item, state);
ItemPainter bubbleItemPainter(ChartItem item, ChartState state) => BubblePainter(item, state);

typedef ColorForValue = Color Function(double value, [double min]);

/// Options for chart item
/// [padding] This will accept only horizontal padding and will move item away
/// by padding value
/// [radius] BorderRadius for drawn chart bar items
/// [color] Color of bar item
///
/// You can define target values they have ability to color your chart item
/// different color if they missed the target.
///
/// If you provide [targetMax] or/and [targetMin] then [targetOverColor] color will
/// be applied to items that missed the target.
class ChartItemOptions {
  const ChartItemOptions({
    this.padding = EdgeInsets.zero,
    this.radius = BorderRadius.zero,
    this.color = Colors.red,
    this.maxBarWidth,
    this.minBarWidth,
    this.targetMin,
    this.targetMax,
    this.targetOverColor,
    this.valueColor,
    this.valueColorOver,
    this.showValue = false,
    this.colorForValue,
    this.itemPainter = barItemPainter,
    this.isTargetInclusive = true,
  });

  final BorderRadius radius;
  final EdgeInsets padding;

  final Color color;

  /// Max width of bar in the chart
  final double maxBarWidth;
  final double minBarWidth;

  /// In case you want to change how value acts on the target value
  /// by default this is true, meaning that when the target is the same
  /// as the value then the value and it's not using [targetOverColor] or [valueColorOver]
  final bool isTargetInclusive;

  final double targetMin;
  final double targetMax;
  final Color targetOverColor;

  final bool showValue;
  final Color valueColor;
  final Color valueColorOver;

  final ColorForValue colorForValue;
  final ChartItemPainter itemPainter;

  Color getItemColor(ChartItem item) {
    return _getColorForValue(item.max, item.min);
  }

  Color _getColorForValue(double max, [double min]) {
    if (colorForValue != null) {
      return colorForValue(max, min);
    }

    if (targetMin == null && targetMax == null) {
      return color;
    }

    final _min = min ?? max;

    if ((targetMin != null && _min <= targetMin) || (targetMax != null && max >= targetMax)) {
      // Check if target is inclusive, don't show error color in that case
      if (isTargetInclusive && (_min == targetMin || max == targetMax)) {
        return color;
      }

      return targetOverColor ?? color;
    }

    return color;
  }

  Color getTextColor(ChartItem item) {
    if (getItemColor(item) == color) {
      return valueColor;
    }

    return valueColorOver ?? valueColor;
  }

  static ChartItemOptions lerp(ChartItemOptions a, ChartItemOptions b, double t) {
    return ChartItemOptions(
      padding: EdgeInsets.lerp(a.padding, b.padding, t),
      radius: BorderRadius.lerp(a.radius, b.radius, t),
      color: Color.lerp(a.color, b.color, t),
      targetMin: lerpDouble(a.targetMin, b.targetMin, t),
      targetMax: lerpDouble(a.targetMax, b.targetMax, t),
      targetOverColor: Color.lerp(a.targetOverColor, b.targetOverColor, t),
      valueColor: Color.lerp(a.valueColor, b.valueColor, t),
      valueColorOver: Color.lerp(a.valueColorOver, b.valueColorOver, t),
      maxBarWidth: lerpDouble(a.maxBarWidth, b.maxBarWidth, t),
      minBarWidth: lerpDouble(a.minBarWidth, b.minBarWidth, t),
      colorForValue: ColorForValueLerp.lerp(a, b, t),

      // Lerp missing
      showValue: t < 0.5 ? a.showValue : b.showValue,
      itemPainter: t < 0.5 ? a.itemPainter : b.itemPainter,
    );
  }
}

class ColorForValueLerp {
  static ColorForValue lerp(ChartItemOptions a, ChartItemOptions b, double t) {
    if (a == null && b == null) {
      return null;
    }

    return (double value, [double min]) {
      final Color _aColor = a._getColorForValue(value, min);
      final Color _bColor = b._getColorForValue(value, min);

      return Color.lerp(_aColor, _bColor, t);
    };
  }
}
