import 'package:charts_painter/chart.dart' as chart;
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.white,
      body: ChartTest(),
    ),
  ));
}

class ChartTest extends StatelessWidget {
  ChartTest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final byCount = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    return chart.Chart(
      state: chart.ChartState.bar(
        chart.ChartData.fromList(
          byCount.map((e) => chart.BarValue(e.toDouble())).toList(),
        ),
        backgroundDecorations: [
          chart.GridDecoration(
            showHorizontalGrid: false,
            showVerticalGrid: false,
            showVerticalValues: true,
            verticalAxisValueFromIndex: (idx) => '${idx + 1}',
            gridWidth: 2,
            textStyle: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(fontSize: 8, fontWeight: FontWeight.bold),
            gridColor: Theme.of(context).dividerColor,
          ),
          chart.ValueDecoration(
            alignment: Alignment.topCenter,
            hideZeroValues: true,
            // valueGenerator: (_),
            textStyle:
                Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 8),
          ),
        ],
        // foregroundDecorations: [
        //   chart.HorizontalAxisDecoration(lineColor: Colors.brown),
        // ],
      ),
    );
  }
}
