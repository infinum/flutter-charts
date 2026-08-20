import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_label_color_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final decorationHorizontalAxisPresenter =
    ChangeNotifierProvider.family<DecorationHorizontalAxisPresenter, int>(
        (ref, a) => DecorationHorizontalAxisPresenter(a, ref));

class DecorationHorizontalAxisPresenter extends ChangeNotifier
    implements DecorationBuilder {
  DecorationHorizontalAxisPresenter(this.index, this._ref) {
    // Rebuild when the app theme changes, so axis labels stay readable.
    _ref.listen(chartLabelColorProvider, (_, __) => notifyListeners());
    _ref.listen(chartGridColorProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  int lineId = 0;

  final int index;

  bool showLines = true;
  bool showValues = false;
  bool endWithChart = false;
  bool dashed = false;
  double lineWidth = 1.0;
  double axisStep = 1.0;
  double textScale = 1.2;
  /// Null follows the theme; set means the user picked a colour.
  Color? lineColorOverride;

  Color get lineColor =>
      lineColorOverride ?? _ref.read(chartGridColorProvider);
  TextAlign valuesAlign = TextAlign.end;
  EdgeInsets valuesPadding = EdgeInsets.zero;
  HorizontalLegendPosition legendPosition = HorizontalLegendPosition.end;

  void updateShowLines(bool value) {
    showLines = value;
    notifyListeners();
  }

  void updateShowValues(bool value) {
    showValues = value;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    lineColorOverride = newColor;
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

  void updateDashed(bool value) {
    dashed = value;
    notifyListeners();
  }

  void updateTextScale(double value) {
    textScale = value;
    notifyListeners();
  }

  void updateValuesAlign(TextAlign value) {
    valuesAlign = value;
    notifyListeners();
  }

  void updateValuesPadding(EdgeInsets value) {
    valuesPadding = value;
    notifyListeners();
  }

  void updateLegendPosition(HorizontalLegendPosition value) {
    legendPosition = value;
    notifyListeners();
  }

  /// Axis labels are painted by the chart, not by a Flutter text widget, so
  /// they cannot inherit the app's text theme. The colour is pushed in from
  /// the theme instead; the library default has no colour and paints black,
  /// which disappears in dark mode.
  TextStyle get _legendFontStyle =>
      TextStyle(fontSize: 12, color: _ref.read(chartLabelColorProvider));

  List<double>? get _dashArray => dashed ? const [4, 4] : null;

  @override
  HorizontalAxisDecoration buildDecoration() {
    return HorizontalAxisDecoration(
      showLines: showLines,
      showValues: showValues,
      endWithChart: endWithChart,
      lineWidth: lineWidth,
      axisStep: axisStep,
      lineColor: lineColor,
      textScale: textScale,
      valuesAlign: valuesAlign,
      valuesPadding: valuesPadding,
      legendPosition: legendPosition,
      dashArray: _dashArray,
      legendFontStyle: _legendFontStyle,
    );
  }

  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('HorizontalAxisDecoration(');
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
    if (textScale != 1.0) {
      writer.line('textScale: ${doubleLiteral(textScale)},');
    }
    if (valuesAlign != TextAlign.end) {
      writer.line('valuesAlign: $valuesAlign,');
    }
    if (valuesPadding != EdgeInsets.zero) {
      writer.line('valuesPadding: ${edgeInsetsLiteral(valuesPadding)},');
    }
    if (legendPosition != HorizontalLegendPosition.end) {
      writer.line('legendPosition: $legendPosition,');
    }
    if (dashed) writer.line('dashArray: [4.0, 4.0],');
    if (showValues) {
      writer.line('// Axis labels are painted by the chart, not by a widget,');
      writer.line('// so they need an explicit colour for your background.');
      writer.line('legendFontStyle: TextStyle(fontSize: 12.0, '
          'color: ${colorLiteral(_ref.read(chartLabelColorProvider))}),');
    }
    writer.close('),');
  }
}
