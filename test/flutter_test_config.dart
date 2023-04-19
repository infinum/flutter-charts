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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
          background: Colors.white,
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
      ),
      ciGoldensConfig: const CiGoldensConfig(
        enabled: isRunningInCi,
        tolerance: 0.05,
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
