import 'package:charts_painter/chart.dart';
import 'package:example/charts/multi_bar_chart_screen.dart';
import 'package:example/charts/multi_bar_widget_chart_screen.dart';
import 'package:flutter/material.dart';

class ComplexCharts extends StatelessWidget {
  const ComplexCharts({Key? key}) : super(key: key);

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
                  data: ChartData(
                    [
                      [10, 12, 13, 11, 16]
                          .map((e) => BarValue<void>(e.toDouble()))
                          .toList(),
                      [6, 8, 9, 7, 12]
                          .map((e) => BarValue<void>(e.toDouble()))
                          .toList(),
                      [2, 4, 5, 3, 8]
                          .map((e) => BarValue<void>(e.toDouble()))
                          .toList(),
                    ],
                    axisMax: 9.0,
                  ),
                  itemOptions: BarItemOptions(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      maxBarWidth: 12.0,
                      barItemBuilder: (data) {
                        return BarItem(
                            radius: BorderRadius.vertical(
                                top: Radius.circular(12.0)),
                            color: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context).colorScheme.primaryContainer,
                            ][data.listIndex]);
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
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => MultiBarChartScreen()));
          },
        ),
        Divider(),
        ListTile(
          title: Text('Multi bar widget chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 50.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  child: Image.asset('assets/png/futurama_small.png')),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => MultiBarWidgetChartScreen()));
          },
        ),
        Divider(),
      ],
    );
  }
}
