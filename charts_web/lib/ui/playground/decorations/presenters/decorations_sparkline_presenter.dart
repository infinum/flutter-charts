import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final decorationSparkLinePresenter =
    ChangeNotifierProvider.family<DecorationSparkLinePresenter, int>(
        (ref, a) => DecorationSparkLinePresenter(a, ref));

class DecorationSparkLinePresenter extends ChangeNotifier
    implements DecorationBuilder {
  DecorationSparkLinePresenter(this.index, Ref ref) {
    color = ref.read(chartStatePresenter).listColors.first;
  }

  int lineId = 0;

  final int index;

  bool filled = false;
  bool smoothPoints = false;
  double lineWidth = 1.0;
  double startPosition = 0.5;

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

  void updateId(int newLineId) {
    lineId = newLineId;
    notifyListeners();
  }

  void updateLineWidth(double newLineWidth) {
    lineWidth = newLineWidth;
    notifyListeners();
  }

  void updateStartPosition(double startPosition) {
    this.startPosition = startPosition;
    notifyListeners();
  }

  @override
  SparkLineDecoration buildDecoration() {
    return SparkLineDecoration(
      listIndex: lineId,
      fill: filled,
      smoothPoints: smoothPoints,
      lineColor: color,
      lineWidth: lineWidth,
      gradient: gradient,
      startPosition: startPosition,
    );
  }

  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('SparkLineDecoration(');
    if (lineId != 0) writer.line('listIndex: $lineId,');
    if (filled) writer.line('fill: true,');
    if (smoothPoints) writer.line('smoothPoints: true,');
    writer.line('lineColor: ${colorLiteral(color)},');
    if (lineWidth != 1.0) {
      writer.line('lineWidth: ${doubleLiteral(lineWidth)},');
    }
    if (startPosition != 0.5) {
      writer.line('startPosition: ${doubleLiteral(startPosition)},');
    }
    final currentGradient = gradient;
    if (currentGradient != null) {
      writer.line('gradient: ${gradientLiteral(currentGradient)},');
    }
    writer.close('),');
  }
}
