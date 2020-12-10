import 'dart:math';

import 'package:example/charts/bubble_chart_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

import 'charts/bar_chart_screen.dart';
import 'charts/candle_chart_screen.dart';

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
        ListTile(
          title: Text('Bar chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 80.0,
              child: Chart(
                state: ChartState(
                  [1, 3, 4, 2, 3, 6].map((e) => BarValue(e.toDouble())).toList(),
                  itemOptions: ChartItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                    color: Theme.of(context).accentColor,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      itemAxisStep: 1,
                      valueAxisStep: 3,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => BarChartScreen()));
          },
        ),
        Divider(),
        ListTile(
          title: Text('Bubble chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 80.0,
              child: Chart(
                state: ChartState(
                  [1, 3, 4, 2, 3, 6, 2, 1, 4].map((e) => BubbleValue(e.toDouble())).toList(),
                  itemOptions: ChartItemOptions(
                    color: Theme.of(context).accentColor,
                    itemPainter: bubbleItemPainter,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      itemAxisStep: 3,
                      valueAxisStep: 2,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => BubbleChartScreen()));
          },
        ),
        Divider(),
        ListTile(
          title: Text('Candle chart'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 80.0,
              child: Chart(
                state: ChartState(
                  [1, 3, 4, 2, 3, 6].map((e) => CandleValue(e + 2 + Random().nextDouble() * 4, e.toDouble())).toList(),
                  options: ChartOptions(
                    valueAxisMax: 12,
                  ),
                  itemOptions: ChartItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    radius: BorderRadius.all(Radius.circular(12.0)),
                    color: Theme.of(context).accentColor,
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      itemAxisStep: 1,
                      valueAxisStep: 3,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => CandleChartScreen()));
          },
        ),
        Divider(),
      ],
    );
  }
}
