import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/resizable_pane.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(
        body: Row(children: [SizedBox(width: 400), PaneDragHandle()]),
      ),
    ),
  ));
  await tester.pumpAndSettle();

  return container;
}

void main() {
  testWidgets('dragging the handle widens the options pane', (tester) async {
    final container = await _pump(tester);

    await tester.drag(find.byType(PaneDragHandle), const Offset(80, 0));
    await tester.pumpAndSettle();

    // The drag recogniser swallows the initial slop (kDragSlopDefault, 20px),
    // so the pane grows by slightly less than the gesture distance.
    expect(
      container.read(optionsPaneWidthProvider),
      closeTo(kDefaultOptionsWidth + 80, kDragSlopDefault + 1),
    );
    expect(container.read(optionsPaneWidthProvider),
        greaterThan(kDefaultOptionsWidth));
  });

  testWidgets('the width is clamped at both ends', (tester) async {
    final container = await _pump(tester);

    await tester.drag(find.byType(PaneDragHandle), const Offset(-5000, 0));
    await tester.pumpAndSettle();
    expect(container.read(optionsPaneWidthProvider), kMinOptionsWidth);

    await tester.drag(find.byType(PaneDragHandle), const Offset(5000, 0));
    await tester.pumpAndSettle();
    expect(container.read(optionsPaneWidthProvider), kMaxOptionsWidth);
  });

  testWidgets('double-click resets the width', (tester) async {
    final container = await _pump(tester);

    await tester.drag(find.byType(PaneDragHandle), const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(container.read(optionsPaneWidthProvider),
        isNot(kDefaultOptionsWidth));

    await tester.tap(find.byType(PaneDragHandle));
    await tester.pump(kDoubleTapMinTime);  // between the two taps
    await tester.tap(find.byType(PaneDragHandle));
    await tester.pumpAndSettle();

    expect(container.read(optionsPaneWidthProvider), kDefaultOptionsWidth);
  });
}
