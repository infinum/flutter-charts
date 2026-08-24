import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/item_options_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String render(void Function(ChartStatePresenter) configure) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final presenter = container.read(chartStatePresenter);
  configure(presenter);

  final writer = SourceWriter();
  writeItemOptions(writer, presenter);

  return writer.build();
}

void main() {
  test('bar painter emits BarItemOptions with the series colour', () {
    final source = render((presenter) {
      presenter.updateItemPainter(SelectedPainter.bar);
      presenter.updateListColor(const Color(0xFFD8262C), 0);
    });

    expect(source, startsWith('itemOptions: BarItemOptions('));
    expect(source, contains('barItemBuilder: (data) => BarItem('));
    expect(source, contains('color: Color(0xFFD8262C),'));
  });

  test('bar painter omits radius, border and gradient when unset', () {
    final source =
        render((presenter) => presenter.updateItemPainter(SelectedPainter.bar));

    expect(source, isNot(contains('radius:')));
    expect(source, isNot(contains('border:')));
    expect(source, isNot(contains('gradient:')));
  });

  test('multiple series emit an indexed lookup', () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter.updateListColor(const Color(0xFF111111), 0);
      presenter.updateListColor(const Color(0xFF222222), 1);
    });

    expect(
      source,
      contains(
          'color: [Color(0xFF111111), Color(0xFF222222)][data.listIndex % 2],'),
    );
  });

  test('a colour threshold emits a test against the item value', () {
    final source = render((presenter) {
      presenter.updateListColor(const Color(0xFF5A8772), 0);
      presenter.updateColorThreshold(7);
      presenter.updateAboveThresholdColor(const Color(0xFFD8262C));
    });

    expect(
      source,
      contains('color: (data.item.max ?? 0) > 7.0 ? Color(0xFFD8262C) : '
          'Color(0xFF5A8772),'),
    );
  });

  test('a colour threshold keeps the per-series lookup as its else branch',
      () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter.updateListColor(const Color(0xFF111111), 0);
      presenter.updateListColor(const Color(0xFF222222), 1);
      presenter.updateColorThreshold(4);
      presenter.updateAboveThresholdColor(const Color(0xFFD8262C));
    });

    expect(
      source,
      contains('color: (data.item.max ?? 0) > 4.0 ? Color(0xFFD8262C) : '
          '[Color(0xFF111111), Color(0xFF222222)][data.listIndex % 2],'),
    );
  });

  test('no threshold leaves the colour a plain literal', () {
    final source = render((presenter) => presenter.updateColorThreshold(null));

    expect(source, isNot(contains('data.item.max')));
  });

  test('per-series radius is emitted when any series sets one', () {
    final source = render((presenter) {
      presenter.updateItemPainter(SelectedPainter.bar);
      presenter.updateBarBorderRadius(BorderRadius.circular(8), 0);
    });

    expect(source, contains('radius: BorderRadius.all(Radius.circular(8.0)),'));
  });

  test('empty painter emits a zero-width transparent bubble', () {
    final source =
        render((presenter) => presenter.updateItemPainter(SelectedPainter.none));

    expect(source, contains('BubbleItemOptions('));
    expect(source, contains('maxBarWidth: 0.0,'));
    expect(source, contains('Color(0x00000000)'));
  });

  test('widget painter emits a compiling substitute and points at the source',
      () {
    final source = render(
        (presenter) => presenter.updateItemPainter(SelectedPainter.widget));

    expect(source, contains('WidgetItemOptions('));
    expect(source, contains('widgetItemBuilder:'));
    expect(source, contains('futurama_bar_widget.dart'));
  });
}
