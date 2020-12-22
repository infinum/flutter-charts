part of flutter_charts;

typedef ColorForValue = Color Function(double value, [double min]);
typedef ColorForIndex = Color Function(ChartItem item, int index);

/// Options for chart item
/// [padding] This will accept only horizontal padding and will move item away
/// by padding value
/// [radius] BorderRadius for drawn chart bar items
/// [color] Color of bar item
///
/// You can define target values they have ability to color your chart item
/// different color if they missed the target.
///
/// If you provide [targetMax] or/and [targetMin] then [colorOverTarget] color will
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
    this.colorOverTarget,
    this.colorForValue,
    this.colorForIndex,
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
  /// as the value then the value and it's not using [colorOverTarget] or [valueColorOver]
  final bool isTargetInclusive;

  final double targetMin;
  final double targetMax;
  final Color colorOverTarget;

  final ColorForValue colorForValue;
  final ColorForIndex colorForIndex;

  Color getItemColor(ChartItem item, int index) {
    if (colorForIndex != null) {
      return colorForIndex(item, index);
    }

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

      return colorOverTarget ?? color;
    }

    return color;
  }

  static ChartItemOptions lerp(ChartItemOptions a, ChartItemOptions b, double t) {
    return ChartItemOptions(
      padding: EdgeInsets.lerp(a.padding, b.padding, t),
      radius: BorderRadius.lerp(a.radius, b.radius, t),
      color: Color.lerp(a.color, b.color, t),
      targetMin: lerpDouble(a.targetMin, b.targetMin, t),
      targetMax: lerpDouble(a.targetMax, b.targetMax, t),
      colorOverTarget: Color.lerp(a.colorOverTarget, b.colorOverTarget, t),
      maxBarWidth: lerpDouble(a.maxBarWidth, b.maxBarWidth, t),
      minBarWidth: lerpDouble(a.minBarWidth, b.minBarWidth, t),
      colorForValue: ColorForValueLerp.lerp(a, b, t),
      colorForIndex: ColorForIndexLerp.lerp(a, b, t),
    );
  }
}

class ColorForValueLerp {
  static ColorForValue lerp(ChartItemOptions a, ChartItemOptions b, double t) {
    if (a.colorForValue == null && b.colorForValue == null) {
      return null;
    }

    return (double value, [double min]) {
      final Color _aColor = a._getColorForValue(value, min);
      final Color _bColor = b._getColorForValue(value, min);

      return Color.lerp(_aColor, _bColor, t);
    };
  }
}

class ColorForIndexLerp {
  static ColorForIndex lerp(ChartItemOptions a, ChartItemOptions b, double t) {
    if (a.colorForIndex == null && b.colorForIndex == null) {
      return null;
    }

    return (ChartItem item, int index) {
      final Color _aColor = a.getItemColor(item, index);
      final Color _bColor = b.getItemColor(item, index);

      return Color.lerp(_aColor, _bColor, t);
    };
  }
}
