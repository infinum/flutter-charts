import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_label_color_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final decorationGridPresenter =
    ChangeNotifierProvider.family<DecorationGridPresenter, int>(
        (ref, a) => DecorationGridPresenter(a, ref));

/// `GridDecoration` is the merge of the two axis decorations, and the most
/// common backdrop in the gallery, so the playground needs it to be able to
/// reproduce those examples.
class DecorationGridPresenter extends ChangeNotifier
    implements DecorationBuilder {
  DecorationGridPresenter(this.index, this._ref) {
    _ref.listen(chartLabelColorProvider, (_, __) => notifyListeners());
    _ref.listen(chartGridColorProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  final int index;

  bool showHorizontalGrid = true;
  bool showVerticalGrid = true;
  bool showHorizontalValues = false;
  bool showVerticalValues = false;
  bool dashed = false;
  double gridWidth = 1.0;
  double horizontalAxisStep = 1.0;
  double verticalAxisStep = 1.0;
  double textScale = 1.0;

  /// Null follows the theme; set means the user picked a colour.
  Color? gridColorOverride;

  Color get gridColor => gridColorOverride ?? _ref.read(chartGridColorProvider);

  void updateShowHorizontalGrid(bool value) {
    showHorizontalGrid = value;
    notifyListeners();
  }

  void updateShowVerticalGrid(bool value) {
    showVerticalGrid = value;
    notifyListeners();
  }

  void updateShowHorizontalValues(bool value) {
    showHorizontalValues = value;
    notifyListeners();
  }

  void updateShowVerticalValues(bool value) {
    showVerticalValues = value;
    notifyListeners();
  }

  void updateDashed(bool value) {
    dashed = value;
    notifyListeners();
  }

  void updateGridWidth(double value) {
    gridWidth = value;
    notifyListeners();
  }

  void updateHorizontalAxisStep(double value) {
    horizontalAxisStep = value;
    notifyListeners();
  }

  void updateVerticalAxisStep(double value) {
    verticalAxisStep = value;
    notifyListeners();
  }

  void updateTextScale(double value) {
    textScale = value;
    notifyListeners();
  }

  void updateColor(Color value) {
    gridColorOverride = value;
    notifyListeners();
  }

  /// Same reason as the axis decorations: the chart paints this text itself,
  /// so it cannot inherit the app's text theme.
  TextStyle get _textStyle =>
      TextStyle(fontSize: 12, color: _ref.read(chartLabelColorProvider));

  List<double>? get _dashArray => dashed ? const [4, 4] : null;

  @override
  GridDecoration buildDecoration() {
    return GridDecoration(
      showHorizontalGrid: showHorizontalGrid,
      showVerticalGrid: showVerticalGrid,
      showHorizontalValues: showHorizontalValues,
      showVerticalValues: showVerticalValues,
      gridColor: gridColor,
      gridWidth: gridWidth,
      horizontalAxisStep: horizontalAxisStep,
      verticalAxisStep: verticalAxisStep,
      textScale: textScale,
      dashArray: _dashArray,
      textStyle: _textStyle,
    );
  }

  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('GridDecoration(');
    if (!showHorizontalGrid) writer.line('showHorizontalGrid: false,');
    if (!showVerticalGrid) writer.line('showVerticalGrid: false,');
    if (showHorizontalValues) writer.line('showHorizontalValues: true,');
    if (showVerticalValues) writer.line('showVerticalValues: true,');
    writer.line('gridColor: ${colorLiteral(gridColor)},');
    if (gridWidth != 1.0) {
      writer.line('gridWidth: ${doubleLiteral(gridWidth)},');
    }
    if (horizontalAxisStep != 1.0) {
      writer.line('horizontalAxisStep: ${doubleLiteral(horizontalAxisStep)},');
    }
    if (verticalAxisStep != 1.0) {
      writer.line('verticalAxisStep: ${doubleLiteral(verticalAxisStep)},');
    }
    if (textScale != 1.0) {
      writer.line('textScale: ${doubleLiteral(textScale)},');
    }
    if (dashed) writer.line('dashArray: [4.0, 4.0],');
    if (showHorizontalValues || showVerticalValues) {
      writer.line('// Grid labels are painted by the chart, so they need an');
      writer.line('// explicit colour for your background.');
      writer.line('textStyle: TextStyle(fontSize: 12.0, '
          'color: ${colorLiteral(_ref.read(chartLabelColorProvider))}),');
    }
    writer.close('),');
  }
}
