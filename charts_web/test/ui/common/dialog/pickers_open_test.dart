import 'package:charts_web/main.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Every dialog that embeds flex_color_picker. The picker is a legacy-Material
/// widget inside a material_ui tree, so it needs both the compatibility bridge
/// and a legacy Material ancestor; miss either and it throws "No Material
/// widget found" the moment the dialog opens.
Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: ChartsWebApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the series colour picker opens', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(ColorSwatchButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(ColorPicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the border dialog opens', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Border').first);
    await tester.pumpAndSettle();

    expect(find.byType(ColorPicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the gradient dialog opens with both pickers', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Gradient').first);
    await tester.pumpAndSettle();

    expect(find.byType(ColorPicker), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the opacity track is available', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(ColorSwatchButton).first);
    await tester.pumpAndSettle();

    final picker = tester.widget<ColorPicker>(find.byType(ColorPicker));
    expect(picker.enableOpacity, isTrue);
    expect(tester.takeException(), isNull);
  });
}
