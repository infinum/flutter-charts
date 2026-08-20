import 'dart:math';
import 'package:example/widgets/widget_decorations.dart';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/material.dart';

import '../widgets/bar_chart.dart';

class BarTargetChartScreen extends StatefulWidget {
  BarTargetChartScreen({Key? key}) : super(key: key);

  @override
  _BarTargetChartScreenState createState() => _BarTargetChartScreenState();
}

class _BarTargetChartScreenState extends State<BarTargetChartScreen> {
  List<ChartItem> _values = <ChartItem>[];
  double targetMax = 0;
  double targetMin = 0;
  bool _showValues = false;
  bool _smoothPoints = false;
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
    targetMax = 5 +
        ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25))
            .roundToDouble();
    _values.addAll(List.generate(minItems, (index) {
      return ChartItem<void>(
          targetMax * 0.4 + _rand.nextDouble() * targetMax * 0.9);
    }));
    targetMin = targetMax - ((_rand.nextDouble() * 3) + (targetMax * 0.2));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return ChartItem<void>(
          targetMax * 0.4 + Random().nextDouble() * targetMax * 0.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _targetDecoration = targetLineDecoration(
      target: targetMax,
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
                dataToValue: (ChartItem value) => value.max ?? 0,
                itemOptions: BarItemOptions(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  minBarWidth: 4.0,
                  barItemBuilder: (data) {
                    return BarItem(
                      color: colorForTarget(
                        Theme.of(context).colorScheme.primary,
                        data.item,
                        target: targetMax,
                        colorOverTarget: Theme.of(context).colorScheme.error,
                      ),
                      radius: const BorderRadius.vertical(
                        top: Radius.circular(24.0),
                      ),
                    );
                  },
                ),
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: true,
                    showHorizontalValues: _showValues,
                    showVerticalValues: _showValues,
                    showTopHorizontalValue: _showValues,
                    horizontalAxisStep: 1,
                    verticalAxisStep: 1,
                    textStyle: Theme.of(context).textTheme.labelMedium,
                    gridColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.2),
                  ),
                  _targetDecoration,
                ],
                foregroundDecorations: [
                  SparkLineDecoration(
                    lineWidth: 4.0,
                    lineColor: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: _showLine ? 1.0 : 0.0),
                    smoothPoints: _smoothPoints,
                  ),
                  targetLineLegendDecoration(
                    legendDescription: 'Target line 👇',
                    legendTarget: targetMax,
                    legendStyle: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontSize: 14),
                    padding: EdgeInsets.only(top: -8),
                  ),
                  BorderDecoration(
                    endWithChart: true,
                    sidesWidth: Border.symmetric(
                        vertical: BorderSide(width: 2.0),
                        horizontal: BorderSide(width: 4.0)),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.4),
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
