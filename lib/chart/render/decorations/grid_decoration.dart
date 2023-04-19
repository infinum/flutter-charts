part of charts_painter;

/// Draws a grid with [verticalAxisStep] and [horizontalAxisStep] as spacers
///
/// That will allow for Legend to be inserted as well.
class GridDecoration extends DecorationPainter {
  /// Make grid decoration for the chart
  ///
  /// Grid decoration is just merge of [HorizontalAxisDecoration] and [VerticalAxisDecoration]
  GridDecoration({
    bool showHorizontalValues = false,
    bool showVerticalValues = false,
    bool endWithChartHorizontal = false,
    bool endWithChartVertical = false,
    TextAlign horizontalTextAlign = TextAlign.end,
    bool showTopHorizontalValue = false,
    TextAlign verticalTextAlign = TextAlign.center,
    bool showVerticalGrid = true,
    bool showHorizontalGrid = true,
    EdgeInsets? verticalValuesPadding,
    EdgeInsets? horizontalValuesPadding,
    String? horizontalAxisUnit,
    AxisValueFromValue verticalAxisValueFromIndex = defaultAxisValue,
    AxisValueFromValue horizontalAxisValueFromValue = defaultAxisValue,
    Color gridColor = Colors.grey,
    double gridWidth = 1.0,
    List<double>? dashArray,
    double verticalAxisStep = 1.0,
    double horizontalAxisStep = 1.0,
    double textScale = 1.0,
    HorizontalLegendPosition horizontalLegendPosition =
        HorizontalLegendPosition.end,
    VerticalLegendPosition verticalLegendPosition =
        VerticalLegendPosition.bottom,
    ShowLineForValue? showHorizontalLineForValue,
    TextStyle? textStyle,
  }) : assert(
            textStyle != null ||
                !(showHorizontalValues ||
                    showTopHorizontalValue ||
                    showVerticalValues),
            'Need to provide text style for values to be visible!') {
    _horizontalAxisDecoration = HorizontalAxisDecoration(
      showValues: showHorizontalValues,
      endWithChart: endWithChartHorizontal,
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
      endWithChart: endWithChartVertical,
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
    required HorizontalAxisDecoration horizontalAxisDecoration,
    required VerticalAxisDecoration verticalAxisDecoration,
  })  : _horizontalAxisDecoration = horizontalAxisDecoration,
        _verticalAxisDecoration = verticalAxisDecoration;

  late HorizontalAxisDecoration _horizontalAxisDecoration;
  late VerticalAxisDecoration _verticalAxisDecoration;

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    _horizontalAxisDecoration.draw(canvas, size, state);
    _verticalAxisDecoration.draw(canvas, size, state);
  }

  @override
  Size layoutSize(BoxConstraints constraints, ChartState state) {
    return constraints
        .deflate(state.defaultMargin +
            state.defaultPadding.copyWith(
              left: _horizontalAxisDecoration._endWithChart *
                  state.defaultPadding.left,
              right: _horizontalAxisDecoration._endWithChart *
                  state.defaultPadding.right,
              top: _verticalAxisDecoration._endWithChart *
                  state.defaultPadding.top,
              bottom: _verticalAxisDecoration._endWithChart *
                  state.defaultPadding.bottom,
            ))
        .biggest;
  }

  @override
  Offset applyPaintTransform(ChartState state, Size size) {
    return Offset(
        state.defaultMargin.left +
            (_horizontalAxisDecoration._endWithChart *
                state.defaultPadding.left),
        state.defaultMargin.top +
            (_verticalAxisDecoration._endWithChart * state.defaultPadding.top));
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
        horizontalAxisDecoration: _horizontalAxisDecoration.animateTo(
            endValue._horizontalAxisDecoration, t),
        verticalAxisDecoration: _verticalAxisDecoration.animateTo(
            endValue._verticalAxisDecoration, t),
      );
    }

    return this;
  }
}
