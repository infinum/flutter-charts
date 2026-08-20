import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/concepts/concepts_screen.dart';
import 'package:charts_web/ui/gallery/gallery_screen.dart';
import 'package:charts_web/ui/playground/playground_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Every surface must render in both brightnesses. A hardcoded light-only
/// colour usually shows up here as an exception or an overflow.
void main() {
  for (final brightness in Brightness.values) {
    for (final entry in <String, Widget>{
      'playground': const PlaygroundScreen(),
      'gallery': const GalleryScreen(),
      'concepts': const ConceptsScreen(),
    }.entries) {
      testWidgets('${entry.key} renders in ${brightness.name}', (tester) async {
        tester.view.physicalSize = const Size(1600, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            theme: appTheme(brightness),
            home: Scaffold(body: entry.value),
          ),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
