import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final decorationSparkLinePresenter =
    ChangeNotifierProvider.family<DecorationSparkLinePresenter, int>((ref, a) => DecorationSparkLinePresenter(a, ref));

class DecorationSparkLinePresenter extends ChangeNotifier {
  DecorationSparkLinePresenter(this.index, Ref ref) {
    color = ref.read(chartStatePresenter).listColors.first;
  }

  final int index;
  SparkLineDecoration decoration = SparkLineDecoration();

  bool filled = false;
  bool smoothPoints = false;

  late Color color;
  LinearGradient? gradient;

  // bool stretchLine = false;

  void updateFilled(bool value) {
    filled = value;
    notifyListeners();
  }

  void updateSmoothPoints(bool value) {
    smoothPoints = value;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    color = newColor;
    notifyListeners();
  }

  void updateGradient(LinearGradient? newGradient) {
    gradient = newGradient;
    notifyListeners();
  }

  SparkLineDecoration buildDecoration() {
    return SparkLineDecoration(fill: filled, smoothPoints: smoothPoints, lineColor: color, gradient: gradient);
  }
}
