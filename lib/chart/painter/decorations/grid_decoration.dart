part of flutter_charts;

/// Draws a grid with [itemAxisStep] and [valueAxisStep] as spacers
/// Grid will stretch across whole graph and it will ignore the padding from
/// [ChartOptions].
/// That will allow for Legend to be inserted as well.
class GridDecoration extends DecorationPainter {
  GridDecoration({
    this.showHorizontalValues = false,
    this.showVerticalValues = false,
    this.endWithChart = false,
    this.horizontalTextAlign = TextAlign.end,
    this.showTopHorizontalValue = false,
    this.verticalTextAlign = TextAlign.center,
    this.showVerticalGrid = true,
    this.verticalValuesPadding,
    this.horizontalAxisUnit,
    this.verticalAxisValueFromIndex = defaultAxisValue,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.itemAxisStep = 1,
    this.valueAxisStep = 1,
    this.textStyle,
  }) {
    _horizontalAxisDecoration = HorizontalAxisDecoration(
      showValues: showHorizontalValues,
      endWithChart: endWithChart,
      valuesAlign: horizontalTextAlign,
      showTopValue: showTopHorizontalValue,
      horizontalAxisUnit: horizontalAxisUnit,
      gridColor: gridColor,
      gridWidth: gridWidth,
      valueAxisStep: valueAxisStep,
      legendFontStyle: textStyle,
    );
    _verticalAxisDecoration = VerticalAxisDecoration(
      showValues: showVerticalValues,
      valuesAlign: verticalTextAlign,
      showGrid: showVerticalGrid,
      endWithChart: endWithChart,
      gridColor: gridColor,
      axisValueFromIndex: verticalAxisValueFromIndex,
      valuesPadding: verticalValuesPadding,
      gridWidth: gridWidth,
      itemAxisStep: itemAxisStep,
      legendFontStyle: textStyle,
    );
  }

  final bool showHorizontalValues;
  final bool showVerticalValues;
  final bool endWithChart;

  final TextAlign horizontalTextAlign;
  final TextAlign verticalTextAlign;

  final TextStyle textStyle;

  final EdgeInsets verticalValuesPadding;

  final bool showTopHorizontalValue;
  final bool showVerticalGrid;
  final String horizontalAxisUnit;

  HorizontalAxisDecoration _horizontalAxisDecoration;
  VerticalAxisDecoration _verticalAxisDecoration;

  final AxisValueFromIndex verticalAxisValueFromIndex;

  final Color gridColor;
  final double gridWidth;

  /// Change step for y axis (1 by default) used in [GridDecoration], [VerticalAxisDecoration] and [HorizontalAxisDecoration]
  final double itemAxisStep;

  /// Change step for x axis (1 by default) used in [GridDecoration], [VerticalAxisDecoration] and [HorizontalAxisDecoration]
  final double valueAxisStep;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    _horizontalAxisDecoration.draw(canvas, size, state);
    _verticalAxisDecoration.draw(canvas, size, state);
  }

  @override
  EdgeInsets marginNeeded() {
    return _horizontalAxisDecoration.marginNeeded() + _verticalAxisDecoration.marginNeeded();
  }

  @override
  EdgeInsets paddingNeeded() {
    return _horizontalAxisDecoration.paddingNeeded() + _verticalAxisDecoration.paddingNeeded();
  }

  @override
  void initDecoration(ChartState state) {
    _horizontalAxisDecoration.initDecoration(state);
    _verticalAxisDecoration.initDecoration(state);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is GridDecoration) {
      return GridDecoration(
        showHorizontalValues: t < 0.5 ? showHorizontalValues : endValue.showHorizontalValues,
        showVerticalValues: t < 0.5 ? showVerticalValues : endValue.showVerticalValues,
        endWithChart: t < 0.5 ? endWithChart : endValue.endWithChart,
        horizontalTextAlign: t < 0.5 ? horizontalTextAlign : endValue.horizontalTextAlign,
        showTopHorizontalValue: t < 0.5 ? showTopHorizontalValue : endValue.showTopHorizontalValue,
        verticalTextAlign: t < 0.5 ? verticalTextAlign : endValue.verticalTextAlign,
        showVerticalGrid: t < 0.5 ? showVerticalGrid : endValue.showVerticalGrid,
        horizontalAxisUnit: t < 0.5 ? horizontalAxisUnit : endValue.horizontalAxisUnit,
        verticalAxisValueFromIndex: t < 0.5 ? verticalAxisValueFromIndex : endValue.verticalAxisValueFromIndex,
        gridColor: Color.lerp(gridColor, endValue.gridColor, t),
        gridWidth: lerpDouble(gridWidth, endValue.gridWidth, t),
        itemAxisStep: lerpDouble(itemAxisStep, endValue.itemAxisStep, t),
        valueAxisStep: lerpDouble(valueAxisStep, endValue.valueAxisStep, t),
        verticalValuesPadding: EdgeInsets.lerp(verticalValuesPadding, endValue.verticalValuesPadding, t),
        textStyle: TextStyle.lerp(textStyle, endValue.textStyle, t),
      );
    }

    return this;
  }
}
