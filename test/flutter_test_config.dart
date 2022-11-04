import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      return testMain();
    },
    config: GoldenToolkitConfiguration(

        // Mac has fon smoothing that will sometimes trigger false positives based on system settings.
        // Skip assertion on Mac until fix is deployed: https://github.com/flutter/flutter/issues/56383
        // skipGoldenAssertion: () => Platform.isMacOS,
        ),
  );
}
