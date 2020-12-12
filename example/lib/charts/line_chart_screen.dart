import 'dart:math';

import 'package:example/widgets/line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

class LineChartScreen extends StatefulWidget {
  LineChartScreen({Key key}) : super(key: key);

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final _values = <BarValue>[];
  double targetMax;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 15;

    targetMax = 3 + (_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25);
    _values.addAll(List.generate((_rand.nextDouble() * 16).toInt() + 6, (index) {
      return BarValue(2 + _rand.nextDouble() * _difference);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sparkline chart',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LineChart(
            data: _values,
            maxBarWidth: 2.0,
            height: MediaQuery.of(context).size.height * 0.6,
            dataToValue: (BarValue value) => value.max,
            itemColor: Theme.of(context).accentColor,
            targetOverColor: Theme.of(context).errorColor,
            backgroundDecorations: [
              GridDecoration(
                showVerticalGrid: false,
                valueAxisStep: 2.5,
                gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            _values.clear();
            _updateValues();
          });
        },
      ),
    );
  }
}
