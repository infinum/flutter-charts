import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/expanded_section.dart';
import 'package:charts_web/ui/playground/options/options_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(
        body: SingleChildScrollView(child: OptionsPanel()),
      ),
    ),
  ));
  await tester.pumpAndSettle();

  return container;
}

/// Body text unique to each section, used to tell open from closed.
const dataBody = 'Add another list';
const itemsBody = 'Min item width';
const decorationsBody = 'Add a decoration';

void main() {
  testWidgets('only Data is open to begin with', (tester) async {
    await _pump(tester);

    expect(find.text(dataBody), findsOneWidget);
    expect(find.text(itemsBody), findsNothing);
    expect(find.text(decorationsBody), findsNothing);
  });

  testWidgets('opening one section closes the others', (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Item options'));
    await tester.pumpAndSettle();

    expect(container.read(expandedOptionSectionProvider),
        OptionSection.itemOptions);
    expect(find.text(itemsBody), findsOneWidget);
    expect(find.text(dataBody), findsNothing);
    expect(find.text(decorationsBody), findsNothing);

    await tester.tap(find.text('Decorations'));
    await tester.pumpAndSettle();

    expect(find.text(decorationsBody), findsOneWidget);
    expect(find.text(itemsBody), findsNothing);
  });

  testWidgets('closing the open section leaves all three collapsed',
      (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();

    expect(container.read(expandedOptionSectionProvider), isNull);
    expect(find.text(dataBody), findsNothing);
    expect(find.text(itemsBody), findsNothing);
    expect(find.text(decorationsBody), findsNothing);

    // The headings are all still there to reopen.
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Item options'), findsOneWidget);
    expect(find.text('Decorations'), findsOneWidget);
  });

  testWidgets('decoration cards inside a section stay independent',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Decorations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SparkLine'));
    await tester.pumpAndSettle();

    // Both editors are open at once: the accordion applies to the three
    // top-level groups, not to everything built from a SectionCard.
    expect(find.text('Grid decoration'), findsOneWidget);
    expect(find.text('SparkLine decoration'), findsOneWidget);
    expect(find.text('Horizontal lines'), findsOneWidget);
    expect(find.text('Smooth points'), findsOneWidget);
  });
}
