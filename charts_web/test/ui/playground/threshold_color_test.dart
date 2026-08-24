import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _above = Color(0xFFD8262C);

ChartStatePresenter _presenter() {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  return container.read(chartStatePresenter);
}

Color _barColor(ChartStatePresenter presenter, double value) {
  final options = presenter.state.itemOptions as BarItemOptions;

  return options
      .barItemBuilder(ItemBuilderData(ChartItem<void>(value), 0, 0))
      .color;
}

Color _bubbleColor(ChartStatePresenter presenter, double value) {
  final options = presenter.state.itemOptions as BubbleItemOptions;

  return options
      .bubbleItemBuilder(ItemBuilderData(ChartItem<void>(value), 0, 0))
      .color;
}

void main() {
  test('without a threshold every item keeps the series colour', () {
    final presenter = _presenter();
    final series = presenter.listColors.first;

    expect(presenter.colorThreshold, isNull);
    expect(_barColor(presenter, 1), series);
    expect(_barColor(presenter, 99), series);
  });

  test('items over the threshold take the above-threshold colour', () {
    final presenter = _presenter()
      ..updateColorThreshold(7)
      ..updateAboveThresholdColor(_above);
    final series = presenter.listColors.first;

    expect(_barColor(presenter, 6), series);
    // The test is strictly greater, matching the gallery entry it comes from:
    // hitting the target exactly is not passing it.
    expect(_barColor(presenter, 7), series);
    expect(_barColor(presenter, 8), _above);
  });

  test('bubbles recolour the same way bars do', () {
    final presenter = _presenter()
      ..updateItemPainter(SelectedPainter.bubble)
      ..updateColorThreshold(7)
      ..updateAboveThresholdColor(_above);

    expect(_bubbleColor(presenter, 6), presenter.listColors.first);
    expect(_bubbleColor(presenter, 8), _above);
  });

  test('clearing the threshold keeps the colour that was picked', () {
    final presenter = _presenter()
      ..updateColorThreshold(7)
      ..updateAboveThresholdColor(_above)
      ..updateColorThreshold(null);

    expect(presenter.aboveThresholdColor, _above);
    expect(_barColor(presenter, 99), presenter.listColors.first);
  });
}
