import 'package:charts_painter/chart.dart';
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
  ChartTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final byCount = [5, 6, 4, 8, 6, 4, 1, 2, 3, 7, 9, 4, 2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 128.0),
      child: Chart<void>(
        state: ChartState(
          data: ChartData(
            [
              byCount.map((e) => ChartItem<void>(e.toDouble())).toList(),
              // byCount.map((e) => BarValue<void>(e.toDouble())).toList()
            ],
          ),
          itemOptions: BarItemOptions(),
          // itemOptions: BarItemOptions(
          //   padding: const EdgeInsets.symmetric(horizontal: 2),
          //   color: Colors.blue,
          // ),
          backgroundDecorations: [
            GridDecoration(
              showHorizontalGrid: false,
              showVerticalGrid: false,
              showVerticalValues: true,
              verticalLegendPosition: VerticalLegendPosition.top,
              verticalAxisValueFromIndex: (idx) => '${idx + 1}',
              gridWidth: 2,
              textStyle: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
          // foregroundDecorations: [
          //   HorizontalAxisDecoration(lineColor: Colors.brown),
          // ],
        ),
      ),
    );
  }
}
