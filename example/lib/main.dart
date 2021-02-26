import 'package:charts_painter/chart.dart';
import 'package:example/chart_types.dart';
import 'package:example/charts/bar_target_chart_screen.dart';
import 'package:example/complex/complex_charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'charts/line_chart_screen.dart';
import 'charts/scrollable_chart_screen.dart';

void main() {
  runApp(ChartDemo());
}

class ChartDemo extends StatefulWidget {
  ChartDemo({Key key}) : super(key: key);

  @override
  _ChartDemoState createState() => _ChartDemoState();
}

class _ChartDemoState extends State<ChartDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        accentColor: Color(0xFFd8262C),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: Color(0xFFd8262C),
              secondary: Color(0xFF353535),
              error: Colors.lightBlue,
            ),
        primaryColor: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Charts showcase'),
        ),
        body: ShowList(),
      ),
    );
  }
}

class ShowList extends StatelessWidget {
  ShowList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Chart types',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                ),
          ),
        ),
        Divider(),
        ChartTypes(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Chart Decorations',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                ),
          ),
        ),
        Divider(),
        ListTile(
          title: Text('Sparkline decoration'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 100.0,
              child: Chart(
                state: ChartState<void>(
                  ChartData.fromList(
                    [2, 7, 2, 4, 7, 6, 2, 5, 4]
                        .map((e) => BubbleValue<void>(e.toDouble()))
                        .toList(),
                    axisMax: 9,
                  ),
                  itemOptions: BubbleItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    color: Theme.of(context).accentColor,
                    maxBarWidth: 1.0,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      showVerticalGrid: false,
                      horizontalAxisStep: 3,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                    SparkLineDecoration(
                      lineWidth: 2.0,
                      lineColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => LineChartScreen()));
          },
        ),
        Divider(),
        ListTile(
          title: Text('Target line decoration'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 100.0,
              child: Chart(
                state: ChartState<void>(
                    ChartData.fromList(
                      [1, 3, 4, 2, 7, 6, 2, 5, 4]
                          .map((e) => BarValue<void>(e.toDouble()))
                          .toList(),
                      axisMax: 8,
                    ),
                    itemOptions: BarItemOptions(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      color: Theme.of(context).accentColor,
                      maxBarWidth: 4.0,
                    ),
                    backgroundDecorations: [
                      GridDecoration(
                        verticalAxisStep: 1,
                        horizontalAxisStep: 2,
                        gridColor: Theme.of(context).dividerColor,
                      ),
                    ],
                    foregroundDecorations: [
                      TargetLineDecoration(
                        target: 6,
                        colorOverTarget: Theme.of(context).colorScheme.error,
                        targetLineColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      BorderDecoration(
                        borderWidth: 1.5,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ]),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => BarTargetChartScreen()));
          },
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Chart Interactions',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                ),
          ),
        ),
        Divider(),
        ListTile(
          title: Text('Scrollable chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 100.0,
              child: Chart(
                state: ChartState<void>(
                  ChartData.fromList(
                    [1, 3, 4, 2, 7, 6, 2, 5, 4]
                        .map((e) => BarValue<void>(e.toDouble()))
                        .toList(),
                    axisMax: 8,
                  ),
                  itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                    color: Theme.of(context).accentColor,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      verticalAxisStep: 1,
                      horizontalAxisStep: 4,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                    SparkLineDecoration(
                      lineColor: Theme.of(context).accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => ScrollableChartScreen()));
          },
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Complex charts',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                ),
          ),
        ),
        Divider(),
        ComplexCharts(),
      ],
    );
  }
}
