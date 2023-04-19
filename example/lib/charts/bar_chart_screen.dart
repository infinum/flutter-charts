import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/material.dart';

import '../widgets/bar_chart.dart';

class BarChartScreen extends StatefulWidget {
  BarChartScreen({Key? key}) : super(key: key);

  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  List<BarValue<void>> _values = <BarValue<void>>[];
  double targetMax = 0;
  double targetMin = 0;
  bool _showValues = false;
  bool _smoothPoints = false;
  bool _colorfulBars = false;
  bool _showLine = false;
  int minItems = 6;
  bool _legendOnEnd = true;
  bool _legendOnBottom = true;

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
      return BarValue<void>(
          targetMax * 0.4 + _rand.nextDouble() * targetMax * 0.9);
    }));
    targetMin = targetMax - ((_rand.nextDouble() * 3) + (targetMax * 0.2));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return BarValue<void>(
          targetMax * 0.4 + Random().nextDouble() * targetMax * 0.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar chart',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BarChart(
              data: _values,
              height: MediaQuery.of(context).size.height * 0.4,
              dataToValue: (BarValue value) => value.max ?? 0.0,
              itemOptions: BarItemOptions(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                minBarWidth: 4.0,
                barItemBuilder: (data) {
                  final colorForValue = Colors.accents[data.itemIndex % 15];
                  return BarItem(
                    radius: const BorderRadius.vertical(
                      top: Radius.circular(24.0),
                    ),
                    color: _colorfulBars
                        ? colorForValue
                        : Theme.of(context).colorScheme.primary,
                  );
                },
              ),
              backgroundDecorations: [
                GridDecoration(
                  showHorizontalValues: _showValues,
                  showVerticalValues: _showValues,
                  showTopHorizontalValue: _legendOnBottom ? _showValues : false,
                  horizontalLegendPosition: _legendOnEnd
                      ? HorizontalLegendPosition.end
                      : HorizontalLegendPosition.start,
                  verticalLegendPosition: _legendOnBottom
                      ? VerticalLegendPosition.bottom
                      : VerticalLegendPosition.top,
                  horizontalAxisStep: 1,
                  verticalAxisStep: 1,
                  verticalValuesPadding:
                      const EdgeInsets.symmetric(vertical: 4.0),
                  horizontalValuesPadding:
                      const EdgeInsets.symmetric(horizontal: 4.0),
                  textStyle: Theme.of(context).textTheme.caption,
                  gridColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.2),
                ),
                TargetAreaDecoration(
                  targetAreaFillColor:
                      Theme.of(context).colorScheme.error.withOpacity(0.2),
                  targetLineColor: Theme.of(context).colorScheme.error,
                  targetAreaRadius: BorderRadius.circular(12.0),
                  targetMax: targetMax,
                  targetMin: targetMin,
                  colorOverTarget: Theme.of(context).colorScheme.error,
                ),
              ],
              foregroundDecorations: [
                SparkLineDecoration(
                  lineWidth: 4.0,
                  lineColor: Theme.of(context)
                      .primaryColor
                      .withOpacity(_showLine ? 1.0 : 0.0),
                  smoothPoints: _smoothPoints,
                ),
                ValueDecoration(
                  alignment: Alignment.bottomCenter,
                  textStyle: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
                BorderDecoration(endWithChart: true)
              ],
            ),
          ),
          Expanded(
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
                  value: _legendOnEnd,
                  title: 'Legend on end',
                  onChanged: (value) {
                    setState(() {
                      _legendOnEnd = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _legendOnBottom,
                  title: 'Legend on bottom',
                  onChanged: (value) {
                    setState(() {
                      _legendOnBottom = value;
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
