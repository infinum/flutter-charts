part of flutter_charts;

/// Tester for charts, this is for [WidgetBook] to show different king od charts and how to use them.
class ChartTester extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _chartSize = Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.3);
    final _chartPadding = Column(
      children: const [
        SizedBox(height: 12.0),
        Divider(
          thickness: 2.0,
          color: Colors.black,
        ),
        SizedBox(height: 12.0),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _chartPadding,
          Text(
            'Candle chart',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 12.0),
          AnimatedChart(
            height: MediaQuery.of(context).size.height * 0.3 + _chartSize.height,
            duration: Duration(milliseconds: 800),
            state: ChartState(
              [
                CandleValue(140, 100),
                CandleValue(131, 85),
                CandleValue(135, 95),
                CandleValue(115, 82),
                CandleValue(138, 98),
                CandleValue(130, 90),
                CandleValue(133, 94),
              ],
              options: const ChartOptions(
                valueAxisMin: 70,
                valueAxisMax: 150,
                padding: EdgeInsets.only(right: 8.0),
              ),
              itemOptions: ChartItemOptions(
                showValue: true,
                valueColor: Theme.of(context).colorScheme.onPrimary,
                valueColorOver: Theme.of(context).colorScheme.onError,
                targetMin: 90,
                targetMax: 140,
                targetOverColor: Theme.of(context).colorScheme.error,
                color: Theme.of(context).accentColor,
                radius: const BorderRadius.all(Radius.circular(36.0)),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
              backgroundDecorations: [
                GridDecoration(
                  showHorizontalValues: true,
                  showVerticalValues: true,
                  endWithChart: true,
                  itemAxisStep: 1,
                  valueAxisStep: 10,
                ),
              ],
            ),
          ),
          _chartPadding,
          Text(
            'Bubble chart',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 12.0),
          AnimatedChart(
            height: _chartSize.height,
            duration: Duration(milliseconds: 800),
            state: ChartState(
              [
                BubbleValue(111),
                BubbleValue(109),
                BubbleValue(109),
                BubbleValue(114),
                BubbleValue(112),
                BubbleValue(107),
                BubbleValue(113),
              ],
              itemOptions: ChartItemOptions(
                targetOverColor: Colors.red,
                showValue: true,
                targetMin: 108,
                targetMax: 114,
                valueColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                valueColorOver: Colors.white,
                color: Colors.white,
                radius: const BorderRadius.all(Radius.circular(12.0)),
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemPainter: bubbleItemPainter,
              ),
              options: const ChartOptions(
                valueAxisMin: 100,
                valueAxisMax: 115,
              ),
              backgroundDecorations: [
                GridDecoration(
                  showHorizontalValues: true,
                  showTopHorizontalValue: true,
                  showVerticalValues: true,
                  showVerticalGrid: false,
                  gridColor: Colors.grey.shade300,
                  gridWidth: 2.0,
                  valueAxisStep: 5,
                ),
                TargetAreaDecoration(
                  lineWidth: 2.0,
                  dashArray: [15, 10],
                  targetColor: Colors.black,
                  targetAreaRadius: BorderRadius.circular(12.0),
                  targetAreaFillColor: Colors.green.shade300.withOpacity(0.8),
                ),
              ],
            ),
          ),
          _chartPadding,
          Text(
            'Bar chart with area limit',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 12.0),
          AnimatedChart(
            height: _chartSize.height,
            duration: Duration(milliseconds: 800),
            state: ChartState(
              [
                BarValue(27),
                BarValue(25),
                BarValue(19),
                BarValue(28),
                BarValue(22),
                BarValue(24),
                BarValue(29),
              ],
              options: const ChartOptions(
                valueAxisMax: 30.0,
                valueAxisMin: 10.0,
                axisLegendTextColor: Color(0xFF1C2548),
              ),
              itemOptions: ChartItemOptions(
                color: Theme.of(context).accentColor,
                targetOverColor: Theme.of(context).errorColor,
                maxBarWidth: 12.0,
                targetMax: 26,
                targetMin: 20,
                radius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              backgroundDecorations: [
                TargetAreaDecoration(
                  dashArray: [8, 8],
                  lineWidth: 1.6,
                  targetAreaFillColor: Colors.yellow.withOpacity(0.4),
                  targetColor: const Color(0xFF3242AA).withOpacity(0.7),
                  targetAreaRadius: BorderRadius.circular(12.0),
                ),
                GridDecoration(
                  showHorizontalValues: true,
                  showTopHorizontalValue: true,
                  showVerticalGrid: false,
                  showVerticalValues: true,
                  horizontalAxisUnit: 'mg',
                  gridColor: const Color(0xFF3242AA).withOpacity(0.2),
                  valueAxisStep: 5.0,
                ),
              ],
            ),
          ),
          _chartPadding,
          Text(
            'Mixed chart',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 12.0),
          AnimatedChart(
            duration: Duration(milliseconds: 800),
            height: _chartSize.height,
            state: ChartState(
              [
                BarValue(20),
                BarValue(30),
                BarValue(3),
                BarValue(17),
                BubbleValue(20),
                CandleValue(25, 12),
                CandleValue(28, 15),
                BubbleValue(20),
              ],
              options: const ChartOptions(),
              itemOptions: const ChartItemOptions(
                targetOverColor: Colors.blueAccent,
                targetMin: 10,
                targetMax: 26,
                color: Colors.lightBlueAccent,
                radius: BorderRadius.all(Radius.circular(36.0)),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              backgroundDecorations: [
                GridDecoration(
                  showHorizontalValues: true,
                  endWithChart: true,
                  valueAxisStep: 5,
                ),
                TargetAreaDecoration(
                  targetAreaFillColor: Colors.lightBlue.withOpacity(0.2),
                  targetColor: Colors.lightBlue,
                  targetAreaRadius: BorderRadius.circular(32.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
