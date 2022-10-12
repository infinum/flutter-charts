import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final chartStatePresenter = ChangeNotifierProvider((_) => ChartStatePresenter());

const _itemBorderSideDefault = BorderSide.none;
const _barBorderRadiusDefault = BorderRadius.zero;

class ChartStatePresenter extends ChangeNotifier {
  // data
  List<List<ChartItem<void>>> _data = [
    [4, 6, 3, 6, 7, 9, 3, 2].map((e) => BarValue(e.toDouble())).toList(),
  ];
  List<Color> listColors = [_presetColors[0]];

  DataStrategy _strategy = const DefaultDataStrategy();

  // Items
  EdgeInsets chartItemPadding = const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 0);
  bool bubbleItemPainter = false;
  double? maxBarWidth;
  double? minBarWidth;
  List<BorderSide> itemBorderSides = [_itemBorderSideDefault];
  Map<int, LinearGradient> gradient = {};
  // bar item specific
  List<BorderRadius> barBorderRadius = [_barBorderRadiusDefault];
  // multi item specific
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
        itemOptionsBuilder: _getItemOptions,
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

    /// Add all per-value collections
    listColors.add(_presetColors[_data.length - 1]);
    barBorderRadius.add(_barBorderRadiusDefault);
    itemBorderSides.add(_itemBorderSideDefault);

    notifyListeners();
  }

  void removeDataList(int listIndex) {
    listColors.removeAt(listIndex);
    data.removeAt(listIndex);
    barBorderRadius.removeAt(listIndex);
    itemBorderSides.removeAt(listIndex);

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

  void updateBarBorderRadius(BorderRadius newValue, int index) {
    barBorderRadius[index] = newValue;
    notifyListeners();
  }

  void updateItemBorderSide(BorderSide newSize, int index) {
    itemBorderSides[index] = newSize;
    notifyListeners();
  }

  void updateGradient(LinearGradient? newGradient, int index) {
    if (newGradient == null) {
      gradient.removeWhere((key, value) => key == index);
    } else {
      gradient[index] = newGradient;
    }
    notifyListeners();
  }

  ItemOptions _getItemOptions(int index) {
    if (bubbleItemPainter) {
      return BubbleItemOptions(
        padding: chartItemPadding,
        colorForKey: _getColorForKey,
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiItemStack: multiItemStack,
        multiValuePadding: multiValuePadding,
        gradient: gradient[index],
        border: itemBorderSides[index],
      );
    } else {
      return BarItemOptions(
        padding: chartItemPadding,
        colorForKey: _getColorForKey,
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiItemStack: multiItemStack,
        multiValuePadding: multiValuePadding,
        gradient: gradient[index],
        radius: barBorderRadius[index],
        border: itemBorderSides[index],
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
