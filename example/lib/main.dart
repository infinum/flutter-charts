import 'package:example/chart_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

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
        accentColor: Colors.redAccent,
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: Colors.redAccent,
              error: Colors.grey,
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
            'Decorations',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                ),
          ),
        ),
        Divider(),
        ListTile(
          title: Text('Sparkline chart decoration'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 80.0,
              child: Chart(
                state: ChartState(
                  [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue(e.toDouble())).toList().asMap(),
                  itemOptions: ChartItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    radius: BorderRadius.all(Radius.circular(12.0)),
                    color: Theme.of(context).accentColor,
                    maxBarWidth: 1.0,
                    itemPainter: bubbleItemPainter,
                  ),
                  options: ChartOptions(
                    valueAxisMax: 9,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      itemAxisStep: 9,
                      valueAxisStep: 9,
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
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => LineChartScreen()));
          },
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Interactions (WIP)',
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
              width: 80.0,
              child: Chart(
                state: ChartState(
                  [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue(e.toDouble())).toList().asMap(),
                  itemOptions: ChartItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                    color: Theme.of(context).accentColor,
                  ),
                  options: ChartOptions(
                    valueAxisMax: 9,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      itemAxisStep: 9,
                      valueAxisStep: 9,
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
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => ScrollableChartScreen()));
          },
        ),
        Divider(),
      ],
    );
  }
}
