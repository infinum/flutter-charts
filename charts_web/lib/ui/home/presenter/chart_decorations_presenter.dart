
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartDecorationsPresenter = ChangeNotifierProvider((ref) => ChartDecorationsPresenter());


class ChartDecorationsPresenter extends ChangeNotifier {


  final List<DecorationPainter> foregroundDecorations = [];
  final List<DecorationPainter> backgroundDecorations = [];


  void addForegroundDecorations(DecorationPainter decoration) {
    foregroundDecorations.add(decoration);
    notifyListeners();
  }

}