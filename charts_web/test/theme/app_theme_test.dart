import 'package:charts_web/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('appTheme is Material 3 and derives from the brand seed', () {
    final light = appTheme(Brightness.light);
    final expected =
        ColorScheme.fromSeed(seedColor: kSeedColor, brightness: Brightness.light);

    expect(light.useMaterial3, isTrue);
    expect(light.colorScheme.primary, expected.primary);
    expect(light.colorScheme.brightness, Brightness.light);
  });

  test('appTheme builds a dark variant from the same seed', () {
    final dark = appTheme(Brightness.dark);

    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(
      dark.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: kSeedColor, brightness: Brightness.dark)
          .primary,
    );
  });

  test('appTheme uses InterTight and styles cards without elevation', () {
    final theme = appTheme(Brightness.light);

    expect(theme.textTheme.bodyMedium!.fontFamily, 'InterTight');
    expect(theme.cardTheme.elevation, 0);
  });
}
