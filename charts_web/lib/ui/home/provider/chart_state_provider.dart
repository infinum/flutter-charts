import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartStateProvider = ChangeNotifierProvider((_) => ChartStateProvider());

class ChartStateProvider extends ChangeNotifier {
  ChartData<void> _defaultData = ChartData.randomBarValues(
    valueAxisMaxOver: 2.0,
  );

  ItemOptions _itemOptions = const BarItemOptions(
    color: Color(0xFFD8555F),
    padding: EdgeInsets.symmetric(horizontal: 2.0),
  );

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
