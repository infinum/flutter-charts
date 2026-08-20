import 'dart:io';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/chart_state_source.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class Preset {
  const Preset(this.functionName, this.fileName, this.configure);

  final String functionName;
  final String fileName;
  final void Function(ProviderContainer container) configure;
}

final presets = <Preset>[
  Preset('fixture01DefaultBar', 'fixture_01_default_bar.dart', (_) {}),
  Preset('fixture02StackedSeries', 'fixture_02_stacked_series.dart',
      (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.addDataList(
        [3, 5, 1, 4].map((e) => ChartItem<void>(e.toDouble())).toList());
    presenter.updateDataStrategy(const StackDataStrategy());
  }),
  Preset('fixture03GroupedSeries', 'fixture_03_grouped_series.dart',
      (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.addDataList(
        [3, 5, 1, 4].map((e) => ChartItem<void>(e.toDouble())).toList());
    presenter.updateDataStrategy(
        const DefaultDataStrategy(stackMultipleValues: true));
    presenter.updateStackMultipleValues(false);
    presenter
        .updateMultiValuePadding(const EdgeInsets.symmetric(horizontal: 2));
  }),
  Preset('fixture04Bubble', 'fixture_04_bubble.dart', (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.updateItemPainter(SelectedPainter.bubble);
    presenter.updateMinBarWidth(6);
    presenter.updateMaxBarWidth(10);
  }),
  Preset('fixture05BarStyled', 'fixture_05_bar_styled.dart', (container) {
    final presenter = container.read(chartStatePresenter);
    presenter.updateBarBorderRadius(
        const BorderRadius.vertical(top: Radius.circular(8)), 0);
    presenter.updateItemBorderSide(
        const BorderSide(color: Color(0xFF202020), width: 2), 0);
    presenter.updateGradient(
        const LinearGradient(
          colors: [Color(0xFFD8262C), Color(0xFF6479C3)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        0);
  }),
  Preset('fixture06Sparkline', 'fixture_06_sparkline.dart', (container) {
    container.read(chartStatePresenter).updateItemPainter(SelectedPainter.none);
    container
        .read(chartDecorationsPresenter)
        .addDecoration(SparkLineDecoration());
    final sparkline = container.read(decorationSparkLinePresenter(0));
    sparkline.updateFilled(true);
    sparkline.updateSmoothPoints(true);
    sparkline.updateLineWidth(2);
    sparkline.updateGradient(const LinearGradient(
      colors: [Color(0x66D8262C), Color(0x00D8262C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ));
  }),
  Preset('fixture07BothAxes', 'fixture_07_both_axes.dart', (container) {
    final decorations = container.read(chartDecorationsPresenter);
    decorations.addDecoration(HorizontalAxisDecoration(),
        layer: DecorationLayer.background);
    decorations.addDecoration(VerticalAxisDecoration(),
        layer: DecorationLayer.background);
  }),
  Preset('fixture08WidgetEverything', 'fixture_08_widget_everything.dart',
      (container) {
    container
        .read(chartStatePresenter)
        .updateItemPainter(SelectedPainter.widget);
    container.read(chartDecorationsPresenter).addDecoration(
          WidgetDecoration(
            widgetDecorationBuilder: (_, __, ___, ____) =>
                const SizedBox.shrink(),
          ),
        );
  }),
];

String wrap(String functionName, String expression) => '''
// GENERATED -- do not edit by hand.
// Regenerate with:
//   UPDATE_FIXTURES=1 fvm flutter test test/codegen/chart_state_source_test.dart
// Committed so `fvm flutter analyze` proves the generated source compiles.

import 'package:charts_painter/chart.dart';
import 'package:material_ui/material_ui.dart';

ChartState<void> $functionName() => $expression;
''';

String sourceFor(Preset preset) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  preset.configure(container);

  return buildChartStateSource(
    container.read(chartStatePresenter),
    container.read(chartDecorationsPresenter),
  );
}

void main() {
  for (final preset in presets) {
    test('${preset.functionName} matches its committed fixture', () {
      final rendered = wrap(preset.functionName, sourceFor(preset));
      final file = File('test/codegen/generated/${preset.fileName}');

      if (Platform.environment['UPDATE_FIXTURES'] == '1') {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(rendered);
      }

      expect(
        file.readAsStringSync(),
        rendered,
        reason: 'Generated source drifted. Regenerate with '
            'UPDATE_FIXTURES=1 fvm flutter test '
            'test/codegen/chart_state_source_test.dart',
      );
    });
  }

  test('generated source never contains a deprecated constructor', () {
    for (final preset in presets) {
      final source = sourceFor(preset);

      expect(source, isNot(contains('BarValue')), reason: preset.functionName);
      expect(source, isNot(contains('BubbleValue')),
          reason: preset.functionName);
      expect(source, isNot(contains('lineKey')), reason: preset.functionName);
    }
  });
}
