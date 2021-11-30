import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Selected item decoration', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1.4)
      ..addScenario(
        'Default',
        getDefaultChart(backgroundDecorations: [
          SelectedItemDecoration(
            2,
            selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.w800),
          ),
        ]),
      )
      ..addScenario(
        'Can be null',
        getDefaultChart(backgroundDecorations: [
          SelectedItemDecoration(null,
              selectedStyle: defaultTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800)),
        ]),
      )
      ..addScenario(
        'with background color',
        getDefaultChart(backgroundDecorations: [
          SelectedItemDecoration(
            2,
            selectedStyle: defaultTextStyle.copyWith(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.w800),
            backgroundColor: Colors.black,
          ),
        ]),
      );
    await tester.pumpWidgetBuilder(builder.build(),
        surfaceSize: const Size(1400, 330), textScaleSize: 1.4);
    await screenMatchesGolden(tester, 'selected_item_decoration_golden');
  });
}
