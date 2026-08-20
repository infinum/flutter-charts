import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/playground/options/item_options_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2400);
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

  return container;
}

void main() {
  testWidgets('item padding offers only the sides the library reads',
      (tester) async {
    await _pump(tester);

    expect(find.text('Left'), findsWidgets);
    expect(find.text('Right'), findsWidgets);
    // padding.top / padding.bottom are never read by charts_painter.
    expect(find.text('Top'), findsNothing);
    expect(find.text('Bottom'), findsNothing);
  });

  testWidgets('a width can be set and cleared again', (tester) async {
    final container = await _pump(tester);
    final presenter = container.read(chartStatePresenter);

    expect(presenter.maxBarWidth, isNull);
    expect(find.text('not set'), findsWidgets);

    presenter.updateMaxBarWidthOrClear(30);
    await tester.pumpAndSettle();
    expect(presenter.maxBarWidth, 30);

    presenter.updateMaxBarWidthOrClear(null);
    await tester.pumpAndSettle();
    expect(presenter.maxBarWidth, isNull);
  });

  testWidgets('series style can change the colour', (tester) async {
    final container = await _pump(tester);
    final presenter = container.read(chartStatePresenter);
    final original = presenter.listColors.first;

    // One swatch in the series style row, and it is a control now.
    final swatches = find.byType(ColorSwatchButton);
    expect(swatches, findsWidgets);

    await tester.tap(swatches.last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The dialog is open rather than the tap being inert.
    expect(find.text('Select color'), findsWidgets);
    expect(presenter.listColors.first, original);
  });

  testWidgets('a set border shows a clear action that unsets it',
      (tester) async {
    final container = await _pump(tester);
    final presenter = container.read(chartStatePresenter);

    expect(find.byTooltip('Clear Border'), findsNothing);

    presenter.updateItemBorderSide(
        const BorderSide(color: Color(0xFF202020), width: 2), 0);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Clear Border'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear Border'));
    await tester.pumpAndSettle();

    expect(presenter.itemBorderSides.first, BorderSide.none);
    expect(find.byTooltip('Clear Border'), findsNothing);
  });
}
