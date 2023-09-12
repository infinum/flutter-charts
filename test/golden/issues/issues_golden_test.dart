import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  goldenTest('WidgetDecoration with axisMin', fileName: 'issue_94', builder: () {
    final List<List<ChartItem<double>>> _mappedValues = [
      [ChartItem(2.0), ChartItem(5.0), ChartItem(8.0), ChartItem(3.0), ChartItem(6.0)]
    ];

    return Container(
      height: 500,
      width: 800,
      child: Padding(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 500,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 80,
                  child: DecorationsRenderer(
                    [
                      HorizontalAxisDecoration(
                        asFixedDecoration: true,
                        lineWidth: 0,
                        axisStep: 2,
                        showValues: true,
                        endWithChart: false,
                        axisValue: (value) => '$value',
                        valuesAlign: TextAlign.center,
                        valuesPadding: const EdgeInsets.only(left: -80, bottom: -10),
                        showLines: false,
                        showTopValue: true,
                        legendFontStyle: TextStyle(
                          fontFamily: 'roboto',
                          color: Colors.black87,
                        ),
                      )
                    ],
                    ChartState<double>(
                      data: ChartData(
                        _mappedValues,
                        axisMin: 2,
                        axisMax: 8,
                        dataStrategy: const DefaultDataStrategy(stackMultipleValues: true),
                      ),
                      itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
                        return const SizedBox();
                      }),
                      backgroundDecorations: [
                        GridDecoration(
                          showVerticalValues: true,
                          verticalLegendPosition: VerticalLegendPosition.bottom,
                          verticalValuesPadding: const EdgeInsets.only(top: 8.0),
                          verticalAxisStep: 2,
                          gridWidth: 1,
                          textStyle: TextStyle(
                            fontFamily: 'roboto',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: AnimatedChart<double>(
                    width: 800 - 80 - 8,
                    duration: const Duration(milliseconds: 450),
                    state: ChartState<double>(
                      data: ChartData(
                        _mappedValues,
                        axisMin: 2,
                        axisMax: 8,
                        dataStrategy: const DefaultDataStrategy(stackMultipleValues: true),
                      ),
                      itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(color: Colors.blue.withOpacity(0.2)),
                            Positioned(
                              top: -24,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Center(child: Text(_mappedValues[data.listIndex][data.itemIndex].max.toString()))
                                ],
                              ),
                            ),
                            Positioned(
                              top: -5,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.4),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      foregroundDecorations: [],
                      backgroundDecorations: [
                        GridDecoration(
                          horizontalAxisStep: 2,
                          showVerticalGrid: false,
                          showVerticalValues: true,
                          verticalLegendPosition: VerticalLegendPosition.bottom,
                          verticalValuesPadding: const EdgeInsets.only(top: 8.0),
                          verticalAxisStep: 1,
                          dashArray: [8, 8],
                          gridWidth: 1,
                          textStyle: TextStyle(
                            fontFamily: 'roboto',
                            color: Colors.black87,
                          ),
                        ),
                        WidgetDecoration(
                          widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
                            return Padding(
                              padding: (chartState.defaultMargin + chartState.defaultPadding),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: 0,
                                    left: 0,
                                    bottom: verticalMultiplier * (3.6 - 2),
                                    child: CustomPaint(painter: DashedLinePainter()),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        TargetAreaDecoration(
                          targetAreaFillColor: Colors.red.withOpacity(0.6),
                          targetLineColor: Colors.transparent,
                          lineWidth: 0,
                          targetMax: 2.0,
                          targetMin: 0,
                        ),
                        SparkLineDecoration(
                          lineWidth: 2,
                          lineColor: Colors.blue,
                          smoothPoints: true,
                          listIndex: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
  goldenTest('WidgetDecoration no axisMin', fileName: 'issue_94_1', builder: () {
    final List<List<ChartItem<double>>> _mappedValues = [
      [ChartItem(2.0), ChartItem(5.0), ChartItem(8.0), ChartItem(3.0), ChartItem(6.0)]
    ];

    return Container(
      height: 500,
      width: 800,
      child: Padding(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 500,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 80,
                  child: DecorationsRenderer(
                    [
                      HorizontalAxisDecoration(
                        asFixedDecoration: true,
                        lineWidth: 0,
                        axisStep: 2,
                        showValues: true,
                        endWithChart: false,
                        axisValue: (value) => '$value',
                        valuesAlign: TextAlign.center,
                        valuesPadding: const EdgeInsets.only(left: -80, bottom: -10),
                        showLines: false,
                        showTopValue: true,
                        legendFontStyle: TextStyle(
                          fontFamily: 'roboto',
                          color: Colors.black87,
                        ),
                      )
                    ],
                    ChartState<double>(
                      data: ChartData(
                        _mappedValues,
                        dataStrategy: const DefaultDataStrategy(stackMultipleValues: true),
                      ),
                      itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
                        return const SizedBox();
                      }),
                      backgroundDecorations: [
                        GridDecoration(
                          showVerticalValues: true,
                          verticalLegendPosition: VerticalLegendPosition.bottom,
                          verticalValuesPadding: const EdgeInsets.only(top: 8.0),
                          verticalAxisStep: 2,
                          gridWidth: 1,
                          textStyle: TextStyle(
                            fontFamily: 'roboto',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: AnimatedChart<double>(
                    width: 800 - 80 - 8,
                    duration: const Duration(milliseconds: 450),
                    state: ChartState<double>(
                      data: ChartData(
                        _mappedValues,
                        dataStrategy: const DefaultDataStrategy(stackMultipleValues: true),
                      ),
                      itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(color: Colors.blue.withOpacity(0.2)),
                            Positioned(
                              top: -24,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Center(child: Text(_mappedValues[data.listIndex][data.itemIndex].max.toString()))
                                ],
                              ),
                            ),
                            Positioned(
                              top: -5,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.4),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      foregroundDecorations: [],
                      backgroundDecorations: [
                        GridDecoration(
                          horizontalAxisStep: 2,
                          showVerticalGrid: false,
                          showVerticalValues: true,
                          verticalLegendPosition: VerticalLegendPosition.bottom,
                          verticalValuesPadding: const EdgeInsets.only(top: 8.0),
                          verticalAxisStep: 1,
                          dashArray: [8, 8],
                          gridWidth: 1,
                          textStyle: TextStyle(
                            fontFamily: 'roboto',
                            color: Colors.black87,
                          ),
                        ),
                        WidgetDecoration(
                          widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
                            return Padding(
                              padding: (chartState.defaultMargin + chartState.defaultPadding),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: 0,
                                    left: 0,
                                    bottom: verticalMultiplier * 3.6,
                                    child: CustomPaint(painter: DashedLinePainter()),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        TargetAreaDecoration(
                          targetAreaFillColor: Colors.red.withOpacity(0.6),
                          targetLineColor: Colors.transparent,
                          lineWidth: 0,
                          targetMax: 2.0,
                          targetMin: 0,
                        ),
                        SparkLineDecoration(
                          lineWidth: 2,
                          lineColor: Colors.blue,
                          smoothPoints: true,
                          listIndex: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 8, dashSpace = 8, startX = 0;
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
