import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartDecorationsPresenter = ChangeNotifierProvider((ref) => ChartDecorationsPresenter(ref));

class ChartDecorationsPresenter extends ChangeNotifier {
  ChartDecorationsPresenter(this.ref);

  final Ref ref;

  final List<DecorationPainter> foregroundDecorations = [];
  final List<DecorationPainter> backgroundDecorations = [];

  void addForegroundDecorations(DecorationPainter decoration) {
    final index = foregroundDecorations.length;

    foregroundDecorations.add(ref.read(decorationSparkLinePresenter(index)).buildDecoration());

    final _listener = ref.read(decorationSparkLinePresenter(index)).addListener(() {
      foregroundDecorations[index] = ref.read(decorationSparkLinePresenter(index)).buildDecoration();
      notifyListeners();
    });

    notifyListeners();
  }
}
