import 'dart:math';

import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

import '../widgets/bar_chart.dart';

class ScrollableChartScreen extends StatefulWidget {
  ScrollableChartScreen({Key key}) : super(key: key);

  @override
  _ScrollableChartScreenState createState() => _ScrollableChartScreenState();
}

class _ScrollableChartScreenState extends State<ScrollableChartScreen> {
  List<BarValue> _values = <BarValue>[];
  double targetMax;
  bool _showValues = false;
  bool _smoothPoints = false;
  bool _showBars = true;
  bool _showLine = false;
  bool _isScrollable = true;
  int minItems = 30;
  int _selected;

  final _controller = ScrollController();

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
          'Scrollable chart',
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            physics: _isScrollable ? ScrollPhysics() : NeverScrollableScrollPhysics(),
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChart(
                data: _values,
                height: MediaQuery.of(context).size.height * 0.4,
                dataToValue: (BarValue value) => value.max,
                itemOptions: ChartItemOptions(
                  itemPainter: barItemPainter,
                  padding: EdgeInsets.symmetric(horizontal: _isScrollable ? 12.0 : 2.0),
                  targetMax: targetMax + 2,
                  targetMin: targetMax,
                  minBarWidth: _isScrollable ? 36.0 : 4.0,
                  // isTargetInclusive: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(_showBars ? 1.0 : 0.0),
                  targetOverColor: Theme.of(context).colorScheme.error.withOpacity(_showBars ? 1.0 : 0.0),
                  radius: const BorderRadius.vertical(
                    top: Radius.circular(24.0),
                  ),
                ),
                chartBehaviour: ChartBehaviour(
                  isScrollable: _isScrollable,
                  onItemClicked: (item) {
                    setState(() {
                      _selected = item;
                    });
                  },
                ),
                chartOptions: ChartOptions(
                  valueAxisMax: max(
                      _values.fold<double>(
                              0,
                              (double previousValue, BarValue element) =>
                                  previousValue = max(previousValue, element?.max ?? 0)) +
                          1,
                      targetMax + 3),
                  padding: _showValues ? EdgeInsets.only(right: 12.0) : null,
                ),
                backgroundDecorations: [
                  HorizontalAxisDecoration(
                    endWithChart: false,
                    gridWidth: 2.0,
                    valueAxisStep: 2,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                  VerticalAxisDecoration(
                    endWithChart: false,
                    gridWidth: 2.0,
                    itemAxisStep: 3,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.8),
                  ),
                  GridDecoration(
                    endWithChart: false,
                    showVerticalGrid: true,
                    showHorizontalValues: _showValues,
                    showVerticalValues: _showValues,
                    valueAxisStep: 1,
                    itemAxisStep: 1,
                    textStyle: Theme.of(context).textTheme.caption,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                  TargetAreaDecoration(
                    targetAreaFillColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
                    targetColor: Theme.of(context).colorScheme.error,
                    targetAreaRadius: BorderRadius.circular(12.0),
                  ),
                  SparkLineDecoration(
                    fill: true,
                    lineColor: Theme.of(context).primaryColor.withOpacity(_showLine ? 0.2 : 0.0),
                    smoothPoints: _smoothPoints,
                  ),
                ],
                foregroundDecorations: [
                  SparkLineDecoration(
                    lineWidth: 2.0,
                    lineColor: Theme.of(context).primaryColor.withOpacity(_showLine ? 1.0 : 0.0),
                    smoothPoints: _smoothPoints,
                  ),
                  CupertinoSelectedPainter(
                    _selected,
                    textSize: 28.0,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(_isScrollable ? 0.5 : 0.8),
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
                  value: _showBars,
                  title: 'Show bar items',
                  onChanged: (value) {
                    setState(() {
                      _showBars = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _showLine,
                  title: 'Show line decoration',
                  onChanged: (value) {
                    setState(() {
                      _showLine = value;
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
                  value: _isScrollable,
                  title: 'Scrollable',
                  onChanged: (value) {
                    setState(() {
                      _isScrollable = value;
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
