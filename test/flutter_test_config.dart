import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  const isRunningInCi = bool.fromEnvironment('CI', defaultValue: false);

  await loadAppFonts();

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      theme: ThemeData(
        backgroundColor: Colors.white.withOpacity(0.7),
        brightness: Brightness.light,
      ),
      platformGoldensConfig: const PlatformGoldensConfig(
        enabled: !isRunningInCi,
      ),
    ),
    run: testMain,
  );

  // return GoldenToolkit.runWithConfiguration(
  //   () async {
  //     await loadAppFonts();
  //     return testMain();
  //   },
  //   config: GoldenToolkitConfiguration(
  //     enableRealShadows: false,
  //     // Mac has fon smoothing that will sometimes trigger false positives based on system settings.
  //     // Skip assertion on Mac until fix is deployed: https://github.com/flutter/flutter/issues/56383
  //     // skipGoldenAssertion: () => Platform.isMacOS,
  //   ),
  // );
}
