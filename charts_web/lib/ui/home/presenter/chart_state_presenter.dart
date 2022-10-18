import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartStatePresenter = ChangeNotifierProvider((ref) {
  return ChartStatePresenter(ref);
});

const _itemBorderSideDefault = BorderSide.none;
const _barBorderRadiusDefault = BorderRadius.zero;

class ChartStatePresenter extends ChangeNotifier {
  ChartStatePresenter(this.ref) {
    _decorationsPresenter =  ref.read(chartDecorationsPresenter);
    ref.read(chartDecorationsPresenter).addListener(() {
      notifyListeners();
    });
    // _ref.listen(chartDecorationsPresenter);
  }

  final Ref ref;
  late ChartDecorationsPresenter _decorationsPresenter;

  // data
  List<List<ChartItem<void>>> _data = [
    [4, 6, 3, 6, 7, 9, 3, 2].map((e) => BarValue(e.toDouble())).toList(),
  ];
  List<Color> listColors = [_presetColors[0]];

  DataStrategy _strategy = const DefaultDataStrategy();

  // Items
  EdgeInsets chartItemPadding = const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 0);
  SelectedPainter selectedPainter = SelectedPainter.bar;
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

  ChartState<void> get state => ChartState(
        _defaultData,
        itemOptionsBuilder: _getItemOptions,
        behaviour: _behaviour,
        foregroundDecorations: _decorationsPresenter.foregroundDecorations.values.toList(),
        backgroundDecorations: _decorationsPresenter.backgroundDecorations.values.toList(),
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

    _decorationsPresenter.removeDecorationsDependentOnData(listIndex);

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

  void updateChartBehaviour(ChartBehaviour behaviour) {
    _behaviour = behaviour;
    notifyListeners();
  }

  void updateItemPainter(SelectedPainter painter) {
    selectedPainter = painter;
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
    if (selectedPainter == SelectedPainter.bubble) {
      return BubbleItemOptions(
        padding: chartItemPadding,
        color: _getColorForKey(index),
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiItemStack: multiItemStack,
        multiValuePadding: multiValuePadding,
        gradient: gradient[index],
        border: itemBorderSides[index],
      );
    } else if (selectedPainter == SelectedPainter.bar) {
      return BarItemOptions(
        padding: chartItemPadding,
        color: _getColorForKey(index),
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiItemStack: multiItemStack,
        multiValuePadding: multiValuePadding,
        gradient: gradient[index],
        radius: barBorderRadius[index],
        border: itemBorderSides[index],
      );
    } else if (selectedPainter == SelectedPainter.none) {
      return const BubbleItemOptions(
        color: Colors.transparent,
        maxBarWidth: 0,
        minBarWidth: 0,
      );
    } else {
      throw 'Not implemeneted';
    }
  }

  Color _getColorForKey(int key) {
    return listColors[key % 5];
  }
}

enum SelectedPainter {
  bar, bubble, none, widget
}

const _presetColors = [
  Color(0xFFD8555F),
  Color(0xFFD9A866),
  Color(0xFF916794),
  Color(0xFF6479C3),
  Color(0xFF5A8772),
];
