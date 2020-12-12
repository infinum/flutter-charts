import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

import '../widgets/bar_chart.dart';

class BarChartScreen extends StatefulWidget {
  BarChartScreen({Key key}) : super(key: key);

  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final _values = <BarValue>[];
  double targetMax;
  int minItems = 6;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 15;

    targetMax = 3 + ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25)).roundToDouble();
    _values.addAll(List.generate(minItems, (index) {
      return BarValue(2 + _rand.nextDouble() * _difference);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar chart',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BarChart(
            data: _values,
            height: MediaQuery.of(context).size.height * 0.6,
            dataToValue: (BarValue value) => value.max,
            itemOptions: ChartItemOptions(
              itemPainter: barItemPainter,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              targetMax: targetMax + 2,
              targetMin: targetMax,
              minBarWidth: 6.0,
              // isTargetInclusive: true,
              color: Theme.of(context).colorScheme.error,
              targetOverColor: Theme.of(context).accentColor,
              radius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
            ),
            chartOptions: ChartOptions(
              valueAxisMax: max(
                  _values.fold<double>(
                          0,
                          (double previousValue, BarValue element) =>
                              previousValue = max(previousValue, element?.max ?? 0)) +
                      1,
                  targetMax + 3),
            ),
            backgroundDecorations: [
              HorizontalAxisDecoration(
                gridWidth: 2.0,
                valueAxisStep: 2,
              ),
              VerticalAxisDecoration(
                gridWidth: 2.0,
                itemAxisStep: 3,
              ),
              GridDecoration(
                showVerticalGrid: true,
                valueAxisStep: 0.5,
                itemAxisStep: 1,
                gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
              ),
              TargetAreaDecoration(
                targetAreaFillColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
                targetColor: Theme.of(context).colorScheme.error,
                targetAreaRadius: BorderRadius.circular(12.0),
              ),
            ],
            foregroundDecorations: [
              SparkLineDecoration(
                lineWidth: 6.0,
                lineColor: Theme.of(context).colorScheme.secondaryVariant,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            heroTag: 'refresh_sharp',
            child: Icon(Icons.refresh_sharp),
            onPressed: () {
              setState(() {
                _values.clear();
                _updateValues();
              });
            },
          ),
          FloatingActionButton(
            heroTag: 'add',
            child: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _values.clear();
                minItems += 4;
                _updateValues();
              });
            },
          ),
          FloatingActionButton(
            heroTag: 'remove',
            child: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _values.clear();
                minItems -= 4;
                _updateValues();
              });
            },
          ),
        ],
      ),
    );
  }
}
