part of flutter_charts;

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart(
    this.data, {
    Key key,
    this.lineColor,
    this.gridColor,
    this.lineWidth = 1.0,
    this.horizontalAxisStep = 1,
    this.verticalAxisStep = 1,
    this.foregroundDecorations = const <DecorationPainter>[],
    this.backgroundDecorations = const <DecorationPainter>[],
    this.lineGradient,
    this.valueAxisOverMax = 3,
    this.axisMax,
    this.axisMin,
  }) : super(key: key);

  final List<double> data;

  final double lineWidth;
  final Color lineColor;
  final Gradient lineGradient;

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
            data.map((e) => BubbleValue<void>(e)).toList(),
            valueAxisMaxOver: valueAxisOverMax,
            axisMax: axisMax,
            axisMin: axisMin,
          ),
          itemOptions: BubbleItemOptions(maxBarWidth: 0.0),
          backgroundDecorations: [
            ...backgroundDecorations,
            GridDecoration(
              gridColor: gridColor ?? Theme.of(context).dividerColor,
              horizontalAxisStep: horizontalAxisStep,
              verticalAxisStep: verticalAxisStep,
            ),
          ],
          foregroundDecorations: [
            ...foregroundDecorations,
            SparkLineDecoration<void>(
              gradient: lineGradient,
              lineWidth: lineWidth,
              lineColor: lineColor ?? Theme.of(context).accentColor,
            ),
          ]),
    );
  }
}
