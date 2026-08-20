import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/decorations_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String render(void Function(ProviderContainer) configure) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  configure(container);

  final writer = SourceWriter();
  writeDecorations(writer, container.read(chartDecorationsPresenter));

  return writer.build();
}

void main() {
  test('nothing is emitted when there are no decorations', () {
    expect(render((_) {}), isEmpty);
  });

  test('a sparkline emits listIndex, not the non-existent lineKey', () {
    final source = render((container) => container
        .read(chartDecorationsPresenter)
        .addDecoration(SparkLineDecoration()));

    expect(source, contains('SparkLineDecoration('));
    expect(source, isNot(contains('lineKey')));
  });

  test('a sparkline gradient reaches the output', () {
    final source = render((container) {
      container
          .read(chartDecorationsPresenter)
          .addDecoration(SparkLineDecoration());
      container.read(decorationSparkLinePresenter(0)).updateGradient(
            const LinearGradient(
              colors: [Color(0xFFD8262C), Color(0x00000000)],
            ),
          );
    });

    expect(source, contains('gradient: LinearGradient(colors: ['));
  });

  test('decorations are grouped by layer', () {
    final source = render((container) {
      final presenter = container.read(chartDecorationsPresenter);
      presenter.addDecoration(HorizontalAxisDecoration(),
          layer: DecorationLayer.background);
      presenter.addDecoration(SparkLineDecoration(),
          layer: DecorationLayer.foreground);
    });

    expect(source, contains('backgroundDecorations: ['));
    expect(source, contains('foregroundDecorations: ['));
    expect(
      source.indexOf('backgroundDecorations'),
      lessThan(source.indexOf('foregroundDecorations')),
    );
  });

  test('axis defaults are omitted but the explicit textScale is kept', () {
    final source = render((container) => container
        .read(chartDecorationsPresenter)
        .addDecoration(VerticalAxisDecoration()));

    expect(source, contains('VerticalAxisDecoration('));
    expect(source, contains('textScale: 1.2,'));
    expect(source, isNot(contains('showLines: true,')));
    expect(source, isNot(contains('showValues: false,')));
  });
}
