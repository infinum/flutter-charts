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
                    ChartDataSection<bool>(items: [
                      ChartItem(5.5, min: 3.5, value: true),
                      ChartItem(4.2, min: 3.2, value: false),
                      ChartItem(7.5, min: 4.2, value: true),
                      ChartItem(6.1, min: 5.0, value: false),
                      ChartItem(6.0, min: 4.0, value: true),
                      ChartItem(4.0, min: 3.0, value: false),
                      ChartItem(5.8, min: 3.2, value: true),
                      ChartItem(3.8, min: 1.8, value: false),
                      ChartItem(4.3, min: 2.5, value: true),
                      ChartItem(1.9, min: 1.3, value: false),
                    ]),
                  ],
                  valueAxisMaxOver: 1,
                ),
                itemOptions: BarItemOptions(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  barItemBuilder: (data) {
                    dynamic _value = data.item.value;
                    final color = (_value is bool && _value) ? Color(0xFF567EF7) : Color(0xFF5ABEF9);
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
                    valuesPadding: const EdgeInsets.only(bottom: 6.0, right: 6.0, left: 6.0),
                    axisValue: (value) => '${value}k',
                    legendFontStyle:
                        defaultTextStyle.copyWith(fontSize: 12.0, color: Colors.white12, fontWeight: FontWeight.w500),
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
          child: Chart<bool>(
            state: ChartState(
              data: ChartData(
                [
                  ChartDataSection<bool>(items: [
                    ChartItem(4),
                    ChartItem(4),
                    ChartItem(4),
                    ChartItem(4),
                    ChartItem(4),
                    ChartItem(4),
                    ChartItem(4),
                  ]),
                  ChartDataSection<bool>(items: [
                    ChartItem(0.4),
                    ChartItem(1.3),
                    ChartItem(0.3),
                    ChartItem(0.4),
                    ChartItem(1.1),
                    ChartItem(0.6),
                    ChartItem(0.4),
                  ]),
                ],
                axisMax: 4,
              ),
              itemOptions: BarItemOptions(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                barItemBuilder: (data) {
                  return BarItem(
                    radius: BorderRadius.all(Radius.circular(12.0)),
                    color: [Color(0xFFE6E6FD), Color(0xFF4D4DA6)][data.sectionOptions.sectionIndex],
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
                  horizontalValuesPadding: const EdgeInsets.only(bottom: -8.0, right: 8.0, left: 8.0),
                  verticalValuesPadding: const EdgeInsets.only(top: 24.0),
                  horizontalAxisValueFromValue: (value) => '${value + 1}h',
                  verticalAxisValueFromIndex: (value) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value],
                  textStyle: defaultTextStyle.copyWith(fontSize: 12.0, color: Colors.black45),
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
                  ChartDataSection<bool>(items: [
                    ChartItem(23),
                    ChartItem(17),
                    ChartItem(20),
                    ChartItem(15),
                    ChartItem(24),
                    ChartItem(27),
                  ]),
                  ChartDataSection<bool>(items: [
                    ChartItem(12),
                    ChartItem(22),
                    ChartItem(10),
                    ChartItem(20),
                    ChartItem(17),
                    ChartItem(12),
                  ]),
                ],
                dataStrategy: DefaultDataStrategy(stackMultipleValues: false),
                axisMax: 4,
              ),
              itemOptions: BarItemOptions(
                barItemBuilder: (data) {
                  return BarItem(color: [Color(0xFF5B6ACF), Color(0xFFB6CADD)][data.sectionOptions.sectionIndex]);
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
                  verticalValuesPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  verticalAxisValueFromIndex: (value) => '0$value',
                  textStyle: defaultTextStyle.copyWith(fontSize: 14.0, color: Colors.black45),
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
                  ChartDataSection<bool>(items: [
                    ChartItem(9, min: 9),
                    ChartItem(12, min: 12),
                    ChartItem(11, min: 11),
                    ChartItem(12, min: 12),
                    ChartItem(10, min: 10),
                    ChartItem(22, min: 22),
                    ChartItem(20, min: 20),
                    ChartItem(18, min: 18),
                    ChartItem(13, min: 13),
                    ChartItem(14, min: 14),
                  ]),
                  ChartDataSection<bool>(items: [
                    ChartItem(14, min: 14),
                    ChartItem(16, min: 16),
                    ChartItem(14, min: 14),
                    ChartItem(16, min: 16),
                    ChartItem(12, min: 12),
                    ChartItem(6, min: 6),
                    ChartItem(13, min: 13),
                    ChartItem(19, min: 19),
                    ChartItem(10, min: 10),
                    ChartItem(11, min: 11),
                  ]),
                ], axisMax: 30, dataStrategy: DefaultDataStrategy(stackMultipleValues: false)),
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
                    pathBuilder: CubicBezierPathBuilder(),
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
                    pathBuilder: CubicBezierPathBuilder(),
                    sectionIndex: 1,
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
                  ChartDataSection<bool>(items: [
                    ChartItem(10, min: 10),
                    ChartItem(8, min: 8),
                    ChartItem(20, min: 20),
                    ChartItem(18, min: 18),
                    ChartItem(9, min: 9),
                    ChartItem(30, min: 30),
                  ]),
                  ChartDataSection<bool>(items: [
                    ChartItem(18, min: 18),
                    ChartItem(25, min: 25),
                    ChartItem(10, min: 10),
                    ChartItem(24, min: 24),
                    ChartItem(19, min: 19),
                    ChartItem(21, min: 21),
                  ]),
                ],
                axisMax: 35,
                dataStrategy: DefaultDataStrategy(stackMultipleValues: false),
              ),
              itemOptions: BubbleItemOptions(
                maxBarWidth: 2.0,
                bubbleItemBuilder: (data) {
                  return BubbleItem(color: [Color(0xFF5B6ACF), Color(0xFFB6CADD)][data.sectionOptions.sectionIndex]);
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
                  textStyle: defaultTextStyle.copyWith(fontSize: 14.0, color: Colors.black45),
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
                  sectionIndex: 1,
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
                    ChartDataSection<bool>(items: [
                      ChartItem(6),
                      ChartItem(3),
                      ChartItem(5),
                      ChartItem(6),
                      ChartItem(5),
                      ChartItem(3),
                      ChartItem(2),
                      ChartItem(5),
                      ChartItem(9),
                      ChartItem(10),
                      ChartItem(5),
                      ChartItem(3),
                    ]),
                    ChartDataSection<bool>(items: [
                      ChartItem(-6),
                      ChartItem(-9),
                      ChartItem(-3),
                      ChartItem(-4),
                      ChartItem(-3),
                      ChartItem(-2),
                      ChartItem(-3),
                      ChartItem(-4),
                      ChartItem(-2),
                      ChartItem(-8),
                      ChartItem(-7),
                      ChartItem(-3),
                    ]),
                  ],
                  axisMax: 14,
                  axisMin: -14,
                ),
                itemOptions: BarItemOptions(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  barItemBuilder: (data) {
                    return BarItem(
                      radius: BorderRadius.vertical(top: Radius.circular(12.0)),
                      color: [Color(0xFF0139A4), Color(0xFF00B6E6)][data.sectionOptions.sectionIndex],
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
  final _s = morse.replaceAll(' ', '0,6,0').replaceAll('.', '2, 1,').replaceAll('-', '6, 1,');
  return _s.split(',').map((e) => double.tryParse(e) ?? 0).toList()..add(12);
}
