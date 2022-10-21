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

  final Map<int, _DecorationData> _decorations = {};

  Map<int, DecorationPainter> get foregroundDecorations => _decorationsByLayer(DecorationLayer.foreground);

  Map<int, DecorationPainter> get backgroundDecorations => _decorationsByLayer(DecorationLayer.background);

  void addDecoration(DecorationPainter decoration, {DecorationLayer layer = DecorationLayer.foreground}) {
    final index = getNewAutoIncrementDecorationIndex();

    _decorations[index] = _DecorationData(ref.read(decorationSparkLinePresenter(index)).buildDecoration(), layer);

    ref.read(decorationSparkLinePresenter(index)).addListener(() => registerNewListener(index));

    notifyListeners();
  }

  void moveDecorationToLayer(int decorationIndex, DecorationLayer layer) {
    _decorations[decorationIndex] = _DecorationData(_decorations[decorationIndex]!.decorationPainter, layer);
    notifyListeners();
  }

  DecorationLayer getLayerOfDecoration(int decorationIndex) {
    return _decorations[decorationIndex]!.layer;
  }

  void removeDecorationsDependentOnData(int lineIndex) {
    final decorationsIndexToRemove = <int>[];

    _decorations.forEach((decorationIndex, element) {
      final decoration = element.decorationPainter;
      if (decoration is SparkLineDecoration) {
        if (decoration.lineArrayIndex == lineIndex) {
          decorationsIndexToRemove.add(decorationIndex);
          ref.read(decorationSparkLinePresenter(decorationIndex)).dispose();
        }
      }
    });

    for (final decorationIndex in decorationsIndexToRemove) {
      _decorations.removeWhere((e, _) => e == decorationIndex);
    }

    notifyListeners();
  }

  void removeDecoration(int decorationIndex) {
    _decorations.removeWhere((e, _) => e == decorationIndex);
    notifyListeners();
  }

  int getNewAutoIncrementDecorationIndex() {
    final index = _decorationIndexIncrement;
    _decorationIndexIncrement++;
    return index;
  }

  void registerNewListener(int index) {
    _decorations[index] = _DecorationData(ref.read(decorationSparkLinePresenter(index)).buildDecoration(),
        _decorations.containsKey(index) ? _decorations[index]!.layer : DecorationLayer.foreground);
    notifyListeners();
  }

  Map<int, DecorationPainter> _decorationsByLayer(DecorationLayer layer) {
    final Map<int, DecorationPainter> toReturn = {};

    _decorations.forEach((key, value) {
      if (value.layer == layer) {
        toReturn[key] = value.decorationPainter;
      }
    });

    return toReturn;
  }
}

class _DecorationData {
  _DecorationData(this.decorationPainter, this.layer);

  final DecorationPainter decorationPainter;
  final DecorationLayer layer;
}

enum DecorationLayer { background, foreground }
