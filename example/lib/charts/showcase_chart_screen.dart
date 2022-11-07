import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

class ShowcaseChartScreen extends StatefulWidget {
  ShowcaseChartScreen({Key? key}) : super(key: key);

  @override
  _ShowcaseChartScreenState createState() => _ShowcaseChartScreenState();
}

class _ShowcaseChartScreenState extends State<ShowcaseChartScreen> {
  int _currentState = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Showcase charts',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AnimatedChart<bool>(
                  duration: Duration(milliseconds: 650),
                  state: _chartStates[_currentState % _chartStates.length]),
            ),
          ),
          SizedBox(height: 48.0),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              height: 60.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: Icon(Icons.navigate_before_outlined),
                      onPressed: () {
                        setState(() {
                          _currentState--;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 24.0),
                  Text((_currentState % _chartStates.length).toString()),
                  SizedBox(width: 24.0),
                  Expanded(
                    child: OutlinedButton(
                      child: Icon(Icons.navigate_next_outlined),
                      onPressed: () {
                        setState(() {
                          _currentState++;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<ChartState<bool>> _chartStates = [
  ChartState(
    data: ChartData(
      [
        [
          CandleValue<bool>.withValue(true, 3.5, 5.5),
          CandleValue<bool>.withValue(false, 3.2, 4.2),
          CandleValue<bool>.withValue(true, 4.2, 7.5),
          CandleValue<bool>.withValue(false, 5.0, 6.1),
          CandleValue<bool>.withValue(true, 4.0, 6.0),
          CandleValue<bool>.withValue(false, 3.0, 4.0),
          CandleValue<bool>.withValue(true, 3.2, 5.8),
          CandleValue<bool>.withValue(false, 1.8, 3.8),
          CandleValue<bool>.withValue(true, 2.5, 4.3),
          CandleValue<bool>.withValue(false, 1.3, 1.9),
        ]
      ],
      valueAxisMaxOver: 1,
    ),
    itemOptions: BarItemOptions(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      barItemBuilder: (data) {
        dynamic _value = data.item.value;
        final color =
            (_value is bool && _value) ? Color(0xFF567EF7) : Color(0xFF5ABEF9);
        return BarItem(
          color: color,
          radius: BorderRadius.all(Radius.circular(12.0)),
        );
      },
    ),
    backgroundDecorations: [
      GridDecoration(
        horizontalAxisStep: 2,
        endWithChartVertical: true,
        endWithChartHorizontal: true,
        showHorizontalValues: true,
        horizontalLegendPosition: HorizontalLegendPosition.start,
        gridColor: Colors.black26,
        dashArray: [8, 8],
        gridWidth: 1.5,
        horizontalValuesPadding:
            const EdgeInsets.only(bottom: -7.0, right: 16.0),
        horizontalAxisValueFromValue: (value) => '${value}k',
        textStyle: TextStyle(
            fontSize: 14.0, color: Colors.black26, fontWeight: FontWeight.w500),
      ),
    ],
    foregroundDecorations: [],
  ),
  ChartState(
    data: ChartData(
      [
        [
          BarValue<bool>.withValue(false, 4),
          BarValue<bool>.withValue(false, 4),
          BarValue<bool>.withValue(false, 4),
          BarValue<bool>.withValue(false, 4),
          BarValue<bool>.withValue(false, 4),
          BarValue<bool>.withValue(false, 4),
          BarValue<bool>.withValue(false, 4),
        ],
        [
          BarValue<bool>.withValue(false, 0.4),
          BarValue<bool>.withValue(false, 1.3),
          BarValue<bool>.withValue(false, 0.3),
          BarValue<bool>.withValue(false, 0.4),
          BarValue<bool>.withValue(false, 1.1),
          BarValue<bool>.withValue(false, 0.6),
          BarValue<bool>.withValue(false, 0.4),
        ],
      ],
      axisMax: 4,
    ),
    itemOptions: BarItemOptions(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      barItemBuilder: (data) {
        return BarItem(
          radius: BorderRadius.all(Radius.circular(12.0)),
          color: [Color(0xFFE6E6FD), Color(0xFF4D4DA6)][data.listIndex],
        );
      },
    ),
    backgroundDecorations: [
      GridDecoration(
        endWithChartVertical: true,
        endWithChartHorizontal: true,
        showHorizontalValues: true,
        showVerticalGrid: false,
        showVerticalValues: true,
        showTopHorizontalValue: true,
        horizontalLegendPosition: HorizontalLegendPosition.start,
        gridColor: Colors.grey.shade200,
        gridWidth: 1,
        horizontalValuesPadding:
            const EdgeInsets.only(bottom: -8.0, right: 8.0),
        verticalValuesPadding: const EdgeInsets.only(top: 24.0),
        horizontalAxisValueFromValue: (value) => '${value + 1}h',
        verticalAxisValueFromIndex: (value) =>
            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value],
        textStyle: TextStyle(fontSize: 14.0, color: Colors.black45),
      ),
    ],
    foregroundDecorations: [],
  ),
  ChartState(
    data: ChartData(
      [
        [
          BarValue<bool>.withValue(false, 23),
          BarValue<bool>.withValue(false, 17),
          BarValue<bool>.withValue(false, 20),
          BarValue<bool>.withValue(false, 15),
          BarValue<bool>.withValue(false, 24),
          BarValue<bool>.withValue(false, 27),
        ],
        [
          BarValue<bool>.withValue(false, 12),
          BarValue<bool>.withValue(false, 22),
          BarValue<bool>.withValue(false, 10),
          BarValue<bool>.withValue(false, 20),
          BarValue<bool>.withValue(false, 17),
          BarValue<bool>.withValue(false, 12),
        ],
      ],
      axisMax: 4,
      dataStrategy: DefaultDataStrategy(stackMultipleValues: false),
    ),
    itemOptions: BarItemOptions(
      barItemBuilder: (data) {
        return BarItem(
            color: [Color(0xFF5B6ACF), Color(0xFFB6CADD)][data.listIndex]);
      },
      multiValuePadding: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    ),
    backgroundDecorations: [
      GridDecoration(
        horizontalAxisStep: 10.0,
        showVerticalGrid: false,
        endWithChartVertical: true,
        endWithChartHorizontal: true,
        showVerticalValues: true,
        gridColor: Colors.grey.shade400,
        gridWidth: 1,
        dashArray: [4, 4],
        verticalValuesPadding: const EdgeInsets.symmetric(vertical: 12.0),
        verticalAxisValueFromIndex: (value) => '0$value',
        textStyle: TextStyle(fontSize: 14.0, color: Colors.black45),
      ),
    ],
    foregroundDecorations: [
      BorderDecoration(
        sidesWidth: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: 3.0,
          ),
        ),
        endWithChart: true,
      ),
    ],
  ),
  ChartState(
    data: ChartData(
      [
        [
          BubbleValue.withValue(false, 9),
          BubbleValue.withValue(false, 12),
          BubbleValue.withValue(false, 11),
          BubbleValue.withValue(false, 12),
          BubbleValue.withValue(false, 10),
          BubbleValue.withValue(false, 22),
          BubbleValue.withValue(false, 20),
          BubbleValue.withValue(false, 18),
          BubbleValue.withValue(false, 13),
          BubbleValue.withValue(false, 14),
        ],
        [
          BubbleValue.withValue(false, 14),
          BubbleValue.withValue(false, 16),
          BubbleValue.withValue(false, 14),
          BubbleValue.withValue(false, 16),
          BubbleValue.withValue(false, 12),
          BubbleValue.withValue(false, 6),
          BubbleValue.withValue(false, 13),
          BubbleValue.withValue(false, 19),
          BubbleValue.withValue(false, 10),
          BubbleValue.withValue(false, 11),
        ],
      ],
      axisMax: 30,
      dataStrategy: DefaultDataStrategy(stackMultipleValues: false),
    ),
    itemOptions: BarItemOptions(
      barItemBuilder: (_) {
        return BarItem(color: Colors.transparent);
      },
    ),
    backgroundDecorations: [
      GridDecoration(
        horizontalAxisStep: 10.0,
        showVerticalGrid: false,
        gridColor: Colors.grey.shade300,
      ),
      SelectedItemDecoration(
        6,
        showText: false,
        backgroundColor: Colors.white54,
      ),
    ],
    foregroundDecorations: [
      SparkLineDecoration(
        smoothPoints: true,
        stretchLine: true,
        lineWidth: 3.0,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFA3A3),
            Color(0xFF8F66C2),
          ],
        ),
      ),
      SparkLineDecoration(
        smoothPoints: true,
        listIndex: 1,
        stretchLine: true,
        lineWidth: 3.0,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFA3A3).withOpacity(0.3),
            Color(0xFF8F66C2).withOpacity(0.3),
          ],
        ),
      ),
    ],
  ),
  ChartState(
    data: ChartData(
      [
        [
          BubbleValue.withValue(false, 10),
          BubbleValue.withValue(false, 8),
          BubbleValue.withValue(false, 20),
          BubbleValue.withValue(false, 18),
          BubbleValue.withValue(false, 9),
          BubbleValue.withValue(false, 30),
        ],
        [
          BubbleValue.withValue(false, 18),
          BubbleValue.withValue(false, 25),
          BubbleValue.withValue(false, 10),
          BubbleValue.withValue(false, 24),
          BubbleValue.withValue(false, 19),
          BubbleValue.withValue(false, 21),
        ],
      ],
      axisMax: 35,
    ),
    itemOptions: BarItemOptions(
      barItemBuilder: (_) {
        return BarItem(color: Colors.transparent);
      },
    ),
    backgroundDecorations: [
      GridDecoration(
        horizontalAxisStep: 10.0,
        showVerticalGrid: false,
        showVerticalValues: true,
        gridColor: Colors.grey.shade400,
        gridWidth: 1,
        dashArray: [4, 4],
        verticalValuesPadding: const EdgeInsets.symmetric(vertical: 12.0),
        verticalAxisValueFromIndex: (value) => '0${value + 1}',
        textStyle: TextStyle(fontSize: 14.0, color: Colors.black45),
      ),
    ],
    foregroundDecorations: [
      BorderDecoration(
        sidesWidth: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: 1.0,
          ),
        ),
        endWithChart: true,
      ),
      SparkLineDecoration(
        listIndex: 1,
        lineColor: Color(0xFFB6CADD),
        lineWidth: 4.0,
      ),
      SparkLineDecoration(
        lineColor: Color(0xFF5B6ACF),
        lineWidth: 4.0,
      ),
    ],
  ),
  ChartState(
    data: ChartData(
      [
        [
          BarValue<bool>.withValue(false, 6),
          BarValue<bool>.withValue(false, 3),
          BarValue<bool>.withValue(false, 5),
          BarValue<bool>.withValue(false, 6),
          BarValue<bool>.withValue(false, 5),
          BarValue<bool>.withValue(false, 3),
          BarValue<bool>.withValue(false, 2),
          BarValue<bool>.withValue(false, 5),
          BarValue<bool>.withValue(false, 9),
          BarValue<bool>.withValue(false, 10),
          BarValue<bool>.withValue(false, 5),
          BarValue<bool>.withValue(false, 3),
        ],
        [
          BarValue<bool>.withValue(false, -6),
          BarValue<bool>.withValue(false, -9),
          BarValue<bool>.withValue(false, -3),
          BarValue<bool>.withValue(false, -4),
          BarValue<bool>.withValue(false, -3),
          BarValue<bool>.withValue(false, -2),
          BarValue<bool>.withValue(false, -3),
          BarValue<bool>.withValue(false, -4),
          BarValue<bool>.withValue(false, -2),
          BarValue<bool>.withValue(false, -8),
          BarValue<bool>.withValue(false, -7),
          BarValue<bool>.withValue(false, -3),
        ],
      ],
      axisMax: 14,
      axisMin: -14,
      dataStrategy: StackDataStrategy(),
    ),
    itemOptions: BarItemOptions(
      barItemBuilder: (data) {
        return BarItem(
          radius: BorderRadius.vertical(top: Radius.circular(12.0)),
          color: [Color(0xFF0139A4), Color(0xFF00B6E6)][data.listIndex],
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
    ),
    backgroundDecorations: [
      GridDecoration(
        horizontalAxisStep: 7.0,
        showVerticalGrid: false,
        gridColor: Colors.grey.shade400,
        gridWidth: 1,
        dashArray: [4, 4],
      ),
    ],
  ),
];
