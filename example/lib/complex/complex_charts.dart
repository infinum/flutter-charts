import 'package:example/charts/multi_bar_chart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

class ComplexCharts extends StatelessWidget {
  const ComplexCharts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Multi bar chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 100.0,
              child: AnimatedChart(
                duration: Duration(milliseconds: 550),
                state: ChartState<void>(
                  ChartData(
                    [
                      [10, 12, 13, 11, 16].map((e) => BarValue<void>(e.toDouble())).toList(),
                      [6, 8, 9, 7, 12].map((e) => BarValue<void>(e.toDouble())).toList(),
                      [2, 4, 5, 3, 8].map((e) => BarValue<void>(e.toDouble())).toList(),
                    ],
                    axisMax: 9.0,
                  ),
                  itemOptions: BarItemOptions(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                      color: Theme.of(context).accentColor,
                      maxBarWidth: 12.0,
                      colorForKey: (_, key) {
                        return [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.primaryVariant,
                        ][key];
                      }),
                  backgroundDecorations: [
                    GridDecoration(
                      verticalAxisStep: 1,
                      horizontalAxisStep: 4,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => MultiBarChartScreen()));
          },
        ),
        Divider(),
      ],
    );
  }
}
