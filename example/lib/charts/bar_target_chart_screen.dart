import 'dart:math';

import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

import '../widgets/bar_chart.dart';

class BarTargetChartScreen extends StatefulWidget {
  BarTargetChartScreen({Key key}) : super(key: key);

  @override
  _BarTargetChartScreenState createState() => _BarTargetChartScreenState();
}

class _BarTargetChartScreenState extends State<BarTargetChartScreen> {
  List<BarValue> _values = <BarValue>[];
  double targetMax;
  double targetMin;
  bool _showValues = false;
  bool _smoothPoints = false;
  bool _colorfulBars = false;
  bool _showLine = false;
  int minItems = 6;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 10;
    targetMax = 5 + ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25)).roundToDouble();
    _values.addAll(List.generate(minItems, (index) {
      return BarValue<void>(targetMax * 0.4 + _rand.nextDouble() * targetMax * 0.9);
    }));
    targetMin = targetMax - ((_rand.nextDouble() * 3) + (targetMax * 0.2));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return BarValue<void>(targetMax * 0.4 + Random().nextDouble() * targetMax * 0.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _targetDecoration = TargetLineDecoration(
      target: targetMax,
      colorOverTarget: Theme.of(context).colorScheme.error,
      targetLineColor: Theme.of(context).colorScheme.error,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target line decoration',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChart(
                data: _values,
                height: MediaQuery.of(context).size.height * 0.4,
                dataToValue: (BarValue value) => value.max,
                itemOptions: ChartItemOptions(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  minBarWidth: 4.0,
                  // isTargetInclusive: true,
                  color: Theme.of(context).colorScheme.primary,
                  radius: const BorderRadius.vertical(
                    top: Radius.circular(24.0),
                  ),
                  colorForValue: _targetDecoration.getTargetItemColor(),
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
                  GridDecoration(
                    showVerticalGrid: true,
                    showHorizontalValues: _showValues,
                    showVerticalValues: _showValues,
                    showTopHorizontalValue: _showValues,
                    valueAxisStep: 1,
                    itemAxisStep: 1,
                    textStyle: Theme.of(context).textTheme.caption,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                  _targetDecoration,
                ],
                foregroundDecorations: [
                  SparkLineDecoration<BarValue<dynamic>>(
                    lineWidth: 4.0,
                    lineColor: Theme.of(context).primaryColor.withOpacity(_showLine ? 1.0 : 0.0),
                    smoothPoints: _smoothPoints,
                  ),
                  TargetLineLegendDecoration(
                    legendDescription: 'Target line 👇',
                    legendTarget: targetMax,
                    legendStyle: Theme.of(context).textTheme.overline.copyWith(fontSize: 14),
                    padding: EdgeInsets.only(top: -7),
                  ),
                  BorderDecoration(
                    borderWidth: EdgeInsets.all(1.5),
                    color: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.4),
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
                  value: _colorfulBars,
                  title: 'Rainbow bar items',
                  onChanged: (value) {
                    setState(() {
                      _colorfulBars = value;
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
