import 'package:charts_painter/chart.dart';
import 'package:example/charts/showcase_chart_screen.dart';
import 'package:flutter/material.dart';

class ShowcaseCharts extends StatelessWidget {
  const ShowcaseCharts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Showcase charts'),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 100.0,
              child: Chart<bool>(
                state: ChartState(
                  data: ChartData(
                    [
                      [
                        ChartItem(10, min: 10),
                        ChartItem(8, min: 8),
                        ChartItem(20, min: 20),
                        ChartItem(18, min: 18),
                        ChartItem(9, min: 9),
                        ChartItem(30, min: 30),
                      ],
                      [
                        ChartItem(18, min: 18),
                        ChartItem(25, min: 25),
                        ChartItem(10, min: 10),
                        ChartItem(24, min: 24),
                        ChartItem(19, min: 19),
                        ChartItem(21, min: 21),
                      ],
                    ],
                    axisMax: 35,
                    dataStrategy:
                        DefaultDataStrategy(stackMultipleValues: true),
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
                      gridColor: Colors.grey.shade400,
                      gridWidth: 0.4,
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
                      lineWidth: 1.0,
                    ),
                    SparkLineDecoration(
                      lineColor: Color(0xFF5B6ACF),
                      lineWidth: 1.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => ShowcaseChartScreen()));
          },
        ),
        Divider(),
      ],
    );
  }
}
