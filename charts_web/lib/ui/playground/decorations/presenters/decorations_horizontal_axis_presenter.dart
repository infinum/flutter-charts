import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presenter/chart_decorations_presenter.dart';

final decorationHorizontalAxisPresenter =
    ChangeNotifierProvider.family<DecorationHorizontalAxisPresenter, int>(
        (ref, a) => DecorationHorizontalAxisPresenter(a, ref));

class DecorationHorizontalAxisPresenter extends ChangeNotifier
    implements DecorationBuilder {
  DecorationHorizontalAxisPresenter(this.index, Ref ref);

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
  HorizontalAxisDecoration buildDecoration() {
    return HorizontalAxisDecoration(
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
  void writeDecorationSource(SourceWriter writer) {
    writer.open('HorizontalAxisDecoration(');
    // The presenter always sets a non-default text scale.
    writer.line('textScale: 1.2,');
    if (!showLines) writer.line('showLines: false,');
    if (showValues) writer.line('showValues: true,');
    if (endWithChart) writer.line('endWithChart: true,');
    if (lineWidth != 1.0) {
      writer.line('lineWidth: ${doubleLiteral(lineWidth)},');
    }
    if (axisStep != 1.0) {
      writer.line('axisStep: ${doubleLiteral(axisStep)},');
    }
    writer.line('lineColor: ${colorLiteral(lineColor)},');
    writer.close('),');
  }
}
