import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('entries have unique ids and non-empty copy', () {
    expect(galleryEntries, hasLength(greaterThanOrEqualTo(12)));

    final ids = galleryEntries.map((entry) => entry.id).toSet();
    expect(ids, hasLength(galleryEntries.length));

    for (final entry in galleryEntries) {
      expect(entry.title, isNotEmpty, reason: entry.id);
      expect(entry.blurb, isNotEmpty, reason: entry.id);
      expect(entry.snippet, contains('ChartState'), reason: entry.id);
      expect(entry.tags, isNotEmpty, reason: entry.id);
    }
  });

  test('every tag is declared in galleryTags', () {
    for (final entry in galleryEntries) {
      for (final tag in entry.tags) {
        expect(galleryTags, contains(tag), reason: '${entry.id} -> $tag');
      }
    }
  });

  testWidgets('every entry builds without throwing', (tester) async {
    for (final entry in galleryEntries) {
      await tester.pumpWidget(MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 240,
            child: Builder(builder: entry.buildChart),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: entry.id);
    }
  });
}
