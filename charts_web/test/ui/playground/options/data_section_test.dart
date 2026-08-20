import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/data_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
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
        body: SingleChildScrollView(child: DataSection()),
      ),
    ),
  ));
  await tester.pumpAndSettle();

  return container;
}

void main() {
  testWidgets('typing values updates the presenter data', (tester) async {
    final container = await _pump(tester);

    await tester.enterText(find.byType(TextField).first, '1, 2, 3');
    await tester.pump();

    final values = container.read(chartStatePresenter).data.first;
    expect(values.map((item) => item.max).toList(), [1.0, 2.0, 3.0]);
  });

  testWidgets('adding a list grows the data and the colour list',
      (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Add another list'));
    await tester.pumpAndSettle();

    final presenter = container.read(chartStatePresenter);
    expect(presenter.data.length, 2);
    expect(presenter.listColors.length, 2);
  });

  testWidgets('the strategy choice only appears with multiple lists',
      (tester) async {
    final container = await _pump(tester);

    expect(find.text('Stacked'), findsNothing);

    container.read(chartStatePresenter).addDataList(
        [1, 2, 3].map((e) => ChartItem<void>(e.toDouble())).toList());
    await tester.pumpAndSettle();

    expect(find.text('Stacked'), findsOneWidget);
  });
}
