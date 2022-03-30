import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartStateProvider = ChangeNotifierProvider((_) => ChartStateProvider());

class ChartStateProvider extends ChangeNotifier {
  List<List<ChartItem<void>>> _data = [
    [4, 6, 3, 6, 7, 9, 3, 2].map((e) => BarValue(e.toDouble())).toList(),
  ];

  DataStrategy _strategy = DefaultDataStrategy();

  ChartData<void> get _defaultData => ChartData(
        _data,
        dataStrategy: _strategy,
        valueAxisMaxOver: 2.0,
      );

  ItemOptions _itemOptions = BarItemOptions(
      // color: Color(0xFFD8555F),
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      colorForKey: (item, key) => [
            Color(0xFFD8555F),
            Color(0xFFD9A866),
            Color(0xFF916794),
            Color(0xFF6479C3),
            Color(0xFF5A8772),
          ][key % 5]);

  ChartBehaviour _behaviour = const ChartBehaviour();

  final List<DecorationPainter> _foregroundDecorations = [];
  final List<DecorationPainter> _backgroundDecorations = [];

  ChartState<void> get state => ChartState(
        _defaultData,
        itemOptions: _itemOptions,
        behaviour: _behaviour,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: _backgroundDecorations,
      );

  void updateData(List<List<ChartItem<void>>> data) {
    _data = data;
    notifyListeners();
  }

  void updateDataStrategy(DataStrategy dataStrategy) {
    _strategy = dataStrategy;

    // print(_strategy.formatDataStrategy(_data).first);
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

  void updateChartItemOptions(ItemOptions newItemOptions) {
    _itemOptions = newItemOptions;
    notifyListeners();
  }
}
