part of flutter_charts;

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart(
    this.data, {
    Key key,
    this.itemColor,
    this.gridColor,
    this.horizontalAxisStep = 1,
    this.verticalAxisStep = 1,
    this.foregroundDecorations = const <DecorationPainter>[],
    this.backgroundDecorations = const <DecorationPainter>[],
    this.valueAxisOverMax = 3,
    this.axisMax,
    this.axisMin,
    this.itemRadius,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 4.0),
    this.maxItemWidth,
    this.minItemWidth,
  }) : super(key: key);

  final List<double> data;

  final BorderRadius itemRadius;
  final Color itemColor;
  final EdgeInsets itemPadding;

  final double maxItemWidth;
  final double minItemWidth;

  final Color gridColor;
  final double horizontalAxisStep;
  final double verticalAxisStep;

  final double axisMin;
  final double axisMax;
  final double valueAxisOverMax;

  final List<DecorationPainter> foregroundDecorations;
  final List<DecorationPainter> backgroundDecorations;

  @override
  Widget build(BuildContext context) {
    return Chart<void>(
      state: ChartState<void>(
        ChartData.fromList(
          data.map((e) => BarValue<void>(e)).toList(),
          valueAxisMaxOver: valueAxisOverMax,
          axisMax: axisMax,
          axisMin: axisMin,
        ),
        itemOptions: BarItemOptions(
          color: itemColor ?? Theme.of(context).accentColor,
          radius: itemRadius,
          padding: itemPadding,
          maxBarWidth: maxItemWidth,
          minBarWidth: minItemWidth,
        ),
        backgroundDecorations: [
          ...backgroundDecorations,
          GridDecoration(
            gridColor: gridColor ?? Theme.of(context).dividerColor,
            horizontalAxisStep: horizontalAxisStep,
            verticalAxisStep: verticalAxisStep,
          ),
        ],
        foregroundDecorations: foregroundDecorations,
      ),
    );
  }
}
