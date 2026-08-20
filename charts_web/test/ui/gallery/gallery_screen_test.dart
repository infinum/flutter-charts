import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/gallery/gallery_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('filtering by tag narrows the grid', (tester) async {
    tester.view.physicalSize = const Size(1600, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(body: GalleryScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text(galleryEntries.first.title), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'decoration'));
    await tester.pumpAndSettle();

    final decorationEntries =
        galleryEntries.where((entry) => entry.tags.contains('decoration'));
    for (final entry in decorationEntries) {
      expect(find.text(entry.title), findsOneWidget, reason: entry.id);
    }
  });
}
