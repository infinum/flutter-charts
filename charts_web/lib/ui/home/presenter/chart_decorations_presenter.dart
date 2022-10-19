import 'dart:async';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

final chartDecorationsPresenter = ChangeNotifierProvider((ref) => ChartDecorationsPresenter(ref));

class ChartDecorationsPresenter extends ChangeNotifier {
  ChartDecorationsPresenter(this.ref);

  final Ref ref;

  /// We have unique id for each decoration, so we use this to track which IDs are taken
  int _decorationIndexIncrement = 0;

  final Map<int, DecorationPainter> foregroundDecorations = {};
  final Map<int, DecorationPainter> backgroundDecorations = {};

  void addForegroundDecorations(DecorationPainter decoration) {
    final index = getNewAutoIncrementDecorationIndex();

    foregroundDecorations[index] = ref.read(decorationSparkLinePresenter(index)).buildDecoration();

    ref.read(decorationSparkLinePresenter(index)).addListener(() => registerNewListener(index));

    notifyListeners();
  }

  void removeDecorationsDependentOnData(int lineIndex) {
    final decorationsIndexToRemove = <int>[];

    foregroundDecorations.forEach((decorationIndex, element) {
      if (element is SparkLineDecoration) {
        if (element.lineArrayIndex == lineIndex) {
          decorationsIndexToRemove.add(decorationIndex);
          ref.read(decorationSparkLinePresenter(decorationIndex)).dispose();
        }
      }
    });

    for (final decorationIndex in decorationsIndexToRemove) {
      foregroundDecorations.removeWhere((e, _) => e == decorationIndex);
    }

    notifyListeners();
  }

  void removeDecoration(int decorationIndex) {
    foregroundDecorations.removeWhere((e, _) => e == decorationIndex);
    notifyListeners();
  }

  int getNewAutoIncrementDecorationIndex() {
    final index = _decorationIndexIncrement;
    _decorationIndexIncrement++;
    return index;
  }

  void registerNewListener(int index) {
    foregroundDecorations[index] = ref.read(decorationSparkLinePresenter(index)).buildDecoration();
    notifyListeners();
  }
}
