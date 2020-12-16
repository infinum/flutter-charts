import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  int minItems = 6;
  int _selected;

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
    final _controller = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar chart',
        ),
      ),
      body: Column(
        children: [
          ScrollableChart(
            controller: _controller,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChart(
                data: _values,
                height: MediaQuery.of(context).size.height * 0.5,
                dataToValue: (BarValue value) => value.max,
                itemOptions: ChartItemOptions(
                  itemPainter: barItemPainter,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  targetMax: targetMax + 2,
                  targetMin: targetMax,
                  minBarWidth: 42.0,
                  // isTargetInclusive: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(_showBars ? 1.0 : 0.0),
                  targetOverColor: Theme.of(context).colorScheme.error.withOpacity(_showBars ? 1.0 : 0.0),
                  radius: const BorderRadius.vertical(
                    top: Radius.circular(24.0),
                  ),
                ),
                chartBehaviour: ChartBehaviour(
                  isScrollable: _isScrollable,
                  scrollController: _controller,
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
                    gridWidth: 2.0,
                    valueAxisStep: 2,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                  VerticalAxisDecoration(
                    gridWidth: 2.0,
                    itemAxisStep: 3,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                  GridDecoration(
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
                  CupertinoSelectedPainter(
                    _selected,
                  ),
                ],
                foregroundDecorations: [
                  SparkLineDecoration(
                    lineWidth: 8.0,
                    lineColor: Theme.of(context).primaryColor.withOpacity(_showLine ? 1.0 : 0.0),
                    smoothPoints: _smoothPoints,
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
              children: [
                ListTile(
                  leading: Icon(timeDilation == 10 ? Icons.play_arrow : Icons.slow_motion_video),
                  title: Text(timeDilation == 10 ? 'Faster animations' : 'Slower animations'),
                  onTap: () {
                    setState(() {
                      timeDilation = timeDilation == 10 ? 1 : 10;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh dataset'),
                  onTap: () {
                    setState(() {
                      _values.clear();
                      _updateValues();
                    });
                  },
                ),
                ListTile(
                  leading: Icon(_showValues ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  title: Text('Show axis values'),
                  onTap: () {
                    setState(() {
                      _showValues = !_showValues;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(_showBars ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  title: Text('Show bar items'),
                  onTap: () {
                    setState(() {
                      _showBars = !_showBars;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(_showLine ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  title: Text('Show line decoration'),
                  onTap: () {
                    setState(() {
                      _showLine = !_showLine;
                    });
                  },
                ),
                ListTile(
                  enabled: _showLine,
                  leading: Icon(_smoothPoints ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  title: Text('Smooth line curve'),
                  onTap: () {
                    setState(() {
                      _smoothPoints = !_smoothPoints;
                    });
                  },
                ),
                ListTile(
                  subtitle: Text('WIP: Breaks chart!'),
                  leading: Icon(_isScrollable ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  title: Text('Scrollable'),
                  onTap: () {
                    setState(() {
                      _isScrollable = !_isScrollable;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add data'),
                  onTap: () {
                    setState(() {
                      minItems += 4;
                      _addValues();
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove),
                  title: Text('Remove data'),
                  onTap: () {
                    setState(() {
                      minItems -= 4;
                      _values.removeRange(_values.length - 4, _values.length);
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
