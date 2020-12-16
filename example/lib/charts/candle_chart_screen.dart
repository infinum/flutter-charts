import 'dart:math';

import 'package:example/widgets/candle_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_charts/chart.dart';

class CandleChartScreen extends StatefulWidget {
  CandleChartScreen({Key key}) : super(key: key);

  @override
  _CandleChartScreenState createState() => _CandleChartScreenState();
}

class _CandleChartScreenState extends State<CandleChartScreen> {
  List<CandleValue> _values = <CandleValue>[];
  double targetMax;
  double targetMin;

  bool _showValues = false;
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
    final double _max = 8 + _difference;

    targetMax = _max * 0.75 + (_rand.nextDouble() * _max * 0.25);
    targetMin = targetMax - (3 + (_rand.nextDouble() * (_max / 2)));
    _values.addAll(List.generate((_rand.nextDouble() * 6).toInt() + 20, (index) {
      double _value = 2 + _rand.nextDouble() * _difference;
      return CandleValue(_value + 2 + _rand.nextDouble() * 4, _value);
    }));
  }

  void _addValues() {
    _values = List.generate(minItems, (index) {
      if (_values.length > index) {
        return _values[index];
      }
      double _value = 2 + Random().nextDouble() * targetMax;
      return CandleValue(_value + 2 + Random().nextDouble() * 4, _value);
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
              child: CandleChart(
                data: _values,
                height: MediaQuery.of(context).size.height * 0.5,
                dataToValue: (CandleValue value) => value,
                chartItemOptions: ChartItemOptions(
                  targetMax: targetMax,
                  targetMin: targetMin,
                  minBarWidth: 4.0,
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  color: Theme.of(context).accentColor,
                  targetOverColor: Theme.of(context).errorColor,
                  radius: BorderRadius.all(
                    Radius.circular(100.0),
                  ),
                ),
                chartBehaviour: ChartBehaviour(onItemClicked: (item) {
                  setState(() {
                    _selected = item;
                  });
                }),
                backgroundDecorations: [
                  GridDecoration(
                    showHorizontalValues: _showValues,
                    showVerticalGrid: true,
                    showVerticalValues: _showValues,
                    verticalValuesPadding: EdgeInsets.only(left: 8.0),
                    valueAxisStep: 1,
                    verticalTextAlign: TextAlign.start,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                    textStyle: Theme.of(context).textTheme.caption.copyWith(fontSize: 13.0),
                  ),
                  CupertinoSelectedPainter(_selected),
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
