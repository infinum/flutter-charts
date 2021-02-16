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
  Widget build(BuildContext context) {
    final List<ChartState> _states = [
      ChartState<void>(
        [
          [5, 5, 4, 7, 7, 7].map((e) => BarValue<void>(e.toDouble())).toList(),
          [6, 4, 6, 8, 5, 7].map((e) => BarValue<void>(e.toDouble())).toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          radius: BorderRadius.all(Radius.circular(12.0)),
          maxBarWidth: 8.0,
          colorForKey: (_, key) => [
            Color(0xFFfdc8cd),
            Color(0xFF7d4abd),
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
            dashArray: [15, 5],
            gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
          ),
          BorderDecoration(
            borderWidth: const EdgeInsets.only(bottom: 2.0),
            color: Colors.blueGrey.shade200,
          )
        ],
      ),
      ChartState<void>(
        [
          [7, 5, 6, 4, 7, 8].map((e) => BarValue<void>(e.toDouble())).toList(),
          [4, 7, 3, 6, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          maxBarWidth: 8.0,
          colorForKey: (_, key) => [
            Color(0xFF5563c4),
            Color(0xFFadc2d6),
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
            dashArray: [2, 10],
            gridWidth: 1.5,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
          ),
          BorderDecoration(
            borderWidth: const EdgeInsets.only(bottom: 2.0),
            color: Colors.blueGrey.shade200,
          )
        ],
      ),
      ChartState<void>.fromList(
        [4, 2, 3, 1].map((e) => BarValue<void>(e.toDouble())).toList(),
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          radius: BorderRadius.circular(12.0),
          maxBarWidth: 80.0,
          colorForValue: (item, min, [max]) {
            return [
              Color(0xFF6341ed),
              Color(0xFF54b7f4),
              Color(0xFF5377f0),
              Color(0xFF44bf9f),
            ][(min.toInt() - 1) % 4];
          },
        ),
        options: ChartOptions(
          valueAxisMax: 6,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 2,
            dashArray: [5, 10],
            gridWidth: 1,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
          ),
          BorderDecoration(
            borderWidth: const EdgeInsets.only(bottom: 2.0),
            color: Colors.blueGrey.shade200,
          )
        ],
      ),
      ChartState<void>.fromList(
        <List<double>>[
          [3.8, 5.8],
          [3.5, 4.5],
          [4.2, 7.6],
          [4.6, 6.3],
          [4, 6.1],
          [3, 3.9],
          [3.2, 5.8],
          [1.9, 3.9],
          [2.2, 4.3],
          [1.5, 2.1],
        ]
            .asMap()
            .map((index, e) => MapEntry(index, CandleValue<void>.withValue(index % 2 == 0, e[0], e[1])))
            .values
            .toList(),
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          radius: BorderRadius.circular(12.0),
          maxBarWidth: 12.0,
          colorForKey: (item, key) {
            final _value = (item.max * 10) % 3 == 0;

            return [
              Color(0xFF6341ed),
              Color(0xFF54b7f4),
              Color(0xFF5377f0),
              Color(0xFF44bf9f),
            ][_value ? 1 : 0];
          },
        ),
        options: ChartOptions(
          valueAxisMax: 8,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 2,
            dashArray: [5, 10],
            gridWidth: 1,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
          ),
          BorderDecoration(
            borderWidth: const EdgeInsets.only(bottom: 2.0),
            color: Colors.blueGrey.shade200,
          )
        ],
      ),
      ChartState<void>(
        [
          <List<double>>[
            [0, 21],
            [0, 18],
            [0, 7],
            [0, 7],
            [0, 20],
            [0, 13],
            [0, 18],
            [0, 23],
            [0, 18],
            [0, 9],
            [0, 19],
            [0, 8],
          ]
              .asMap()
              .map((index, e) => MapEntry(index, CandleValue<void>.withValue(index % 2 == 0, e[0], e[1])))
              .values
              .toList(),
          <List<double>>[
            [22, 33],
            [19, 33],
            [8, 28],
            [8, 28],
            [21, 29],
            [14, 29],
            [19, 33],
            [24, 33],
            [19, 33],
            [10, 16],
            [20, 39],
            [9, 28],
          ]
              .asMap()
              .map((index, e) => MapEntry(index, CandleValue<void>.withValue(index % 2 == 0, e[0], e[1])))
              .values
              .toList(),
          <List<double>>[
            [34, 44],
            [34, 50],
            [29, 37],
            [29, 38],
            [30, 45],
            [30, 41],
            [34, 48],
            [34, 43],
            [34, 50],
            [17, 30],
            [40, 47],
            [29, 34],
          ]
              .asMap()
              .map((index, e) => MapEntry(index, CandleValue<void>.withValue(index % 2 == 0, e[0], e[1])))
              .values
              .toList(),
        ],
        itemOptions: ChartItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          multiValuePadding: const EdgeInsets.symmetric(horizontal: 12.0),
          radius: BorderRadius.circular(12.0),
          maxBarWidth: 6.0,
          colorForKey: (item, key) {
            return [
              Color(0xFF4cb793),
              Color(0xFFc6d584),
              Color(0xFFb7bba7),
            ][key];
          },
        ),
        options: ChartOptions(
          valueAxisMax: 8,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            valueAxisStep: 10,
            dashArray: [5, 10],
            gridWidth: 1,
            gridColor: Colors.blueGrey.shade200.withOpacity(0.8),
          ),
          BorderDecoration(
            borderWidth: const EdgeInsets.only(bottom: 2.0),
            color: Colors.blueGrey.shade200,
          )
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
          Container(
            padding: const EdgeInsets.all(24.0),
            height: 350.0,
            child: AnimatedChart<dynamic>(
              duration: Duration(milliseconds: 350),
              state: _states[_shown],
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
