import 'package:charts_painter/chart.dart';
import 'package:example/widgets/bar_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _batteryData = [
  26,
  24,
  25,
  45,
  60,
  75,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  80,
  84,
  88,
  92,
  98,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  100,
  95,
  92,
  90,
  90,
  88,
  88,
  86,
  86,
  86,
  86,
  85
];

class IosChartScreen extends StatefulWidget {
  IosChartScreen({Key? key}) : super(key: key);

  @override
  _IosChartScreenState createState() => _IosChartScreenState();
}

class _IosChartScreenState extends State<IosChartScreen> {
  int _currentState = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Apple battery chart',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: SizedBox(
                height: 180,
                child: BarChart(
                  data: _batteryData
                      .map((e) => BarValue<void>(e.toDouble()))
                      .toList(),
                  height: MediaQuery.of(context).size.height * 0.18,
                  dataToValue: (BarValue value) => value.max ?? 0.0,
                  itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    minBarWidth: 4.0,
                    barItemBuilder: (data) {
                      return BarItem(
                        radius: const BorderRadius.vertical(
                          top: Radius.circular(24.0),
                        ),
                        color: CupertinoColors.systemGreen,
                      );
                    },
                  ),
                  backgroundDecorations: [
                    WidgetDecoration(
                      margin: const EdgeInsets.only(bottom: 12),
                      widgetDecorationBuilder:
                          (context, state, squareWidth, squareHeight) {
                        return Container(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: (state.defaultMargin +
                                          state.defaultPadding)
                                      .copyWith(bottom: 0),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // First (Smaller) green rectangle area
                                      Positioned(
                                        top: 2.0,
                                        bottom: 36.0,
                                        left: squareWidth * 2,
                                        width: squareWidth * 4,
                                        child: Container(
                                          color: CupertinoColors.activeGreen
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      // Second (Bigger) green rectangle area
                                      Positioned(
                                        top: 2.0,
                                        bottom: 36.0,
                                        left: squareWidth * 20,
                                        width: squareWidth * 20,
                                        child: Container(
                                          color: CupertinoColors.activeGreen
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      // Bottom battery state indicator (green)
                                      Positioned(
                                        bottom: 30.0,
                                        height: 24.0,
                                        left: squareWidth * 2,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              height: 6.0,
                                              width: squareWidth * 4,
                                              decoration: ShapeDecoration(
                                                shape: StadiumBorder(),
                                                color:
                                                    CupertinoColors.systemGreen,
                                              ),
                                            ),
                                            // Indicator with pause icon
                                            Container(
                                              width: squareWidth * 14,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    height: 6,
                                                    bottom: 0,
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape: StadiumBorder(),
                                                        color: CupertinoColors
                                                            .systemGreen
                                                            .withOpacity(0.2),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: -6,
                                                    height: 18,
                                                    child: Center(
                                                      child: Container(
                                                        width: 18,
                                                        height: 18,
                                                        color: Colors.white,
                                                        child: Icon(
                                                          Icons.pause,
                                                          color: CupertinoColors
                                                              .systemGreen,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            // Indicator with charge icon
                                            Container(
                                              width: squareWidth * 20,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    height: 6,
                                                    bottom: 0,
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape: StadiumBorder(),
                                                        color: CupertinoColors
                                                            .systemGreen,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: -6,
                                                    height: 18,
                                                    child: Center(
                                                      child: Container(
                                                        width: 18,
                                                        height: 18,
                                                        color: Colors.white,
                                                        child: Icon(
                                                          Icons
                                                              .electric_bolt_outlined,
                                                          color: CupertinoColors
                                                              .systemGreen,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GridDecoration(
                      verticalAxisStep: 12,
                      horizontalAxisStep: 25,
                      endWithChartVertical: false,
                      endWithChartHorizontal: true,
                      showHorizontalValues: true,
                      gridWidth: 1.0,
                      gridColor: Colors.grey.shade300,
                      horizontalAxisValueFromValue: (index) =>
                          index % 2 == 0 ? '${index}%' : '',
                      horizontalValuesPadding:
                          const EdgeInsets.only(top: 8.0, left: 4.0),
                      verticalAxisValueFromIndex: (index) =>
                          '${(((index / 4) + 9) % 12).toStringAsFixed(0).padLeft(2, '0').replaceAll('00', '12 A')}',
                      textStyle: TextStyle(color: Colors.grey),
                      verticalTextAlign: TextAlign.start,
                      verticalValuesPadding:
                          const EdgeInsets.only(left: 4, bottom: 18.0),
                      showVerticalValues: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
