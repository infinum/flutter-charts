import 'dart:math';

import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/line_chart.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

class LineChartScreen extends StatefulWidget {
  LineChartScreen({Key key}) : super(key: key);

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  List<BarValue> _values = <BarValue>[];
  double targetMax;
  bool _showValues = false;
  bool _smoothPoints = false;
  int minItems = 10;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = 2 + (_rand.nextDouble() * 15);

    targetMax = 3 + (_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25);
    _values.addAll(List.generate(minItems, (index) {
      return BarValue(2 + _rand.nextDouble() * _difference);
    }));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return BarValue(2 + Random().nextDouble() * targetMax);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sparkline chart',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Stack(
                children: [
                  LineChart(
                    data: _values.where((element) => _values.indexOf(element) % 2 == 0).toList(),
                    height: MediaQuery.of(context).size.height * 0.4,
                    dataToValue: (BarValue value) => value.max,
                    itemColor: Theme.of(context).accentColor,
                    lineWidth: 2.0,
                    chartItemOptions: ChartItemOptions(
                      maxBarWidth: 4.0,
                      color: Theme.of(context).accentColor.withOpacity(0.4),
                      itemPainter: bubbleItemPainter,
                    ),
                    smoothCurves: _smoothPoints,
                    backgroundDecorations: [
                      GridDecoration(
                        showVerticalGrid: false,
                        showTopHorizontalValue: _showValues,
                        showVerticalValues: _showValues,
                        showHorizontalValues: _showValues,
                        valueAxisStep: 1,
                        textStyle: Theme.of(context).textTheme.caption,
                        gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                      ),
                    ],
                    foregroundDecorations: [
                      // SparkLineDecoration(
                      //   lineWidth: 10.0,
                      //   items: _values.where((element) => _values.indexOf(element) % 2 == 1).toList(),
                      // )
                    ],
                  ),
                  LineChart(
                    lineWidth: 0.5,
                    data: _values.where((element) => _values.indexOf(element) % 2 == 1).toList(),
                    height: MediaQuery.of(context).size.height * 0.4,
                    dataToValue: (BarValue value) => value.max,
                    itemColor: Theme.of(context).colorScheme.primaryVariant,
                    smoothCurves: _smoothPoints,
                    chartItemOptions: ChartItemOptions(
                      maxBarWidth: 4.0,
                      itemPainter: bubbleItemPainter,
                      color: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: ChartOptionsWidget(
              onRefresh: () {
                setState(() {
                  _values.clear();
                  _updateValues();
                });
              },
              onAddItems: () {
                setState(() {
                  minItems += 8;
                  _addValues();
                });
              },
              onRemoveItems: () {
                setState(() {
                  if (_values.length > 4) {
                    minItems -= 4;
                    _values.removeRange(_values.length - 4, _values.length);
                  }
                });
              },
              toggleItems: [
                ToggleItem(
                  title: 'Axis values',
                  value: _showValues,
                  onChanged: (value) {
                    setState(() {
                      _showValues = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _smoothPoints,
                  title: 'Smooth line curve',
                  onChanged: (value) {
                    setState(() {
                      _smoothPoints = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
