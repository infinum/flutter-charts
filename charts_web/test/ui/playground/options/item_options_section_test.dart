import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/item_options_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('choosing a painter updates the presenter', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: ItemOptionsSection()),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(container.read(chartStatePresenter).selectedPainter,
        SelectedPainter.bar);

    await tester.tap(find.text('Bubble'));
    await tester.pumpAndSettle();

    expect(container.read(chartStatePresenter).selectedPainter,
        SelectedPainter.bubble);
  });
}
