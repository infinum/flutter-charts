import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_vertical_axis_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_label_color_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Axis values are painted on the chart canvas, so they cannot inherit the
/// text theme. Without an explicit colour the library default paints black and
/// vanishes in dark mode.
void main() {
  test('axis label colour follows the theme colour pushed into the provider',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const darkOnSurface = Color(0xFFF5DDDC);
    container.read(chartLabelColorProvider.notifier).state = darkOnSurface;

    expect(
      container
          .read(decorationHorizontalAxisPresenter(0))
          .buildDecoration()
          .legendFontStyle
          ?.color,
      darkOnSurface,
    );
    expect(
      container
          .read(decorationVerticalAxisPresenter(1))
          .buildDecoration()
          .legendFontStyle
          ?.color,
      darkOnSurface,
    );
  });

  test('changing the theme colour rebuilds an existing decoration', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final presenter = container.read(decorationHorizontalAxisPresenter(0));
    var notifications = 0;
    presenter.addListener(() => notifications++);

    container.read(chartLabelColorProvider.notifier).state =
        const Color(0xFF102030);

    expect(notifications, greaterThan(0));
    expect(presenter.buildDecoration().legendFontStyle?.color,
        const Color(0xFF102030));
  });
}
