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

  goldenTest('Horizontal deooration',
      fileName: 'general_horizontal_decoration_golden', builder: () {
    return GoldenTestScenario(
      name: 'Horizontal decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
            lineWidth: 4.0,
          ),
        ]),
      ),
    );
  });

  goldenTest('Vertical decoration',
      fileName: 'general_vertical_decoration_golden', builder: () {
    return GoldenTestScenario(
        name: 'Vertical decoration',
        child: Container(
          height: 500,
          width: 800,
          child: getDefaultChart(backgroundDecorations: [
            VerticalAxisDecoration(
              lineWidth: 4.0,
            ),
          ]),
        ));
  });

  goldenTest('Grid decoration', fileName: 'general_grid_decoration_golden',
      builder: () {
    return GoldenTestScenario(
      name: 'Grid decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            gridWidth: 4.0,
          ),
        ]),
      ),
    );
  });

  goldenTest('Border decoration', fileName: 'general_border_decoration_golden',
      builder: () {
    return GoldenTestScenario(
      name: 'Border decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          BorderDecoration(borderWidth: 4),
        ]),
      ),
    );
  });

  goldenTest('Selected item decoration',
      fileName: 'general_selected_item_decoration_golden', builder: () {
    return GoldenTestScenario(
      name: 'Selected item decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          SelectedItemDecoration(
            2,
            backgroundColor: Colors.grey.withOpacity(0.25),
            showText: false,
          ),
        ]),
      ),
    );
  });

  goldenTest('Target line decoration',
      fileName: 'general_target_line_decoration_golden', builder: () {
    return GoldenTestScenario(
      name: 'Target line decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(foregroundDecorations: [
          TargetLineDecoration(lineWidth: 8.0, target: 4),
        ]),
      ),
    );
  });

  goldenTest('Target line text decoration',
      fileName: 'general_target_line_text_decoration_golden', builder: () {
    return GoldenTestScenario(
      name: 'Target line text decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(
          foregroundDecorations: [
            TargetLineDecoration(
                lineWidth: 8,
                target: 4,
                targetLineColor: Colors.red.withOpacity(0.2)),
            TargetLineLegendDecoration(
              legendTarget: 4,
              legendDescription: 'This is target |',
              legendStyle: defaultTextStyle.copyWith(
                fontSize: 32.0,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  });

  goldenTest('Target area decoration',
      fileName: 'general_target_area_decoration_golden', builder: () {
    return GoldenTestScenario(
      name: 'Target area decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(
          foregroundDecorations: [
            TargetAreaDecoration(targetMin: 3, targetMax: 5, lineWidth: 4),
          ],
        ),
      ),
    );
  });

  goldenTest('Sparkline text decoration',
      fileName: 'general_sparkline_decoration_golden', builder: () {
    return GoldenTestScenario(
      name: 'Sparkline text decoration',
      child: Container(
        height: 500,
        width: 800,
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 8.0,
          ),
        ]),
      ),
    );
  });
}
