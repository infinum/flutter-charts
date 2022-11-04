import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

final _data = [4, 6, 3, 6, 7, 9, 3, 2, 4, 6, 2];

class MigrationChartScreen extends StatelessWidget {
  MigrationChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Migration from 2.0',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: ListView(
                children: [
                  _Header(title: 'Target line decoration'),
                  _buildChartWithDecoration(
                    decoration: WidgetDecoration(widgetDecorationBuilder:
                        (context, chartState, itemWidth, verticalMultiplier) {
                      return Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: verticalMultiplier * 3,
                            child: Container(color: Colors.red, height: 2),
                          ),
                        ],
                      );
                    }),
                  ),
                  _Header(title: 'Target line text decoration'),
                  _buildChartWithDecoration(
                    decoration: WidgetDecoration(
                        widgetDecorationBuilder: (context, chartState,
                            itemWidth, verticalMultiplier) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                top: null,
                                bottom: 2 * verticalMultiplier,
                                child: const RotatedBox(
                                    quarterTurns: 3,
                                    child: Text('This is target line')),
                              ),
                              Positioned.fill(
                                top: null,
                                left: 0,
                                bottom: 2 * verticalMultiplier,
                                child: Container(
                                    color: Colors.red,
                                    width: double.infinity,
                                    height: 2),
                              ),
                            ],
                          );
                        },
                        margin: const EdgeInsets.only(left: 20)),
                  ),
                  _Header(title: 'Target area decoration'),
                  _buildChartWithDecoration(
                    decoration: WidgetDecoration(
                      widgetDecorationBuilder:
                          (context, chartState, itemWidth, verticalMultiplier) {
                        return Padding(
                          padding: EdgeInsets.only(top: 5 * verticalMultiplier),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            width: double.infinity,
                            height: verticalMultiplier * 2,
                          ),
                        );
                      },
                    ),
                  ),
                  _Header(title: 'Border decoration'),
                  _buildChartWithDecoration(
                    decoration: WidgetDecoration(
                        widgetDecorationBuilder: (context, chartState,
                            itemWidth, verticalMultiplier) {
                          return Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red, width: 3)),
                            width: double.infinity,
                            height: double.infinity,
                          );
                        },
                        margin: EdgeInsets.all(3)),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildChartWithDecoration({required DecorationPainter decoration}) {
    return SizedBox(
      width: 450,
      child: Chart(
          state: ChartState<void>(
        data: ChartData(
            [_data.map((e) => ChartItem<void>(e.toDouble())).toList()]),
        itemOptions: BarItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          minBarWidth: 4.0,
          barItemBuilder: (data) {
            return BarItem(
              radius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
              color: Colors.red.withOpacity(0.4),
            );
          },
        ),
        backgroundDecorations: [decoration],
      )),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
