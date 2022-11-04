import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:example/widgets/chart_options.dart';
import 'package:example/widgets/toggle_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/bar_chart.dart';

class MultiBarWidgetChartScreen extends StatefulWidget {
  MultiBarWidgetChartScreen({Key? key}) : super(key: key);

  @override
  _MultiBarWidgetChartScreenState createState() =>
      _MultiBarWidgetChartScreenState();
}

class _MultiBarWidgetChartScreenState extends State<MultiBarWidgetChartScreen> {
  Map<int, List<ChartItem<void>>> _values = <int, List<ChartItem<void>>>{};
  double targetMax = 0;
  double targetMin = 0;
  bool _showValues = false;
  int minItems = 4;
  bool _legendOnEnd = true;
  bool _legendOnBottom = true;
  bool _stackItems = true;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    final Random _rand = Random();
    final double _difference = _rand.nextDouble() * 10;
    targetMax = 5 +
        ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25))
            .roundToDouble();
    _values.addAll(
        Map<int, List<ChartItem<void>>>.fromEntries(List.generate(3, (key) {
      return MapEntry(
          key,
          List.generate(minItems, (index) {
            return ChartItem<void>(
                targetMax * 0.4 + _rand.nextDouble() * targetMax * 0.9);
          }));
    })));
    targetMin = targetMax - ((_rand.nextDouble() * 3) + (targetMax * 0.2));
  }

  void _addValues() {
    _values = Map.fromEntries(List.generate(3, (key) {
      return MapEntry(
          key,
          List.generate(minItems, (index) {
            if (_values[key]!.length > index) {
              return _values[key]![index];
            }

            return BarValue<void>(
                targetMax * 0.4 + Random().nextDouble() * targetMax * 0.9);
          }));
    }));
  }

  List<List<ChartItem<void>>> _getMap() {
    return [
      _values[0]!
          .asMap()
          .map<int, ChartItem<void>>((index, e) {
            return MapEntry(index, ChartItem<void>(e.max ?? 0.0));
          })
          .values
          .toList(),
      _values[1]!
          .asMap()
          .map<int, ChartItem<void>>((index, e) {
            return MapEntry(index, ChartItem<void>(e.max ?? 0.0));
          })
          .values
          .toList(),
      _values[2]!.toList()
    ];
  }

  final _images = [
    'assets/png/futurama1.jpeg',
    'assets/png/futurama2.jpeg',
    'assets/png/futurama4.jpeg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multi bar widget chart',
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Chart(
                height: MediaQuery.of(context).size.height * 0.4,
                state: ChartState<void>(
                  data: ChartData(_getMap(),
                      dataStrategy: _stackItems
                          ? StackDataStrategy()
                          : DefaultDataStrategy(stackMultipleValues: false)),
                  itemOptions: WidgetItemOptions(widgetItemBuilder: (data) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                (!_stackItems || data.listIndex == 0)
                                    ? 12
                                    : 0)),
                      ),
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                (!_stackItems || data.listIndex == 0)
                                    ? 12
                                    : 0)),
                        color: Colors.accents[data.listIndex].withOpacity(0.2),
                        border: Border.all(
                          width: 2,
                          color: Colors.accents[data.listIndex],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                (!_stackItems || data.listIndex == 0)
                                    ? 12
                                    : 0)),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                _images[data.listIndex],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8.0,
                              left: 0.0,
                              right: 0.0,
                              child: Text(
                                '${data.item.max?.toStringAsFixed(2)}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  backgroundDecorations: [
                    GridDecoration(
                      showVerticalGrid: true,
                      showHorizontalValues: _showValues,
                      showVerticalValues: _showValues,
                      showTopHorizontalValue:
                          _legendOnBottom ? _showValues : false,
                      horizontalLegendPosition: _legendOnEnd
                          ? HorizontalLegendPosition.end
                          : HorizontalLegendPosition.start,
                      verticalLegendPosition: _legendOnBottom
                          ? VerticalLegendPosition.bottom
                          : VerticalLegendPosition.top,
                      textStyle: Theme.of(context).textTheme.caption,
                      gridColor: Theme.of(context)
                          .colorScheme
                          .primaryVariant
                          .withOpacity(0.2),
                    ),
                  ],
                  foregroundDecorations: [
                    BorderDecoration(),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: ChartOptionsWidget(
              onRefresh: () {
                setState(() {
                  _values.clear();
                  _updateValues();
                });
              },
              onAddItems: () {
                setState(() {
                  minItems += 2;
                  _addValues();
                });
              },
              onRemoveItems: () {
                setState(() {
                  if (minItems > 2) {
                    minItems -= 2;
                    _values = _values.map((key, value) {
                      return MapEntry(key,
                          value..removeRange(value.length - 4, value.length));
                    });
                  }
                });
              },
              toggleItems: [
                ToggleItem(
                  title: 'Axis values',
                  value: _showValues,
                  onChanged: (value) {
                    setState(() {
                      _showValues = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _legendOnEnd,
                  title: 'Legend on end',
                  onChanged: (value) {
                    setState(() {
                      _legendOnEnd = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _legendOnBottom,
                  title: 'Legend on bottom',
                  onChanged: (value) {
                    setState(() {
                      _legendOnBottom = value;
                    });
                  },
                ),
                ToggleItem(
                  value: _stackItems,
                  title: 'Stack items',
                  onChanged: (value) {
                    setState(() {
                      _stackItems = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
