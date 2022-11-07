import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/bubble_chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/material.dart';

class BubbleChartScreen extends StatefulWidget {
  BubbleChartScreen({Key? key}) : super(key: key);

  @override
  _BubbleChartScreenState createState() => _BubbleChartScreenState();
}

class _BubbleChartScreenState extends State<BubbleChartScreen> {
  List<BubbleValue> _values = <BubbleValue>[];
  double targetMax = 0;
  double targetMin = 0;
  bool _showValues = false;
  int minItems = 8;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = 5 + (_rand.nextDouble() * 15);

    targetMax = _difference;
    targetMin = _difference * 0.5;
    _values.addAll(List.generate(minItems, (index) {
      return BubbleValue<void>(2 + _rand.nextDouble() * _difference);
    }));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }

      return BubbleValue<void>(2 + Random().nextDouble() * targetMax);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tad = TargetAreaDecoration(
      targetMax: targetMax,
      targetMin: targetMin,
      colorOverTarget: Theme.of(context).colorScheme.secondary,
      targetLineColor: Theme.of(context).colorScheme.secondary,
      targetAreaFillColor:
          Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      targetAreaRadius: BorderRadius.circular(8.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bubble chart',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BubbleChart<BubbleValue>(
                  data: _values,
                  height: MediaQuery.of(context).size.height * 0.3,
                  itemOptions: BubbleItemOptions(
                    maxBarWidth: 60,
                    bubbleItemBuilder: (data) {
                      return BubbleItem(
                          color: tad.getTargetItemColor(
                              Theme.of(context).colorScheme.primary,
                              data.item));
                    },
                    padding: EdgeInsets.symmetric(
                        horizontal: (1 - (_values.length / 17)) * 8.0),
                  ),
                  dataToValue: (BubbleValue value) => value.max ?? 0,
                  backgroundDecorations: [
                    GridDecoration(
                      showHorizontalValues: _showValues,
                      showTopHorizontalValue: _showValues,
                      showVerticalGrid: true,
                      showVerticalValues: _showValues,
                      verticalValuesPadding: EdgeInsets.only(left: 8.0),
                      verticalAxisStep: 4,
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
                    tad,
                  ],
                ),
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
