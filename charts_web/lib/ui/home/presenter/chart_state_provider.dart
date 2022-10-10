import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartStatePresenter = ChangeNotifierProvider((_) => ChartStatePresenter());

class ChartStatePresenter extends ChangeNotifier {

  // data
  List<List<ChartItem<void>>> _data = [
    [4, 6, 3, 6, 7, 9, 3, 2].map((e) => BarValue(e.toDouble())).toList(),
  ];
  List<Color> listColors = [_presetColors[0]];

  DataStrategy _strategy = const DefaultDataStrategy();

  EdgeInsets chartItemPadding = const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 0);
  bool bubbleItemPainter = false;
  double? maxBarWidth;
  double? minBarWidth;

  // multi item
  bool multiItemStack = true;
  EdgeInsets multiValuePadding = EdgeInsets.zero;
  bool get isMultiItem => _data.length > 1;

  ChartData<void> get _defaultData => ChartData(
        _data,
        dataStrategy: _strategy,
        valueAxisMaxOver: 2.0,
      );

  List<List<ChartItem<void>>> get data => _data;

  ChartBehaviour _behaviour = const ChartBehaviour();

  final List<DecorationPainter> _foregroundDecorations = [];
  final List<DecorationPainter> _backgroundDecorations = [];

  ChartState<void> get state => ChartState(
        _defaultData,
        itemOptions: _getItemOptions,
        behaviour: _behaviour,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: _backgroundDecorations,
      );

  void updateData(List<List<ChartItem<void>>> data) {
    _data = data;
    notifyListeners();
  }

  void addDataList(List<ChartItem<void>> list) {
    _data.add(list);
    listColors.add(_presetColors[_data.length - 1]);
    notifyListeners();
  }

  void removeDataList(int listIndex) {
    listColors.removeAt(listIndex);
    data.removeAt(listIndex);
    notifyListeners();
  }

  void updateListColor(Color color, int listIndex) {
    listColors[listIndex] = color;
    notifyListeners();
  }

  void updateDataStrategy(DataStrategy dataStrategy) {
    _strategy = dataStrategy;
    notifyListeners();
  }

  void addForegroundDecoration(DecorationPainter painter) {
    _foregroundDecorations.add(painter);
    notifyListeners();
  }

  void addBackgroundDecoration(DecorationPainter painter) {
    _backgroundDecorations.add(painter);
    notifyListeners();
  }

  void updateChartBehaviour(ChartBehaviour behaviour) {
    _behaviour = behaviour;
    notifyListeners();
  }

  void updateGeometryRenderer(bool bubble) {
    bubbleItemPainter = bubble;
    notifyListeners();
  }

  void updateChartItemPadding(EdgeInsets newChartItemPadding) {
    chartItemPadding = newChartItemPadding;
    notifyListeners();
  }

  void updateItemWidth({
    double maxItemWidth = -1,
    double minItemWidth = -1,
  }) {
    maxBarWidth = maxItemWidth == -1 ? maxBarWidth : maxItemWidth;
    minBarWidth = minItemWidth == -1 ? minBarWidth : minItemWidth;
  }

  void updateMinBarWidth(double newMinBarWidth) {
    minBarWidth = newMinBarWidth;
    notifyListeners();
  }

  void updateMaxBarWidth(double newMaxBarWidth) {
    maxBarWidth = newMaxBarWidth;
    notifyListeners();
  }

  void updateMultiItemStack(bool newValue) {
    multiItemStack = newValue;
    notifyListeners();
  }

  void updateMultiValuePadding(EdgeInsets newPadding) {
    multiValuePadding = newPadding;
    notifyListeners();
  }

  ItemOptions get _getItemOptions {
    if (bubbleItemPainter) {
      return BubbleItemOptions(
        padding: chartItemPadding,
        colorForKey: _getColorForKey,
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiItemStack: multiItemStack,
        multiValuePadding: multiValuePadding,
      );
    } else {
      return BarItemOptions(
        padding: chartItemPadding,
        colorForKey: _getColorForKey,
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiItemStack: multiItemStack,
        multiValuePadding: multiValuePadding,
      );
    }
  }

  Color _getColorForKey(ChartItem item, int key) {
    return listColors[key % 5];
  }
}


const _presetColors = [
  Color(0xFFD8555F),
  Color(0xFFD9A866),
  Color(0xFF916794),
  Color(0xFF6479C3),
  Color(0xFF5A8772),
];
