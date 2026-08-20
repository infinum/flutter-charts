// This is the one file in charts_web allowed to import
// package:flutter/material.dart: its whole subject is the boundary between the
// legacy Material library and package:material_ui. Everything else must import
// material_ui only.
// ignore_for_file: deprecated_member_use
import 'package:charts_web/main.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the colour picker opens and inherits the app theme',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: ChartsWebApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ColorSwatchButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(ColorPicker), findsOneWidget);
    expect(tester.takeException(), isNull);

    final pickerContext = tester.element(find.byType(ColorPicker));

    // flex_color_picker 3.8.0 imports package:flutter/material.dart, whose
    // ThemeData is a different class from material_ui's. Without
    // MaterialUiCompatibilityBridge in main.dart, legacy Theme.of does not
    // throw — it silently falls back to Flutter's default palette, so the
    // picker would render in default purple instead of the app's colours.
    expect(
      legacy.Theme.of(pickerContext).colorScheme.primary,
      Theme.of(pickerContext).colorScheme.primary,
      reason: 'legacy theme should be bridged from the material_ui theme',
    );

    // Unlike the theme, this one does throw when unbridged.
    expect(legacy.MaterialLocalizations.of(pickerContext), isNotNull);
  });
}
