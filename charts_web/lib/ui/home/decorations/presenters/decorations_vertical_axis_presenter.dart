import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presenter/chart_decorations_presenter.dart';

final decorationVerticalAxisPresenter =
    ChangeNotifierProvider.family<DecorationVerticalAxisPresenter, int>(
        (ref, a) => DecorationVerticalAxisPresenter(a, ref));

class DecorationVerticalAxisPresenter extends ChangeNotifier
    implements DecorationBuilder {
  DecorationVerticalAxisPresenter(this.index, Ref ref);

  int lineId = 0;

  final int index;

  bool showLines = true;
  bool showValues = false;
  bool endWithChart = false;
  double lineWidth = 1.0;
  double axisStep = 1.0;
  Color lineColor = Colors.grey;

  void updateShowLines(bool value) {
    showLines = value;
    notifyListeners();
  }

  void updateShowValues(bool value) {
    showValues = value;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    lineColor = newColor;
    notifyListeners();
  }

  void updateAxisStep(double newAxisStep) {
    axisStep = newAxisStep;
    notifyListeners();
  }

  void updateLineWidth(double newLineWidth) {
    lineWidth = newLineWidth;
    notifyListeners();
  }

  void updateEndWithChart(bool value) {
    endWithChart = value;
    notifyListeners();
  }

  @override
  VerticalAxisDecoration buildDecoration() {
    return VerticalAxisDecoration(
      showLines: showLines,
      textScale: 1.2,
      showValues: showValues,
      endWithChart: endWithChart,
      lineWidth: lineWidth,
      axisStep: axisStep,
      lineColor: lineColor,
    );
  }

  @override
  String buildDecorationCode() {
    return '''    VerticalAxisDecoration(
      showLines: $showLines,
      textScale: 1.2,
      showValues: $showValues,
      endWithChart: $endWithChart,
      lineWidth: $lineWidth,
      axisStep: $axisStep,
      lineColor: ${colorToCode(lineColor)},
    ),
    ''';
  }
}
