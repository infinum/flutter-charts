import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_charts/chart.dart';

class StyleChangingChartScreen extends StatefulWidget {
  StyleChangingChartScreen({Key key}) : super(key: key);

  @override
  _StyleChangingChartScreenState createState() => _StyleChangingChartScreenState();
}

class _StyleChangingChartScreenState extends State<StyleChangingChartScreen> {
  int _shown = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 2000), (timer) {
      // setState(() {
      //   _shown++;
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ChartState> _states = [
      ChartState<void>(
        [
          <List<double>>[
            [3.8, 5.8],
            [4.2, 7.6],
            [4, 6.1],
            [3.2, 5.8],
            [2.2, 4.3],
          ].map((e) => CandleValue(e[0], e[1])).toList(),
          <List<double>>[
            [3.5, 4.5],
            [4.6, 6.3],
            [3, 3.9],
            [1.9, 3.9],
            [1.5, 2.1],
          ].map((e) => CandleValue(e[0], e[1])).toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          radius: BorderRadius.circular(24.0),
          maxBarWidth: 36.0,
          colorForKey: (item, key) {
            return [
              Color(0xFF5377f0),
              Color(0xFF56b7f4),
            ][key % 2];
          },
        ),
        options: ChartOptions(
          valueAxisMax: 8,
        ),
        behaviour: ChartBehaviour(
          multiItemStack: false,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 2,
            showHorizontalValues: true,
            horizontalLegendPosition: HorizontalLegendPosition.start,
            endWithChart: true,
            showTopHorizontalValue: true,
            horizontalAxisValueFromValue: (value) => '${value}k',
            horizontalValuesPadding: const EdgeInsets.only(
              bottom: -8.0,
              right: 16.0,
            ),
            textStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white54),
            dashArray: [15, 10],
            gridWidth: 1,
            gridColor: Colors.grey.withOpacity(0.6),
          ),
        ],
      ),
      ChartState<void>(
        [
          [5, 5, 5, 5, 5, 5, 5].map((e) => BarValue<void>(e.toDouble())).toList(),
          [1.5, 2, 1.2, 1.5, 2, 1.5, 1.4].map((e) => BarValue<void>(e.toDouble())).toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          maxBarWidth: 48.0,
          colorForKey: (_, key) => [
            Color(0xFFe3e3fb),
            Color(0xFF464698),
          ][key % 2],
          radius: BorderRadius.circular(24.0),
        ),
        options: ChartOptions(
          valueAxisMin: 1,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 1,
            gridWidth: 1,
            showTopHorizontalValue: true,
            horizontalLegendPosition: HorizontalLegendPosition.start,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.2),
            textStyle: Theme.of(context).textTheme.caption,
            verticalAxisValueFromIndex: (index) => MaterialLocalizations.of(context).narrowWeekdays[index],
            horizontalAxisValueFromValue: (value) => '${value}h',
            verticalValuesPadding: const EdgeInsets.only(top: 8.0),
            showHorizontalValues: true,
            showVerticalValues: true,
          ),
        ],
      ),
      ChartState<void>(
        [
          [7, 5, 6, 4, 7, 8].map((e) => BarValue<void>(e.toDouble())).toList(),
          [4, 7, 3, 6, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 28.0),
          maxBarWidth: 58.0,
          colorForKey: (_, key) => [
            Color(0xFF5562c4),
            Color(0xFFaec3d7),
          ][key % 2],
        ),
        options: ChartOptions(
          valueAxisMax: 9,
        ),
        behaviour: ChartBehaviour(
          multiItemStack: false,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 3,
            showVerticalValues: true,
            textStyle: Theme.of(context).textTheme.caption,
            verticalAxisValueFromIndex: (value) => '0${value + 1}',
            verticalValuesPadding: const EdgeInsets.only(top: 12.0),
            dashArray: [2, 10],
            gridWidth: 1.5,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
          ),
          BorderDecoration(
            endWithChart: true,
            sidesWidth: const EdgeInsets.only(bottom: 2.0),
            color: Colors.blueGrey.shade200,
          )
        ],
      ),
      ChartState<void>(
          [
            [7, 5, 6, 4, 7, 8, 5].map((e) => BarValue<void>(e.toDouble())).toList(),
            [4, 7, 3, 6, 5, 4, 6].map((e) => BarValue<void>(e.toDouble())).toList(),
          ],
          itemOptions: ChartItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            multiValuePadding: const EdgeInsets.symmetric(horizontal: 28.0),
            maxBarWidth: 58.0,
            color: Colors.transparent,
          ),
          options: ChartOptions(
            valueAxisMax: 9,
          ),
          behaviour: ChartBehaviour(
            multiItemStack: false,
          ),
          backgroundDecorations: [
            GridDecoration(
              showVerticalGrid: false,
              valueAxisStep: 3,
              showVerticalValues: true,
              textStyle: Theme.of(context).textTheme.caption,
              verticalAxisValueFromIndex: (value) => '0${value + 1}',
              verticalValuesPadding: const EdgeInsets.only(top: 12.0),
              dashArray: [2, 10],
              gridWidth: 1.5,
              gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
            ),
            BorderDecoration(
              endWithChart: true,
              sidesWidth: const EdgeInsets.only(bottom: 2.0),
              color: Colors.blueGrey.shade200,
            )
          ],
          foregroundDecorations: [
            SparkLineDecoration(
              lineKey: 1,
              lineColor: Color(0xFFe4e6ea),
              gradient: LinearGradient(colors: [Color(0xFFe4e6ea), Color(0xFFe4e6ea)]),
              lineWidth: 4.0,
            ),
            SparkLineDecoration(
              lineColor: Color(0xFF5461c4),
              gradient: LinearGradient(colors: [Color(0xFF5461c4), Color(0xFF5461c4)]),
              lineWidth: 4.0,
            ),
          ]),
      ChartState<void>(
          [
            [4, 5, 4, 4.5, 2, 6, 3].map((e) => BarValue<void>(e.toDouble())).toList(),
            [3, 2.6, 3.4, 3, 7, 6, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
          ],
          itemOptions: ChartItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            multiValuePadding: const EdgeInsets.symmetric(horizontal: 28.0),
            maxBarWidth: 58.0,
            color: Colors.transparent,
          ),
          options: ChartOptions(
            valueAxisMax: 9,
          ),
          behaviour: ChartBehaviour(
            multiItemStack: false,
          ),
          backgroundDecorations: [
            GridDecoration(
              showVerticalGrid: false,
              valueAxisStep: 3,
              showVerticalValues: true,
              textStyle: Theme.of(context).textTheme.caption,
              verticalAxisValueFromIndex: (value) => '0${value + 1}',
              verticalValuesPadding: const EdgeInsets.only(top: 12.0),
              gridWidth: 1,
              gridColor: Colors.blueGrey.shade200.withOpacity(0.4),
            ),
          ],
          foregroundDecorations: [
            SparkLineDecoration(
              lineColor: Colors.white30,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFff9f9f),
                  Color(0xFF8d65ba),
                ],
                stops: [0.3, 0.7],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              smoothPoints: true,
              lineWidth: 4.0,
            ),
            SparkLineDecoration(
              lineKey: 1,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFff9f9f),
                  Color(0xFF8d65ba),
                ],
                stops: [0.3, 0.7],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              smoothPoints: true,
              lineWidth: 4.0,
            ),
          ]),
      ChartState<void>(
        [
          [15, 20, 12, 15, 20, 15, 14].map((e) => BarValue<void>(e.toDouble())).toList(),
          [-5, -15, -10, -5, -2, -18, -20].map((e) => BarValue<void>(e.toDouble())).toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          maxBarWidth: 68.0,
          colorForKey: (_, key) => [
            Color(0xFF3458a9),
            Color(0xFF15aedf),
          ][key % 2],
          radius: BorderRadius.vertical(top: Radius.circular(48.0)),
        ),
        options: ChartOptions(
          valueAxisMin: 1,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 5,
            gridWidth: 1,
            showTopHorizontalValue: true,
            horizontalLegendPosition: HorizontalLegendPosition.start,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.2),
            textStyle: Theme.of(context).textTheme.caption,
            horizontalAxisValueFromValue: (value) => '${value}',
            verticalValuesPadding: const EdgeInsets.only(top: 8.0),
            showHorizontalValues: true,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Style changing',
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50.0,
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 350),
            color: (_shown % _states.length) >= 1 ? Colors.white : Color(0xFF292e4b),
            padding: const EdgeInsets.all(24.0),
            height: 850.0,
            child: AnimatedChart<dynamic>(
              duration: Duration(milliseconds: 350),
              state: _states[_shown % _states.length],
            ),
          ),
          Row(
            children: _states.map((e) {
              return Radio<int>(
                groupValue: _shown,
                value: _states.indexOf(e),
                onChanged: (v) {
                  setState(() {
                    _shown = v;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
