import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../util.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testWidgets('Horizontal decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          HorizontalAxisDecoration(
            lineWidth: 2.0,
          ),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_horizontal_decoration_golden.png'));
  });

  testWidgets('Vertical decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          VerticalAxisDecoration(
            lineWidth: 2.0,
          ),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_vertical_decoration_golden.png'));
  });

  testWidgets('Grid decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          GridDecoration(
            gridWidth: 2.0,
          ),
        ]),
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/general/general_grid_decoration_golden.png'));
  });

  testWidgets('Border decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          BorderDecoration(
            borderWidth: 4.0,
          ),
        ]),
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/general/general_border_decoration_golden.png'));
  });

  testWidgets('Value decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          ValueDecoration(textStyle: defaultTextStyle.copyWith(fontSize: 16.0)),
        ]),
      ),
    );
    await expectLater(find.byType(Padding), matchesGoldenFile('goldens/general/general_value_decoration_golden.png'));
  });

  testWidgets('Selected item decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          SelectedItemDecoration(2,
              backgroundColor: Colors.black87,
              selectedStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontFamily: 'Roboto',
                fontSize: 26.0,
              )),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_selected_item_decoration_golden.png'));
  });

  testWidgets('Target line decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(foregroundDecorations: [
          TargetLineDecoration(lineWidth: 2.0, target: 4),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_target_line_decoration_golden.png'));
  });

  testWidgets('Target line text decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(backgroundDecorations: [
          TargetLineDecoration(lineWidth: 2.0, target: 4, targetLineColor: Colors.red.withOpacity(0.1)),
          TargetLineLegendDecoration(
            legendTarget: 4,
            legendDescription: 'This is target |',
            legendStyle: defaultTextStyle.copyWith(fontSize: 18.0, color: Colors.black87),
          ),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_target_line_text_decoration_golden.png'));
  });

  testWidgets('Target area decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(foregroundDecorations: [
          TargetAreaDecoration(targetMin: 3, targetMax: 5),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_target_area_decoration_golden.png'));
  });

  testWidgets('Sparkline text decoration', (tester) async {
    await tester.pumpWidget(
      Container(
        height: 500,
        width: 800,
        child: getDefaultChart(foregroundDecorations: [
          SparkLineDecoration(
            lineWidth: 3.0,
          ),
        ]),
      ),
    );
    await expectLater(
        find.byType(Padding), matchesGoldenFile('goldens/general/general_sparkline_decoration_golden.png'));
  });
}
