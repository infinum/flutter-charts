import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BarChartScreen extends StatefulWidget {
  BarChartScreen({Key? key}) : super(key: key);

  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  List<BarValue<void>> _values = <BarValue<void>>[];
  double targetMax = 10;
  double targetMin = 5;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar chart',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 500,
                child: Chart(
                  state: ChartState.line(
                    ChartData.fromList(
                      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((e) => BubbleValue<void>(e.toDouble())).toList(),
                      axisMax: 16,
                      axisMin: -3,
                    ),
                    itemOptions: BubbleItemOptions(
                      minBarWidth: 4,
                      maxBarWidth: 4,
                    ),
                    behaviour: const ChartBehaviour(
                      isScrollable: true,
                    ),
                    backgroundDecorations: [
                      GridDecoration(
                        showVerticalValues: true,
                        showHorizontalValues: false,
                        verticalAxisStep: 4,
                        gridColor: Colors.black26,
                        textStyle: const TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                        ),
                        verticalAxisValueFromIndex: (index) {
                          var now = DateTime.now();
                          var midnight = DateTime(now.year, now.month, now.day);
                          return 'Text here? ${now.day}';
                        },
                      ),
                    ],
                    foregroundDecorations: [
                      SparkLineDecoration(
                        lineWidth: 2.0,
                        lineColor: Colors.red,
                        smoothPoints: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
