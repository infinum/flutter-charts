import 'package:charts_painter/chart.dart';
import 'package:example/charts/ios_charts_screen.dart';
import 'package:flutter/material.dart';

class IosCharts extends StatelessWidget {
  const IosCharts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Apple battery chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 100.0,
              child: Chart(
                state: ChartState<void>(
                  data: ChartData.fromList(
                    [1, 3, 4, 2, 7, 7, 7, 7, 4, 5, 7, 8, 9, 4]
                        .map((e) => ChartItem<void>(e.toDouble()))
                        .toList(),
                    axisMax: 9,
                  ),
                  itemOptions: BarItemOptions(
                    barItemBuilder: (_) => BarItem(
                      radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    maxBarWidth: 8.0,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      verticalAxisStep: 1,
                      horizontalAxisStep: 1.5,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => IosChartScreen()));
          },
        ),
        Divider(),
      ],
    );
  }
}
