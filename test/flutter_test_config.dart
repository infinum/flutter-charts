import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  const isRunningInCi = bool.fromEnvironment('CI', defaultValue: false);

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      // Alchemist 0.14 defaults to a blue backdrop and 18px scenario labels.
      // Keep the white backdrop the committed goldens were built around.
      goldenTestTheme: GoldenTestTheme(
        backgroundColor: Colors.white,
        borderColor: const Color(0xFFE0E0E0),
        nameTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        padding: const EdgeInsets.all(8),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        brightness: Brightness.light,
      ),
      ciGoldensConfig: const CiGoldensConfig(
        enabled: isRunningInCi,
        diffThreshold: 0.05,
      ),
      platformGoldensConfig: const PlatformGoldensConfig(
        enabled: !isRunningInCi,
      ),
    ),
    run: testMain,
  );
}
