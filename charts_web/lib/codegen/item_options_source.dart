import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter/painting.dart';

/// Emits the `itemOptions:` argument of `ChartState`.
void writeItemOptions(SourceWriter writer, ChartStatePresenter presenter) {
  switch (presenter.selectedPainter) {
    case SelectedPainter.bar:
      _writeGeometry(writer, presenter, isBar: true);
    case SelectedPainter.bubble:
      _writeGeometry(writer, presenter, isBar: false);
    case SelectedPainter.none:
      _writeEmpty(writer);
    case SelectedPainter.widget:
      _writeWidget(writer);
  }
}

void _writeGeometry(
  SourceWriter writer,
  ChartStatePresenter presenter, {
  required bool isBar,
}) {
  final seriesCount = presenter.data.length;

  writer
      .open('itemOptions: ${isBar ? 'BarItemOptions' : 'BubbleItemOptions'}(');

  if (presenter.chartItemPadding != EdgeInsets.zero) {
    writer.line('padding: ${edgeInsetsLiteral(presenter.chartItemPadding)},');
  }
  if (presenter.multiValuePadding != EdgeInsets.zero) {
    writer.line(
        'multiValuePadding: ${edgeInsetsLiteral(presenter.multiValuePadding)},');
  }
  if (presenter.maxBarWidth != null) {
    writer.line('maxBarWidth: ${doubleLiteral(presenter.maxBarWidth!)},');
  }
  if (presenter.minBarWidth != null) {
    writer.line('minBarWidth: ${doubleLiteral(presenter.minBarWidth!)},');
  }

  final builder = isBar ? 'barItemBuilder' : 'bubbleItemBuilder';
  final item = isBar ? 'BarItem' : 'BubbleItem';

  writer.open('$builder: (data) => $item(');
  writer.line('color: ${_perSeries(
    seriesCount,
    (index) => colorLiteral(
        presenter.listColors[index % presenter.listColors.length]),
  )},');

  if (presenter.gradient.isNotEmpty) {
    writer.line('gradient: ${_perSeries(seriesCount, (index) {
      final gradient = presenter.gradient[index];

      return gradient == null ? 'null' : gradientLiteral(gradient);
    })},');
  }

  if (presenter.itemBorderSides.any((side) => side != BorderSide.none)) {
    writer.line('border: ${_perSeries(
      seriesCount,
      (index) => borderSideLiteral(presenter.itemBorderSides[index]),
    )},');
  }

  if (isBar &&
      presenter.barBorderRadius.any((radius) => radius != BorderRadius.zero)) {
    writer.line('radius: ${_perSeries(
      seriesCount,
      (index) => borderRadiusLiteral(presenter.barBorderRadius[index]),
    )},');
  }

  writer.close('),');
  writer.close('),');
}

void _writeEmpty(SourceWriter writer) {
  writer.open('itemOptions: BubbleItemOptions(');
  writer.line(
      'bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),');
  writer.line('maxBarWidth: 0.0,');
  writer.line('minBarWidth: 0.0,');
  writer.close('),');
}

void _writeWidget(SourceWriter writer) {
  writer.open('itemOptions: WidgetItemOptions(');
  writer.line('// Any widget works here. This demo draws an image; see');
  writer
      .line('// charts_web/lib/ui/playground/options/futurama_bar_widget.dart');
  writer.open('widgetItemBuilder: (data) => DecoratedBox(');
  writer.open('decoration: BoxDecoration(');
  writer.line('color: Color(0xFFD8262C),');
  writer.line('borderRadius: BorderRadius.all(Radius.circular(4.0)),');
  writer.close('),');
  writer.line('child: const SizedBox.expand(),');
  writer.close('),');
  writer.close('),');
}

/// One value for a single series, or an inline indexed lookup for several, so
/// the emitted builder stays a self-contained expression.
String _perSeries(int count, String Function(int index) literalFor) {
  if (count <= 1) return literalFor(0);

  final literals = List.generate(count, literalFor).join(', ');

  return '[$literals][data.listIndex % $count]';
}
