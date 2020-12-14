import 'dart:math';

import 'package:example/widgets/line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_charts/chart.dart';

class LineChartScreen extends StatefulWidget {
  LineChartScreen({Key key}) : super(key: key);

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final _values = <BarValue>[];
  double targetMax;
  bool _showValues = false;
  bool _smoothCurves = false;
  int minItems = 6;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = 2 + (_rand.nextDouble() * 15);

    targetMax = 3 + (_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25);
    _values.addAll(List.generate(minItems, (index) {
      return BarValue(2 + _rand.nextDouble() * _difference);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sparkline chart',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LineChart(
                data: _values,
                maxBarWidth: 4.0,
                height: MediaQuery.of(context).size.height * 0.6,
                dataToValue: (BarValue value) => value.max,
                itemColor: Theme.of(context).accentColor.withOpacity(0.4),
                targetOverColor: Theme.of(context).errorColor,
                smoothCurves: _smoothCurves,
                backgroundDecorations: [
                  GridDecoration(
                    showVerticalGrid: false,
                    showTopHorizontalValue: _showValues,
                    showVerticalValues: _showValues,
                    showHorizontalValues: _showValues,
                    valueAxisStep: 1,
                    textStyle: Theme.of(context).textTheme.caption,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
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
                  leading: Icon(_showValues ? Icons.visibility_off : Icons.visibility),
                  title: Text('${_showValues ? 'Hide' : 'Show'} axis values'),
                  onTap: () {
                    setState(() {
                      _showValues = !_showValues;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(_smoothCurves ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  title: Text('Smooth curves'),
                  onTap: () {
                    setState(() {
                      _smoothCurves = !_smoothCurves;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add data'),
                  onTap: () {
                    setState(() {
                      _values.clear();
                      minItems += 4;
                      _updateValues();
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove),
                  title: Text('Remove data'),
                  onTap: () {
                    setState(() {
                      _values.clear();
                      minItems -= 4;
                      _updateValues();
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
