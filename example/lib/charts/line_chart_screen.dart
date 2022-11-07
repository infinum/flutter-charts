import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/line_chart.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/material.dart';

class LineChartScreen extends StatefulWidget {
  LineChartScreen({Key? key}) : super(key: key);

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  Map<int, List<BubbleValue>> _values = <int, List<BubbleValue>>{};
  double targetMax = 0;
  bool _showValues = false;
  bool _smoothPoints = false;
  bool _fillLine = false;
  bool _showLine = true;
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

    targetMax =
        3 + (_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25);
    _values.addAll(List.generate(3, (index) {
      List<BubbleValue<void>> _items = [];
      for (int i = 0; i < minItems; i++) {
        _items.add(BubbleValue<void>(2 + _rand.nextDouble() * _difference));
      }
      return _items;
    }).asMap());
  }

  void _addValues() {
    _values.addAll(List.generate(3, (index) {
      List<BubbleValue<void>> _items = [];
      for (int i = 0; i < minItems; i++) {
        _items.add(BubbleValue<void>(2 + Random().nextDouble() * targetMax));
      }
      return _items;
    }).asMap());
  }

  List<List<BubbleValue<void>>> _getMap() {
    return [
      _values[0]!.toList(),
      _values[1]!
          .asMap()
          .map<int, BubbleValue<void>>((index, e) {
            return MapEntry(index, e);
          })
          .values
          .toList(),
      _values[2]!
          .asMap()
          .map<int, BubbleValue<void>>((index, e) {
            return MapEntry(index, e);
          })
          .values
          .toList()
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              child: Stack(
                children: [
                  LineChart<void>.multiple(
                    _getMap(),
                    stack: _stack,
                    height: MediaQuery.of(context).size.height * 0.4,
                    itemColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(_showLine ? 1.0 : 0.0),
                    lineWidth: 2.0,
                    chartItemOptions: BubbleItemOptions(
                      maxBarWidth: _showLine ? 0.0 : 6.0,
                      bubbleItemBuilder: (data) => BubbleItem(
                          color: [
                        Colors.black,
                        Colors.red,
                        Colors.blue
                      ][data.listIndex]),
                    ),
                    smoothCurves: _smoothPoints,
                    backgroundDecorations: [
                      GridDecoration(
                        showVerticalGrid: false,
                        showTopHorizontalValue: _showValues,
                        showVerticalValues: _showValues,
                        showHorizontalValues: _showValues,
                        horizontalAxisStep: _stack ? 3 : 1,
                        textStyle: Theme.of(context).textTheme.caption,
                        gridColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.2),
                      ),
                      SparkLineDecoration(
                        id: 'first_line_fill',
                        smoothPoints: _smoothPoints,
                        fill: true,
                        lineColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(_fillLine
                                ? _stack
                                    ? 1.0
                                    : 0.2
                                : 0.0),
                        listIndex: 0,
                      ),
                      SparkLineDecoration(
                        id: 'second_line_fill',
                        smoothPoints: _smoothPoints,
                        fill: true,
                        lineColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(_fillLine
                                ? _stack
                                    ? 1.0
                                    : 0.2
                                : 0.0),
                        listIndex: 1,
                      ),
                      SparkLineDecoration(
                        id: 'third_line_fill',
                        smoothPoints: _smoothPoints,
                        fill: true,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: Colors.accents),
                        lineColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(_fillLine
                                ? _stack
                                    ? 1.0
                                    : 0.2
                                : 0.0),
                        listIndex: 2,
                      ),
                    ],
                    foregroundDecorations: [
                      SparkLineDecoration(
                        id: 'second_line',
                        lineWidth: 2.0,
                        smoothPoints: _smoothPoints,
                        lineColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(_showLine ? 1.0 : 0.0),
                        listIndex: 1,
                      ),
                      SparkLineDecoration(
                        id: 'third_line',
                        lineWidth: 2.0,
                        smoothPoints: _smoothPoints,
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: Colors.accents),
                        lineColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(_showLine ? 1.0 : 0.0),
                        listIndex: 2,
                      ),
                    ],
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
                  minItems += 4;
                  _addValues();
                });
              },
              onRemoveItems: () {
                setState(() {
                  if (minItems > 6) {
                    minItems -= 4;
                    _values = _values.map((key, value) {
                      return MapEntry(key,
                          value..removeRange(value.length - 4, value.length));
                    });
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
                ToggleItem(
                  title: 'Show lines',
                  value: _showLine,
                  onChanged: (value) {
                    setState(() {
                      _showLine = value;
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
