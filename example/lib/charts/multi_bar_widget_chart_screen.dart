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
  _MultiBarWidgetChartScreenState createState() => _MultiBarWidgetChartScreenState();
}

class _MultiBarWidgetChartScreenState extends State<MultiBarWidgetChartScreen> {
  Map<int, List<BarValue<void>>> _values = <int, List<BarValue<void>>>{};
  double targetMax = 0;
  double targetMin = 0;
  bool _showValues = false;
  int minItems = 2;
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
    targetMax = 5 + ((_rand.nextDouble() * _difference * 0.75) - (_difference * 0.25)).roundToDouble();
    _values.addAll(Map<int, List<BarValue<void>>>.fromEntries(List.generate(3, (key) {
      return MapEntry(
          key,
          List.generate(minItems, (index) {
            return BarValue<void>(targetMax * 0.4 + _rand.nextDouble() * targetMax * 0.9);
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

            return BarValue<void>(targetMax * 0.4 + Random().nextDouble() * targetMax * 0.9);
          }));
    }));
  }

  List<List<BarValue<void>>> _getMap() {
    return [
      _values[0]!
          .asMap()
          .map<int, BarValue<void>>((index, e) {
            return MapEntry(index, BarValue<void>(e.max ?? 0.0));
          })
          .values
          .toList(),
      _values[1]!
          .asMap()
          .map<int, BarValue<void>>((index, e) {
            return MapEntry(index, BarValue<void>(e.max ?? 0.0));
          })
          .values
          .toList(),
      _values[2]!.toList()
    ];
  }

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
              child: BarChart.map(
                _getMap(),
                stack: _stackItems,
                height: MediaQuery.of(context).size.height * 0.4,
                itemOptions: WidgetItemOptions(
                    multiItemStack: _stackItems,
                    chartItemBuilder: (item, itemKey, listKey) {
                      final _images = [
                        'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.LxlHIr73N2FnqJ3t0TEn-gHaFr%26pid%3DApi&f=1&ipt=afa66b22e9421c69abbb25704c5e4bcb39e4799643ebbdedcabf90ab8af40a6f&ipo=images',
                        'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimages3.alphacoders.com%2F283%2F28305.jpg&f=1&nofb=1&ipt=901963091e95b05a0e8de0829ed79cfb7a310a1c45c155f3a7e5bb9d299b4a56&ipo=images',
                        'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2F66.media.tumblr.com%2F737584aa0cc9d02de5a24bb151f57b53%2Ftumblr_inline_o8xhyaVYPH1sss5ih_1280.png&f=1&nofb=1&ipt=d00e38cf1c3af3a8e42ba24f516da8d696495d9b989a77beedb04d7534c8fb9d&ipo=images',
                      ];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular((!_stackItems || listKey == 0) ? 12 : 0)),
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular((!_stackItems || listKey == 0) ? 12 : 0)),
                          color: Colors.accents[listKey].withOpacity(0.2),
                          border: Border.all(
                            width: 2,
                            color: Colors.accents[listKey],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular((!_stackItems || listKey == 0) ? 12 : 0)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  _images[listKey],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8.0,
                                left: 0.0,
                                right: 0.0,
                                child: Text(
                                  '${item.max?.toStringAsFixed(2)}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
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
                    showTopHorizontalValue: _legendOnBottom ? _showValues : false,
                    horizontalLegendPosition:
                        _legendOnEnd ? HorizontalLegendPosition.end : HorizontalLegendPosition.start,
                    verticalLegendPosition:
                        _legendOnBottom ? VerticalLegendPosition.bottom : VerticalLegendPosition.top,
                    textStyle: Theme.of(context).textTheme.caption,
                    gridColor: Theme.of(context).colorScheme.primaryVariant.withOpacity(0.2),
                  ),
                ],
                foregroundDecorations: [
                  BorderDecoration(),
                ],
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
                      return MapEntry(key, value..removeRange(value.length - 4, value.length));
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
