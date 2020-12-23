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
  bool _fillLine = false;
  bool _stack = true;
  int minItems = 15;

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
      return BarValue<void>(2 + _rand.nextDouble() * _difference);
    }));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return BarValue<void>(2 + Random().nextDouble() * targetMax);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _firstItems = _values.where((element) => _values.indexOf(element) % 3 == 0).toList();

    final _secondItems = _stack
        ? _values.where((element) => _values.indexOf(element) % 3 == 1).map((element) {
            final _index = _values.indexOf(element) ~/ 3;
            return BarValue<void>(element.max + _firstItems[_index].max);
          }).toList()
        : _values.where((element) => _values.indexOf(element) % 3 == 1).toList();

    final _thirdItems = _stack
        ? _values.where((element) => _values.indexOf(element) % 3 == 2).map((element) {
            final _index = _values.indexOf(element) ~/ 3;
            return BarValue<void>(element.max + _secondItems[_index].max);
          }).toList()
        : _values.where((element) => _values.indexOf(element) % 3 == 2).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multi sparkline decoration',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LineChart(
                data: _values.where((element) => _values.indexOf(element) % 3 == 0).toList(),
                height: MediaQuery.of(context).size.height * 0.4,
                dataToValue: (BarValue value) => value.max,
                itemColor: Theme.of(context).accentColor,
                lineWidth: 2.0,
                chartItemOptions: ChartItemOptions(
                  maxBarWidth: 4.0,
                  color: Theme.of(context).accentColor.withOpacity(0.4),
                ),
                chartOptions: ChartOptions(
                  valueAxisMax: max(
                      (_stack ? _thirdItems : _values).fold<double>(
                              0,
                              (double previousValue, BarValue element) =>
                                  previousValue = max(previousValue, element?.max ?? 0)) +
                          1,
                      targetMax + 3),
                ),
                smoothCurves: _smoothPoints,
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: false,
                    showTopHorizontalValue: _showValues,
                    showVerticalValues: _showValues,
                    showHorizontalValues: _showValues,
                    valueAxisStep: _stack ? 3 : 1,
                    textStyle: Theme.of(context).textTheme.caption,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                  SparkLineDecoration(
                    id: 'third_line_fill',
                    smoothPoints: _smoothPoints,
                    fill: true,
                    lineColor: Theme.of(context).colorScheme.secondary.withOpacity(_fillLine
                        ? _stack
                            ? 1.0
                            : 0.2
                        : 0.0),
                    items: _thirdItems,
                  ),
                  SparkLineDecoration(
                    id: 'second_line_fill',
                    smoothPoints: _smoothPoints,
                    fill: true,
                    gradient:
                        LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: Colors.accents),
                    lineColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(_fillLine
                        ? _stack
                            ? 1.0
                            : 0.4
                        : 0.0),
                    items: _secondItems,
                  ),
                  SparkLineDecoration(
                    id: 'first_line_fill',
                    smoothPoints: _smoothPoints,
                    fill: true,
                    lineColor: Theme.of(context).accentColor.withOpacity(_fillLine
                        ? _stack
                            ? 1.0
                            : 0.2
                        : 0.0),
                    items: _firstItems,
                  ),
                ],
                foregroundDecorations: [
                  SparkLineDecoration(
                    id: 'third_line',
                    lineWidth: 4.0,
                    smoothPoints: _smoothPoints,
                    lineColor: Theme.of(context).colorScheme.secondary,
                    items: _thirdItems,
                  ),
                  SparkLineDecoration(
                    id: 'second_line',
                    lineWidth: 4.0,
                    gradient:
                        LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: Colors.accents),
                    smoothPoints: _smoothPoints,
                    lineColor: Theme.of(context).colorScheme.primaryVariant,
                    items: _secondItems,
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
                  minItems += 12;
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
                ToggleItem(
                  value: _fillLine,
                  title: 'Fill',
                  onChanged: (value) {
                    setState(() {
                      _fillLine = value;
                    });
                  },
                ),
                ToggleItem(
                  title: 'Stack lines',
                  value: _stack,
                  onChanged: (value) {
                    setState(() {
                      _stack = value;
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
