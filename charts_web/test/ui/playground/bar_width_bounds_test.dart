import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// ItemOptions asserts maxBarWidth >= minBarWidth. The playground used to let
/// you cross them, which threw as soon as the chart rebuilt.
void main() {
  test('raising the minimum above the maximum carries the maximum up', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final presenter = container.read(chartStatePresenter)
      ..updateMaxBarWidth(10)
      ..updateMinBarWidth(90);

    expect(presenter.minBarWidth, 90);
    expect(presenter.maxBarWidth, 90);
  });

  test('lowering the maximum below the minimum pulls the minimum down', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final presenter = container.read(chartStatePresenter)
      ..updateMinBarWidth(40)
      ..updateMaxBarWidth(12);

    expect(presenter.minBarWidth, 12);
    expect(presenter.maxBarWidth, 12);
  });

  test('widths cannot go negative', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final presenter = container.read(chartStatePresenter)
      ..updateMinBarWidth(-5)
      ..updateMaxBarWidth(-20);

    expect(presenter.minBarWidth, 0);
    expect(presenter.maxBarWidth, 0);
  });

  testWidgets('crossing the bounds no longer throws when the chart rebuilds',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final presenter = container.read(chartStatePresenter)
      ..updateMaxBarWidth(10)
      ..updateMinBarWidth(90);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: Chart<void>(state: presenter.state),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
