import 'package:charts_painter/chart.dart';
import 'package:example/widgets/widget_decorations.dart';
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
          ChartItem<bool>(5.5, value: true, min: 3.5),
          ChartItem<bool>(4.2, value: false, min: 3.2),
          ChartItem<bool>(7.5, value: true, min: 4.2),
          ChartItem<bool>(6.1, value: false, min: 5.0),
          ChartItem<bool>(6.0, value: true, min: 4.0),
          ChartItem<bool>(4.0, value: false, min: 3.0),
          ChartItem<bool>(5.8, value: true, min: 3.2),
          ChartItem<bool>(3.8, value: false, min: 1.8),
          ChartItem<bool>(4.3, value: true, min: 2.5),
          ChartItem<bool>(1.9, value: false, min: 1.3),
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
          ChartItem<bool>(4, value: false),
          ChartItem<bool>(4, value: false),
          ChartItem<bool>(4, value: false),
          ChartItem<bool>(4, value: false),
          ChartItem<bool>(4, value: false),
          ChartItem<bool>(4, value: false),
          ChartItem<bool>(4, value: false),
        ],
        [
          ChartItem<bool>(0.4, value: false),
          ChartItem<bool>(1.3, value: false),
          ChartItem<bool>(0.3, value: false),
          ChartItem<bool>(0.4, value: false),
          ChartItem<bool>(1.1, value: false),
          ChartItem<bool>(0.6, value: false),
          ChartItem<bool>(0.4, value: false),
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
          ChartItem<bool>(23, value: false),
          ChartItem<bool>(17, value: false),
          ChartItem<bool>(20, value: false),
          ChartItem<bool>(15, value: false),
          ChartItem<bool>(24, value: false),
          ChartItem<bool>(27, value: false),
        ],
        [
          ChartItem<bool>(12, value: false),
          ChartItem<bool>(22, value: false),
          ChartItem<bool>(10, value: false),
          ChartItem<bool>(20, value: false),
          ChartItem<bool>(17, value: false),
          ChartItem<bool>(12, value: false),
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
          ChartItem(9, value: false, min: 9),
          ChartItem(12, value: false, min: 12),
          ChartItem(11, value: false, min: 11),
          ChartItem(12, value: false, min: 12),
          ChartItem(10, value: false, min: 10),
          ChartItem(22, value: false, min: 22),
          ChartItem(20, value: false, min: 20),
          ChartItem(18, value: false, min: 18),
          ChartItem(13, value: false, min: 13),
          ChartItem(14, value: false, min: 14),
        ],
        [
          ChartItem(14, value: false, min: 14),
          ChartItem(16, value: false, min: 16),
          ChartItem(14, value: false, min: 14),
          ChartItem(16, value: false, min: 16),
          ChartItem(12, value: false, min: 12),
          ChartItem(6, value: false, min: 6),
          ChartItem(13, value: false, min: 13),
          ChartItem(19, value: false, min: 19),
          ChartItem(10, value: false, min: 10),
          ChartItem(11, value: false, min: 11),
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
      selectedItemDecoration(
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
            Color(0xFFFFA3A3).withValues(alpha: 0.3),
            Color(0xFF8F66C2).withValues(alpha: 0.3),
          ],
        ),
      ),
    ],
  ),
  ChartState(
    data: ChartData(
      [
        [
          ChartItem(10, value: false, min: 10),
          ChartItem(8, value: false, min: 8),
          ChartItem(20, value: false, min: 20),
          ChartItem(18, value: false, min: 18),
          ChartItem(9, value: false, min: 9),
          ChartItem(30, value: false, min: 30),
        ],
        [
          ChartItem(18, value: false, min: 18),
          ChartItem(25, value: false, min: 25),
          ChartItem(10, value: false, min: 10),
          ChartItem(24, value: false, min: 24),
          ChartItem(19, value: false, min: 19),
          ChartItem(21, value: false, min: 21),
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
          ChartItem<bool>(6, value: false),
          ChartItem<bool>(3, value: false),
          ChartItem<bool>(5, value: false),
          ChartItem<bool>(6, value: false),
          ChartItem<bool>(5, value: false),
          ChartItem<bool>(3, value: false),
          ChartItem<bool>(2, value: false),
          ChartItem<bool>(5, value: false),
          ChartItem<bool>(9, value: false),
          ChartItem<bool>(10, value: false),
          ChartItem<bool>(5, value: false),
          ChartItem<bool>(3, value: false),
        ],
        [
          ChartItem<bool>(-6, value: false),
          ChartItem<bool>(-9, value: false),
          ChartItem<bool>(-3, value: false),
          ChartItem<bool>(-4, value: false),
          ChartItem<bool>(-3, value: false),
          ChartItem<bool>(-2, value: false),
          ChartItem<bool>(-3, value: false),
          ChartItem<bool>(-4, value: false),
          ChartItem<bool>(-2, value: false),
          ChartItem<bool>(-8, value: false),
          ChartItem<bool>(-7, value: false),
          ChartItem<bool>(-3, value: false),
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
