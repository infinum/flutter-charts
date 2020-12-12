import 'dart:math';

import 'package:example/widgets/bubble_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

class BubbleChartScreen extends StatefulWidget {
  BubbleChartScreen({Key key}) : super(key: key);

  @override
  _BubbleChartScreenState createState() => _BubbleChartScreenState();
}

class _BubbleChartScreenState extends State<BubbleChartScreen> {
  final _values = <BubbleValue>[];
  double targetMax;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 15;

    targetMax = 3 + (_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25);
    _values.addAll(List.generate((_rand.nextDouble() * 6).toInt() + 3, (index) {
      return BubbleValue(2 + _rand.nextDouble() * _difference);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bubble chart',
        ),
      ),
      body: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BubbleChart<BubbleValue>(
              data: _values,
              height: MediaQuery.of(context).size.height * 0.6,
              valueColor: Theme.of(context).colorScheme.onPrimary,
              valueOverColor: Theme.of(context).colorScheme.onError,
              dataToValue: (BubbleValue value) => value.max,
              targetValueMax: targetMax,
              itemPadding: EdgeInsets.symmetric(horizontal: (1 - (_values.length / 17)) * 8.0),
              showValue: _values.length < 6,
              backgroundDecorations: [
                GridDecoration(
                  showHorizontalValues: true,
                  showTopHorizontalValue: true,
                  showVerticalGrid: true,
                  showVerticalValues: true,
                  verticalValuesPadding: EdgeInsets.only(left: 8.0),
                  valueAxisStep: 1,
                  verticalTextAlign: TextAlign.start,
                  gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  textStyle: Theme.of(context).textTheme.caption.copyWith(fontSize: 13.0),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            _values.clear();
            _updateValues();
          });
        },
      ),
    );
  }
}
