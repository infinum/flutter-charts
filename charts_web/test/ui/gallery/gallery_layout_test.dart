import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_detail.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/gallery/gallery_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: Scaffold(body: child),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cards keep their size on a very wide window', (tester) async {
    await _pump(tester, const GalleryScreen(), const Size(2400, 2000));

    final cards = find.byType(Card);
    expect(cards, findsWidgets);

    // Without a max-extent grid these stretched to fill the window.
    for (var i = 0; i < tester.widgetList(cards).length; i++) {
      expect(tester.getSize(cards.at(i)).width, lessThanOrEqualTo(440));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the detail view lays out at both widths', (tester) async {
    final entry = galleryEntries.first;

    await _pump(tester, GalleryDetail(entry: entry), const Size(1800, 1600));
    expect(find.text('Make it yours'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(tester, GalleryDetail(entry: entry), const Size(420, 2000));
    expect(find.text('Make it yours'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
