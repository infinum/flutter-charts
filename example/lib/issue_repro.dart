import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

const double axisWidth = 80.0;

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: LineChart(),
    ),
  ));
}

class LineChart extends StatelessWidget {
  final bool useAxis;

  LineChart({Key? key, this.useAxis = true}) : super(key: key);

  final List<List<ChartItem<double>>> _mappedValues = [
    [ChartItem(2.0), ChartItem(5.0), ChartItem(8.0), ChartItem(3.0), ChartItem(6.0)]
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: axisWidth,
              child: DecorationsRenderer(
                [
                  HorizontalAxisDecoration(
                    asFixedDecoration: true,
                    lineWidth: 0,
                    axisStep: 2,
                    showValues: true,
                    endWithChart: false,
                    axisValue: (value) => '$value',
                    legendFontStyle: Theme.of(context).textTheme.bodyMedium,
                    valuesAlign: TextAlign.center,
                    valuesPadding: const EdgeInsets.only(left: -axisWidth, bottom: -10),
                    showLines: false,
                    showTopValue: true,
                  )
                ],
                ChartState<double>(
                  data: ChartData(
                    _mappedValues,
                    axisMin: useAxis ? 2 : null,
                    axisMax: useAxis ? 8 : null,
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
                      textStyle: Theme.of(context).textTheme.labelSmall,
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
                width: MediaQuery.of(context).size.width - axisWidth - 8,
                duration: const Duration(milliseconds: 450),
                state: ChartState<double>(
                  data: ChartData(
                    _mappedValues,
                    axisMin: useAxis ? 2 : null,
                    axisMax: useAxis ? 8 : null,
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
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      border: Border.all(width: 1.4, color: Theme.of(context).colorScheme.surface)),
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
                      gridColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      dashArray: [8, 8],
                      gridWidth: 1,
                      textStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    WidgetDecoration(
                      widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
                        return Padding(
                          padding: chartState.defaultMargin,
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
                      targetAreaFillColor: Theme.of(context).colorScheme.error.withOpacity(0.6),
                      targetLineColor: Colors.transparent,
                      lineWidth: 0,
                      targetMax: 2,
                      targetMin: 0,
                    ),
                    SparkLineDecoration(
                      lineWidth: 2,
                      lineColor: Theme.of(context).colorScheme.primary,
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
    );
  }
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
