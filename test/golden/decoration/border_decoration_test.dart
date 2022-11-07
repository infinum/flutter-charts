import 'package:alchemist/alchemist.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  goldenTest('Border decoration', fileName: 'border_decoration_golden',
      builder: () {
    return GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'Default',
          child: getDefaultChart(backgroundDecorations: [
            BorderDecoration(),
          ]),
        ),
        GoldenTestScenario(
          name: 'Increase width',
          child: getDefaultChart(backgroundDecorations: [
            BorderDecoration(
              borderWidth: 6.0,
            ),
          ]),
        ),
        GoldenTestScenario(
          name: 'End with cahrt',
          child: getDefaultChart(backgroundDecorations: [
            BorderDecoration(
                sidesWidth: Border.symmetric(
                    vertical: BorderSide(width: 1.0, color: Colors.black))),
          ]),
        ),
        GoldenTestScenario(
          name: 'Just vertical',
          child: getDefaultChart(backgroundDecorations: [
            BorderDecoration(
                sidesWidth: Border.symmetric(
                    vertical: BorderSide(width: 1.0, color: Colors.black))),
          ]),
        ),
        GoldenTestScenario(
          name: 'Just horizontal',
          child: getDefaultChart(backgroundDecorations: [
            BorderDecoration(
                sidesWidth: Border.symmetric(
                    horizontal: BorderSide(width: 1.0, color: Colors.black))),
          ]),
        ),
        GoldenTestScenario(
          name: 'All different',
          child: getDefaultChart(backgroundDecorations: [
            BorderDecoration(
                sidesWidth: Border(
              top: BorderSide(width: 2.0, color: Colors.red),
              bottom: BorderSide(width: 4.0, color: Colors.yellow),
              left: BorderSide(width: 2.0, color: Colors.green),
              right: BorderSide(width: 4.0, color: Colors.black),
            )),
          ]),
        ),
      ],
    );
  });
}
