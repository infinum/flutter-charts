import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

import '../widgets/bar_chart.dart';

class BarChartScreen extends StatefulWidget {
  BarChartScreen({Key key}) : super(key: key);

  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final _values = <BarValue>[];
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
    _values.addAll(List.generate((_rand.nextDouble() * 6).toInt() + 6, (index) {
      return BarValue(2 + _rand.nextDouble() * _difference);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar chart',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BarChart(
            data: _values,
            minBarWidth: 12.0,
            height: MediaQuery.of(context).size.height * 0.6,
            dataToValue: (BarValue value) => value.max,
            targetValueMax: targetMax,
            itemPadding: EdgeInsets.symmetric(horizontal: Random().nextBool() ? 12.0 : 4.0),
            itemColor: Theme.of(context).accentColor,
            targetOverColor: Theme.of(context).errorColor,
            itemRadius: BorderRadius.vertical(
              top: Radius.circular(Random().nextBool() ? 100.0 : 0.0),
            ),
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
              ),
              TargetLineLegendDecoration(
                legendDescription: 'Target',
                legendStyle: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                    ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh_sharp),
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
