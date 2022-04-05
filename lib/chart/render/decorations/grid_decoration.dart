part of charts_painter;

/// Draws a grid with [verticalAxisStep] and [horizontalAxisStep] as spacers
///
/// That will allow for Legend to be inserted as well.
class GridDecoration extends DecorationPainter {
  /// Make grid decoration for the chart
  ///
  /// Grid decoration is just merge of [HorizontalAxisDecoration] and [VerticalAxisDecoration]
  GridDecoration({
    this.showHorizontalValues = false,
    this.showVerticalValues = false,
    bool endWithChart = false,
    this.horizontalTextAlign = TextAlign.end,
    this.showTopHorizontalValue = false,
    this.verticalTextAlign = TextAlign.center,
    this.showVerticalGrid = true,
    this.showHorizontalGrid = true,
    this.verticalValuesPadding,
    this.horizontalValuesPadding,
    this.horizontalAxisUnit,
    this.verticalAxisValueFromIndex = defaultAxisValue,
    this.horizontalAxisValueFromValue = defaultAxisValue,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.dashArray,
    this.verticalAxisStep = 1,
    this.horizontalAxisStep = 1,
    this.textScale = 1.5,
    this.horizontalLegendPosition = HorizontalLegendPosition.end,
    this.verticalLegendPosition = VerticalLegendPosition.bottom,
    this.showHorizontalLineForValue,
    this.textStyle,
  })  : _endWithChart = endWithChart ? 1.0 : 0.0,
        assert(
            textStyle != null ||
                !(showHorizontalValues ||
                    showTopHorizontalValue ||
                    showVerticalValues),
            'Need to provide text style for values to be visible!') {
    _horizontalAxisDecoration = HorizontalAxisDecoration(
      showValues: showHorizontalValues,
      endWithChart: endWithChart,
      showLines: showHorizontalGrid,
      valuesAlign: horizontalTextAlign,
      valuesPadding: horizontalValuesPadding,
      showTopValue: showTopHorizontalValue,
      horizontalAxisUnit: horizontalAxisUnit,
      showLineForValue: showHorizontalLineForValue,
      lineColor: gridColor,
      dashArray: dashArray,
      lineWidth: gridWidth,
      textScale: textScale,
      axisStep: horizontalAxisStep,
      axisValue: horizontalAxisValueFromValue,
      legendFontStyle: textStyle,
      legendPosition: horizontalLegendPosition,
    );
    _verticalAxisDecoration = VerticalAxisDecoration(
      showValues: showVerticalValues,
      valuesAlign: verticalTextAlign,
      showLines: showVerticalGrid,
      endWithChart: endWithChart,
      lineColor: gridColor,
      dashArray: dashArray,
      valueFromIndex: verticalAxisValueFromIndex,
      legendPosition: verticalLegendPosition,
      valuesPadding: verticalValuesPadding,
      lineWidth: gridWidth,
      axisStep: verticalAxisStep,
      legendFontStyle: textStyle,
    );
  }

  GridDecoration._lerp({
    this.showHorizontalValues = false,
    this.showVerticalValues = false,
    double endWithChart = 0.0,
    this.horizontalTextAlign = TextAlign.end,
    this.showTopHorizontalValue = false,
    this.verticalTextAlign = TextAlign.center,
    this.showVerticalGrid = true,
    this.showHorizontalGrid = true,
    this.verticalValuesPadding,
    this.horizontalValuesPadding,
    this.horizontalAxisUnit,
    this.verticalAxisValueFromIndex = defaultAxisValue,
    this.horizontalAxisValueFromValue = defaultAxisValue,
    this.gridColor = Colors.grey,
    this.gridWidth = 1.0,
    this.verticalAxisStep = 1,
    this.horizontalAxisStep = 1,
    this.textScale = 1.5,
    this.dashArray,
    this.showHorizontalLineForValue,
    this.horizontalLegendPosition = HorizontalLegendPosition.end,
    this.verticalLegendPosition = VerticalLegendPosition.bottom,
    this.textStyle,
  })  : _endWithChart = endWithChart,
        assert(
            textStyle != null ||
                !(showHorizontalValues ||
                    showTopHorizontalValue ||
                    showVerticalValues),
            'Need to provide text style for values to be visible!') {
    _horizontalAxisDecoration = HorizontalAxisDecoration._lerp(
      showValues: showHorizontalValues,
      endWithChart: _endWithChart,
      valuesAlign: horizontalTextAlign,
      showTopValue: showTopHorizontalValue,
      showLines: showHorizontalGrid,
      horizontalAxisUnit: horizontalAxisUnit,
      valuesPadding: horizontalValuesPadding,
      lineColor: gridColor,
      dashArray: dashArray,
      textScale: textScale,
      showLineForValue: showHorizontalLineForValue,
      axisValue: horizontalAxisValueFromValue,
      lineWidth: gridWidth,
      axisStep: horizontalAxisStep,
      legendFontStyle: textStyle,
      legendPosition: horizontalLegendPosition,
    );
    _verticalAxisDecoration = VerticalAxisDecoration._lerp(
      showValues: showVerticalValues,
      valuesAlign: verticalTextAlign,
      showLines: showVerticalGrid,
      endWithChart: _endWithChart,
      lineColor: gridColor,
      dashArray: dashArray,
      valueFromIndex: verticalAxisValueFromIndex,
      valuesPadding: verticalValuesPadding,
      lineWidth: gridWidth,
      legendPosition: verticalLegendPosition,
      axisStep: verticalAxisStep,
      legendFontStyle: textStyle,
    );
  }

  /// Should grid show horizontal axis values.
  ///
  /// Need to provide [textStyle] if this is set to true
  final bool showHorizontalValues;

  /// Should grid show vertical axis values
  ///
  /// Need to provide [textStyle] if this is set to true
  final bool showVerticalValues;

  /// This decoration can continue beyond padding set by [ChartState]
  /// setting this to true will stop drawing on padding, and will end
  /// at same place where the chart will end
  ///
  /// This does not apply to axis legend text, text can still be shown on the padding part
  bool get endWithChart => _endWithChart > 0.5;
  final double _endWithChart;

  /// Align horizontal legend text
  final TextAlign horizontalTextAlign;

  /// Align vertical legend text
  final TextAlign verticalTextAlign;

  /// Text style for legends, same style is used for both [HorizontalAxisDecoration] and [VerticalAxisDecoration], if
  /// both [showHorizontalValues] and [showVerticalValues] are set to true.
  final TextStyle? textStyle;

  /// Padding for horizontal values in axis legend
  final EdgeInsets? horizontalValuesPadding;

  /// Padding for vertical values in axis legend
  final EdgeInsets? verticalValuesPadding;

  /// Should top horizontal value be shown? This will increase padding such that
  /// text fits above the chart and adds top most value on horizontal scale.
  final bool showTopHorizontalValue;

  /// Hide or show vertical lines on the grid
  final bool showVerticalGrid;

  /// Hide or show horizontal lines on the grid
  final bool showHorizontalGrid;

  /// Label that is shown at the end of the chart on horizontal axis.
  /// This is usually to show measure unit used for axis
  final String? horizontalAxisUnit;

  /// Dash array pattern for creating dashed grid
  final List<double>? dashArray;

  /// Position of horizontal legend
  /// Default: [HorizontalLegendPosition.end]
  /// Can be [HorizontalLegendPosition.start] or [HorizontalLegendPosition.end]
  final HorizontalLegendPosition horizontalLegendPosition;

  /// Position of vertical legend
  /// Default: [VerticalLegendPosition.bottom]
  /// Can be [VerticalLegendPosition.bottom] or [VerticalLegendPosition.top]
  final VerticalLegendPosition verticalLegendPosition;

  late HorizontalAxisDecoration _horizontalAxisDecoration;
  late VerticalAxisDecoration _verticalAxisDecoration;

  /// Generate vertical axis legend from item index
  final AxisValueFromIndex verticalAxisValueFromIndex;

  /// Generate horizontal axis legend from value steps
  final AxisValueFromValue horizontalAxisValueFromValue;

  /// Show horizontal line for current value. Return true if you want to show the line.
  final ShowLineForValue? showHorizontalLineForValue;

  /// Change grid color
  final Color gridColor;

  /// Change grid line width
  final double gridWidth;

  final double textScale;

  /// Change step for y axis (1 by default) used in [GridDecoration], [VerticalAxisDecoration] and [HorizontalAxisDecoration]
  final double verticalAxisStep;

  /// Change step for x axis (1 by default) used in [GridDecoration], [VerticalAxisDecoration] and [HorizontalAxisDecoration]
  final double horizontalAxisStep;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    _horizontalAxisDecoration.draw(canvas, size, state);
    _verticalAxisDecoration.draw(canvas, size, state);
  }

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    return constraints.deflate(state.defaultMargin).biggest;
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    return Offset(state.defaultMargin.left, state.defaultMargin.top);
  }

  @override
  EdgeInsets marginNeeded() {
    return _horizontalAxisDecoration.marginNeeded() +
        _verticalAxisDecoration.marginNeeded();
  }

  @override
  EdgeInsets paddingNeeded() {
    return _horizontalAxisDecoration.paddingNeeded() +
        _verticalAxisDecoration.paddingNeeded();
  }

  @override
  void initDecoration(ChartState state) {
    _horizontalAxisDecoration.initDecoration(state);
    _verticalAxisDecoration.initDecoration(state);
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is GridDecoration) {
      return GridDecoration._lerp(
        showHorizontalValues:
            t < 0.5 ? showHorizontalValues : endValue.showHorizontalValues,
        showVerticalValues:
            t < 0.5 ? showVerticalValues : endValue.showVerticalValues,
        endWithChart: lerpDouble(_endWithChart, endValue._endWithChart, t) ??
            endValue._endWithChart,
        horizontalTextAlign:
            t < 0.5 ? horizontalTextAlign : endValue.horizontalTextAlign,
        showTopHorizontalValue:
            t < 0.5 ? showTopHorizontalValue : endValue.showTopHorizontalValue,
        verticalTextAlign:
            t < 0.5 ? verticalTextAlign : endValue.verticalTextAlign,
        showVerticalGrid:
            t < 0.5 ? showVerticalGrid : endValue.showVerticalGrid,
        showHorizontalGrid:
            t < 0.5 ? showHorizontalGrid : endValue.showHorizontalGrid,
        horizontalAxisUnit:
            t < 0.5 ? horizontalAxisUnit : endValue.horizontalAxisUnit,
        verticalAxisValueFromIndex: t < 0.5
            ? verticalAxisValueFromIndex
            : endValue.verticalAxisValueFromIndex,
        horizontalAxisValueFromValue: t < 0.5
            ? horizontalAxisValueFromValue
            : endValue.horizontalAxisValueFromValue,
        horizontalLegendPosition: t < 0.5
            ? horizontalLegendPosition
            : endValue.horizontalLegendPosition,
        verticalLegendPosition:
            t < 0.5 ? verticalLegendPosition : endValue.verticalLegendPosition,
        gridColor:
            Color.lerp(gridColor, endValue.gridColor, t) ?? endValue.gridColor,
        dashArray: t < 0.5 ? dashArray : endValue.dashArray,
        gridWidth:
            lerpDouble(gridWidth, endValue.gridWidth, t) ?? endValue.gridWidth,
        verticalAxisStep:
            lerpDouble(verticalAxisStep, endValue.verticalAxisStep, t) ??
                endValue.verticalAxisStep,
        textScale:
            lerpDouble(textScale, endValue.textScale, t) ?? endValue.textScale,
        horizontalAxisStep:
            lerpDouble(horizontalAxisStep, endValue.horizontalAxisStep, t) ??
                endValue.horizontalAxisStep,
        verticalValuesPadding: EdgeInsets.lerp(
            verticalValuesPadding, endValue.verticalValuesPadding, t),
        horizontalValuesPadding: EdgeInsets.lerp(
            horizontalValuesPadding, endValue.horizontalValuesPadding, t),
        textStyle: TextStyle.lerp(textStyle, endValue.textStyle, t),
      );
    }

    return this;
  }
}
