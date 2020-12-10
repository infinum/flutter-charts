import 'dart:math';

import 'package:example/widgets/candle_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

class CandleChartScreen extends StatefulWidget {
  CandleChartScreen({Key key}) : super(key: key);

  @override
  _CandleChartScreenState createState() => _CandleChartScreenState();
}

class _CandleChartScreenState extends State<CandleChartScreen> {
  final _values = <CandleValue>[];
  double targetMax;
  double targetMin;

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
    _values.addAll(List.generate((_rand.nextDouble() * 6).toInt() + 4, (index) {
      double _value = 2 + _rand.nextDouble() * _difference;
      return CandleValue(_value + 2 + _rand.nextDouble() * 4, _value);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Candle chart',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CandleChart(
            data: _values,
            height: MediaQuery.of(context).size.height * 0.6,
            dataToValue: (CandleValue value) => value,
            targetValueMax: targetMax,
            targetValueMin: targetMin,
            itemPadding: EdgeInsets.symmetric(horizontal: 12.0),
            itemColor: Theme.of(context).accentColor,
            maxBarWidth: 12.0,
            targetOverColor: Theme.of(context).errorColor,
            itemRadius: BorderRadius.all(
              Radius.circular(Random().nextBool() ? 100.0 : 0.0),
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
