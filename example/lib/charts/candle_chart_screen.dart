import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/candle_chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/material.dart';

class CandleItem {
  CandleItem(this.min, this.max);

  final double max;
  final double min;
}

class CandleChartScreen extends StatefulWidget {
  CandleChartScreen({Key? key}) : super(key: key);

  @override
  _CandleChartScreenState createState() => _CandleChartScreenState();
}

class _CandleChartScreenState extends State<CandleChartScreen> {
  List<CandleItem> _values = <CandleItem>[];
  double targetMax = 0;
  double targetMin = 0;

  bool _showValues = false;
  int minItems = 25;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 15;
    final double _max = 8 + _difference;

    targetMax = _max * 0.75 + (_rand.nextDouble() * _max * 0.25);
    targetMin = targetMax - (3 + (_rand.nextDouble() * (_max / 2)));
    _values.addAll(List.generate(minItems, (index) {
      double _value = 2 + _rand.nextDouble() * _difference;
      return CandleItem(_value, _value + 2 + _rand.nextDouble() * 4);
    }));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }
      double _value = 2 + Random().nextDouble() * targetMax;
      return CandleItem(_value, _value + 2 + Random().nextDouble() * 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Candle chart',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CandleChart<CandleItem>(
                data: _values,
                height: MediaQuery.of(context).size.height * 0.4,
                dataToValue: (CandleItem value) =>
                    CandleValue(value.min, value.max),
                chartItemOptions: BarItemOptions(
                  minBarWidth: 4.0,
                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                  barItemBuilder: (_) {
                    return BarItem(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(1.0),
                      radius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    );
                  },
                ),
                chartBehaviour: ChartBehaviour(onItemClicked: (item) {
                  setState(() {
                    _selected = item.itemIndex;
                  });
                }),
                backgroundDecorations: [
                  GridDecoration(
                    showHorizontalValues: _showValues,
                    showVerticalGrid: true,
                    showVerticalValues: _showValues,
                    verticalValuesPadding: EdgeInsets.only(left: 8.0),
                    horizontalAxisStep: 5,
                    verticalTextAlign: TextAlign.start,
                    gridColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.2),
                    textStyle: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 13.0),
                  ),
                ],
                foregroundDecorations: [
                  ValueDecoration(
                    textStyle: TextStyle(color: Colors.red),
                    alignment: Alignment.topCenter,
                  ),
                  ValueDecoration(
                    textStyle: TextStyle(color: Colors.red),
                    alignment: Alignment.bottomCenter,
                    valueGenerator: (item) => item.min ?? 0,
                  ),
                  SelectedItemDecoration(
                    _selected,
                    backgroundColor: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.5),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
