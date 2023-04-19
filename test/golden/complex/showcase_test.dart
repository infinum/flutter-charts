import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  goldenTest('Complex - showcase', fileName: 'showcase_charts', builder: () {
    return GoldenTestGroup(children: [
      GoldenTestScenario(
        name: 'Colorful candles',
        child: Container(
          height: 300,
          width: 400,
          color: Color(0xFF2D3357),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Chart<bool>(
              state: ChartState(
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
                    final color = (_value is bool && _value)
                        ? Color(0xFF567EF7)
                        : Color(0xFF5ABEF9);
                    return BarItem(
                      color: color,
                      radius: BorderRadius.all(Radius.circular(12.0)),
                    );
                  },
                ),
                backgroundDecorations: [
                  HorizontalAxisDecoration(
                    axisStep: 2,
                    endWithChart: true,
                    showValues: true,
                    legendPosition: HorizontalLegendPosition.start,
                    lineColor: Colors.white12,
                    dashArray: [8, 8],
                    lineWidth: 1.5,
                    valuesPadding: const EdgeInsets.only(
                        bottom: 6.0, right: 6.0, left: 6.0),
                    axisValue: (value) => '${value}k',
                    legendFontStyle: defaultTextStyle.copyWith(
                        fontSize: 12.0,
                        color: Colors.white12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
                foregroundDecorations: [],
              ),
            ),
          ),
        ),
      ),
      GoldenTestScenario(
        name: 'Bar chart with background',
        child: Container(
          padding: EdgeInsets.zero,
          height: 300,
          width: 400,
          child: Chart<void>(
            state: ChartState(
              data: ChartData(
                [
                  [
                    BarValue(4),
                    BarValue(4),
                    BarValue(4),
                    BarValue(4),
                    BarValue(4),
                    BarValue(4),
                    BarValue(4),
                  ],
                  [
                    BarValue(0.4),
                    BarValue(1.3),
                    BarValue(0.3),
                    BarValue(0.4),
                    BarValue(1.1),
                    BarValue(0.6),
                    BarValue(0.4),
                  ],
                ],
                axisMax: 4,
              ),
              itemOptions: BarItemOptions(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                barItemBuilder: (data) {
                  return BarItem(
                    radius: BorderRadius.all(Radius.circular(12.0)),
                    color: [
                      Color(0xFFE6E6FD),
                      Color(0xFF4D4DA6)
                    ][data.listIndex],
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
                  horizontalValuesPadding: const EdgeInsets.only(
                      bottom: -8.0, right: 8.0, left: 8.0),
                  verticalValuesPadding: const EdgeInsets.only(top: 24.0),
                  horizontalAxisValueFromValue: (value) => '${value + 1}h',
                  verticalAxisValueFromIndex: (value) => [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ][value.toInt()],
                  textStyle: defaultTextStyle.copyWith(
                      fontSize: 12.0, color: Colors.black45),
                ),
              ],
              foregroundDecorations: [],
            ),
          ),
        ),
      ),
      GoldenTestScenario(
        name: 'Multiple items chart',
        child: Container(
          height: 300,
          width: 400,
          padding: EdgeInsets.zero,
          child: Chart<bool>(
            state: ChartState(
              data: ChartData(
                [
                  [
                    BarValue(23),
                    BarValue(17),
                    BarValue(20),
                    BarValue(15),
                    BarValue(24),
                    BarValue(27),
                  ],
                  [
                    BarValue(12),
                    BarValue(22),
                    BarValue(10),
                    BarValue(20),
                    BarValue(17),
                    BarValue(12),
                  ],
                ],
                dataStrategy: DefaultDataStrategy(stackMultipleValues: false),
                axisMax: 4,
              ),
              itemOptions: BarItemOptions(
                barItemBuilder: (data) {
                  return BarItem(
                      color: [
                    Color(0xFF5B6ACF),
                    Color(0xFFB6CADD)
                  ][data.listIndex]);
                },
                multiValuePadding: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
              backgroundDecorations: [
                GridDecoration(
                  horizontalAxisStep: 10.0,
                  showVerticalGrid: false,
                  showVerticalValues: true,
                  gridColor: Colors.grey.shade400,
                  gridWidth: 1,
                  dashArray: [4, 4],
                  verticalValuesPadding:
                      const EdgeInsets.symmetric(vertical: 12.0),
                  verticalAxisValueFromIndex: (value) => '0$value',
                  textStyle: defaultTextStyle.copyWith(
                      fontSize: 14.0, color: Colors.black45),
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
              ],
            ),
          ),
        ),
      ),
      GoldenTestScenario(
        name: 'Multiple line chart gradient',
        child: Container(
          height: 300,
          width: 400,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFFFCE3E2),
            Color(0xFFFEE6DE),
            Color(0xFFF3EFEE),
            Color(0xFFEDF2F7),
          ])),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Chart<bool>(
              state: ChartState(
                data: ChartData([
                  [
                    BubbleValue(9),
                    BubbleValue(12),
                    BubbleValue(11),
                    BubbleValue(12),
                    BubbleValue(10),
                    BubbleValue(22),
                    BubbleValue(20),
                    BubbleValue(18),
                    BubbleValue(13),
                    BubbleValue(14),
                  ],
                  [
                    BubbleValue(14),
                    BubbleValue(16),
                    BubbleValue(14),
                    BubbleValue(16),
                    BubbleValue(12),
                    BubbleValue(6),
                    BubbleValue(13),
                    BubbleValue(19),
                    BubbleValue(10),
                    BubbleValue(11),
                  ],
                ],
                    axisMax: 30,
                    dataStrategy:
                        DefaultDataStrategy(stackMultipleValues: false)),
                itemOptions: BubbleItemOptions(
                  maxBarWidth: 0.0,
                ),
                backgroundDecorations: [
                  HorizontalAxisDecoration(
                    axisStep: 10.0,
                    lineColor: Colors.grey.shade300,
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
            ),
          ),
        ),
      ),
      GoldenTestScenario(
        name: 'Multiple line chart',
        child: Container(
          height: 300,
          width: 400,
          padding: EdgeInsets.zero,
          child: Chart<bool>(
            state: ChartState(
              data: ChartData(
                [
                  [
                    BubbleValue(10),
                    BubbleValue(8),
                    BubbleValue(20),
                    BubbleValue(18),
                    BubbleValue(9),
                    BubbleValue(30),
                  ],
                  [
                    BubbleValue(18),
                    BubbleValue(25),
                    BubbleValue(10),
                    BubbleValue(24),
                    BubbleValue(19),
                    BubbleValue(21),
                  ],
                ],
                axisMax: 35,
                dataStrategy: DefaultDataStrategy(stackMultipleValues: false),
              ),
              itemOptions: BubbleItemOptions(
                maxBarWidth: 2.0,
                bubbleItemBuilder: (data) {
                  return BubbleItem(
                      color: [
                    Color(0xFF5B6ACF),
                    Color(0xFFB6CADD)
                  ][data.listIndex]);
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
                  verticalValuesPadding:
                      const EdgeInsets.symmetric(vertical: 12.0),
                  verticalAxisValueFromIndex: (value) => '0${value + 1}',
                  textStyle: defaultTextStyle.copyWith(
                      fontSize: 14.0, color: Colors.black45),
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
          ),
        ),
      ),
      GoldenTestScenario(
          name: 'Bar chart up/down',
          child: Container(
            height: 300,
            width: 400,
            padding: EdgeInsets.zero,
            child: Chart<bool>(
              state: ChartState(
                data: ChartData(
                  [
                    [
                      BarValue(6),
                      BarValue(3),
                      BarValue(5),
                      BarValue(6),
                      BarValue(5),
                      BarValue(3),
                      BarValue(2),
                      BarValue(5),
                      BarValue(9),
                      BarValue(10),
                      BarValue(5),
                      BarValue(3),
                    ],
                    [
                      BarValue(-6),
                      BarValue(-9),
                      BarValue(-3),
                      BarValue(-4),
                      BarValue(-3),
                      BarValue(-2),
                      BarValue(-3),
                      BarValue(-4),
                      BarValue(-2),
                      BarValue(-8),
                      BarValue(-7),
                      BarValue(-3),
                    ],
                  ],
                  axisMax: 14,
                  axisMin: -14,
                ),
                itemOptions: BarItemOptions(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  barItemBuilder: (data) {
                    return BarItem(
                      radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                      color: [
                        Color(0xFF0139A4),
                        Color(0xFF00B6E6)
                      ][data.listIndex],
                    );
                  },
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
            ),
          ))
    ]);
  });
}

List<double> translateMorse(String morse) {
  final _s = morse
      .replaceAll(' ', '0,6,0')
      .replaceAll('.', '2, 1,')
      .replaceAll('-', '6, 1,');
  return _s.split(',').map((e) => double.tryParse(e) ?? 0).toList()..add(12);
}
