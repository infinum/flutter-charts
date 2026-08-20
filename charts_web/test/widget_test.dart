import 'dart:convert';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/main.dart';
import 'package:charts_web/ui/playground/playground_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Registers the fonts declared in `pubspec.yaml` so text is laid out with the
/// same metrics as the running app.
Future<void> loadAppFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: ChartsWebApp()));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadAppFonts);

  testWidgets('the app boots into the playground with a chart and its source',
      (tester) async {
    await _pumpApp(tester, const Size(1920, 1080));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(PlaygroundScreen), findsOneWidget);
    expect(find.byType(AnimatedChart<void>), findsOneWidget);
    expect(find.textContaining('ChartState<void>'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every destination opens without throwing', (tester) async {
    await _pumpApp(tester, const Size(1920, 2400));

    for (final label in ['Gallery', 'Concepts', 'Playground']) {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }
  });

  testWidgets('the theme toggle cycles system, light and dark',
      (tester) async {
    await _pumpApp(tester, const Size(1920, 1080));

    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

    await tester.tap(find.byIcon(Icons.brightness_auto));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
